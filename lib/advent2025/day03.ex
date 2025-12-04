defmodule Advent2025.Day03 do
  use Advent, day: 3, input: :lines

  def part_1, do: solve(pick: 2)
  def part_2, do: solve(pick: 12)

  defp solve(pick: n), do: input() |> Enum.map(&largest_n_digits(&1, n)) |> Enum.sum()

  defp largest_n_digits(line, n) do
    line
    |> String.graphemes()
    |> pick(0, n)
    |> Integer.undigits()
  end

  defp pick(_, _, 0), do: []

  defp pick(digits, from, remaining) do
    last_valid = length(digits) - remaining

    {digit, i} =
      digits |> Enum.slice(from..last_valid) |> Enum.with_index(from) |> Enum.max_by(&elem(&1, 0))

    [String.to_integer(digit) | pick(digits, i + 1, remaining - 1)]
  end
end
