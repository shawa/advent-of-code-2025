defmodule Advent2025.Day07 do
  use Advent, day: 7, input: Advent2025.Day07.Parser

  def part_1 do
    # just count the number of hits
    {_, hits} = simulate(fn _, _ -> 1 end)
    hits
  end

  def part_2 do
    {final, _} = simulate(&+/2)
    final |> Map.values() |> Enum.sum()
  end

  defp simulate(merge) do
    {n_rows, cols, start_col, splitter_rows} = input()

    Enum.reduce(
      1..(n_rows - 1),
      {%{start_col => 1}, 0},
      &step(&1, &2, splitter_rows, cols, merge)
    )
  end

  defp step(row, {beams, hits}, splitter_rows, cols, merge) do
    row_splitters = Map.get(splitter_rows, row, MapSet.new())

    {hit, continuing} =
      Map.split_with(beams, fn {col, _} -> MapSet.member?(row_splitters, col) end)

    spawned =
      hit
      |> Enum.flat_map(fn {col, n} -> Enum.map(do_spawn(col, cols), &{&1, n}) end)
      |> Enum.reduce(%{}, fn {col, n}, acc -> Map.update(acc, col, n, &merge.(&1, n)) end)

    {Map.merge(continuing, spawned, fn _, a, b -> merge.(a, b) end), hits + map_size(hit)}
  end

  defp do_spawn(col, cols) when col > 0 and col < cols - 1, do: [col - 1, col + 1]
  defp do_spawn(0, _), do: [1]
  defp do_spawn(col, cols) when col == cols - 1, do: [col - 1]
end

defmodule Advent2025.Day07.Parser do
  def parse!(input) do
    lines = String.split(input, "\n", trim: true)
    n_rows = length(lines)
    cols = String.length(hd(lines))
    start_col = lines |> hd() |> String.graphemes() |> Enum.find_index(&(&1 == "S"))

    splitter_rows =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, row} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {c, _} -> c == "^" end)
        |> Enum.map(fn {_, col} -> {row, col} end)
      end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Map.new(fn {row, cs} -> {row, MapSet.new(cs)} end)

    {n_rows, cols, start_col, splitter_rows}
  end
end
