defmodule UnionFind do
  # https://en.wikipedia.org/wiki/Disjoint-set_data_structure
  defstruct [:parent, :rank, :count]

  def new(elements) do
    %__MODULE__{
      parent: Map.new(elements, &{&1, &1}),
      rank: Map.new(elements, &{&1, 0}),
      count: length(elements)
    }
  end

  def component_count(%__MODULE__{count: count}), do: count

  def component_sizes(uf) do
    uf.parent
    |> Map.keys()
    |> Enum.map(fn x -> find(uf, x) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.frequencies()
    |> Map.values()
  end

  def find(%__MODULE__{parent: parent} = uf, x) do
    case Map.fetch!(parent, x) do
      ^x ->
        {uf, x}

      px ->
        {uf, root} = find(uf, px)
        {%{uf | parent: Map.put(uf.parent, x, root)}, root}
    end
  end

  def union(uf, x, y) do
    {uf, rx} = find(uf, x)
    {uf, ry} = find(uf, y)

    cond do
      rx == ry ->
        {uf, false}

      uf.rank[rx] < uf.rank[ry] ->
        {%{uf | parent: Map.put(uf.parent, rx, ry), count: uf.count - 1}, true}

      uf.rank[rx] > uf.rank[ry] ->
        {%{uf | parent: Map.put(uf.parent, ry, rx), count: uf.count - 1}, true}

      true ->
        parent = Map.put(uf.parent, ry, rx)
        rank = Map.update!(uf.rank, rx, &(&1 + 1))
        {%{uf | parent: parent, rank: rank, count: uf.count - 1}, true}
    end
  end
end
