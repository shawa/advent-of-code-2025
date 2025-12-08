defmodule Advent2025.Day08 do
  use Advent, day: 8, input: Advent2025.Day08.Parser

  def part_1 do
    {uf, _edges, _last_a, _last_b} = build_graph_until(&edge_count_reached?/2)

    uf
    |> UnionFind.component_sizes()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def part_2 do
    {_uf, _edges, {x1, _, _}, {x2, _, _}} =
      build_graph_until(&is_single_component?/2)

    x1 * x2
  end

  defp edge_count_reached?(_uf, edges), do: MapSet.size(edges) >= 1000
  defp is_single_component?(uf, _edges), do: UnionFind.component_count(uf) == 1

  defp build_graph_until(done?) do
    points = input()
    sorted_pairs = all_pairs_by_distance(points)
    uf = UnionFind.new(points)

    sorted_pairs
    |> Enum.reduce_while(
      {uf, MapSet.new(), nil, nil},
      fn {a, b}, {uf, edges, _, _} = state ->
        edge = if a < b, do: {a, b}, else: {b, a}

        cond do
          done?.(uf, edges) ->
            {:halt, state}

          MapSet.member?(edges, edge) ->
            {:cont, state}

          true ->
            {uf, _} = UnionFind.union(uf, a, b)
            {:cont, {uf, MapSet.put(edges, edge), a, b}}
        end
      end
    )
  end

  defp all_pairs_by_distance(points) do
    for {a, i} <- Enum.with_index(points),
        {b, j} <- Enum.with_index(points),
        i < j do
      {a, b}
    end
    |> Enum.sort_by(fn {a, b} -> distance(a, b) end)
  end

  defp distance({x1, y1, z1}, {x2, y2, z2}) do
    dx = x2 - x1
    dy = y2 - y1
    dz = z2 - z1
    dx * dx + dy * dy + dz * dz
  end
end

defmodule Advent2025.Day08.Parser do
  def parse!(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y, z] = line |> String.split(",") |> Enum.map(&String.to_integer/1)
      {x, y, z}
    end)
  end
end
