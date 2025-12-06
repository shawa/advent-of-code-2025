defmodule Advent2025.Day06 do
  use Advent, day: 6, input: :binary

  def part_1, do: solve(:horizontal)
  def part_2, do: solve(:vertical)

  defp solve(direction) do
    lines = input() |> String.split("\n", trim: true)
    {number_rows, [operator_row]} = Enum.split(lines, -1)

    operator_row
    |> column_bounds()
    |> Enum.map(&extract_column(number_rows, &1, direction))
    |> Enum.zip(Regex.scan(~r/[*+]/, operator_row) |> List.flatten())
    |> Enum.map(&aggregate/1)
    |> Enum.sum()
  end

  defp column_bounds(operator_row) do
    positions =
      operator_row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {c, _} -> c in ["*", "+"] end)
      |> Enum.map(fn {_, i} -> i end)

    ends = tl(positions) ++ [String.length(operator_row)]
    Enum.zip(positions, ends)
  end

  defp extract_column(rows, {start, stop}, direction) do
    rows
    |> Enum.map(&String.pad_trailing(&1, stop))
    |> Enum.map(&String.slice(&1, start, stop - start))
    |> orient(direction)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
  end

  defp orient(slices, :horizontal), do: slices

  defp orient(slices, :vertical),
    do: slices |> Enum.map(&String.graphemes/1) |> Enum.zip_with(&Enum.join/1)

  defp aggregate({numbers, "+"}), do: Enum.sum(numbers)
  defp aggregate({numbers, "*"}), do: Enum.product(numbers)
end
