defmodule Advent2025.Day05 do
  use Advent, day: 5, input: Advent2025.Day05.Input

  def part_1 do
    %{numbers: numbers, ranges: raw_ranges} = input()
    ranges = raw_ranges |> coalesce() |> List.to_tuple()

    Enum.count(numbers, &in_any_range?(ranges, &1))
  end

  def part_2 do
    input().ranges
    |> coalesce()
    |> Enum.map(&Enum.count/1)
    |> Enum.sum()
  end

  # the spec says the ranges can overlap. exploit this.
  # 1..10, 5..15, 10..12 -> 1..15
  def coalesce(ranges) do
    ranges
    |> Enum.sort_by(& &1.first)
    |> Enum.reduce([], fn
      range, [] ->
        [range]

      range, [current | rest] when range.first <= current.last + 1 ->
        [current.first..max(current.last, range.last) | rest]

      range, acc ->
        [range | acc]
    end)
    |> Enum.reverse()
  end

  defp in_any_range?(ranges, n) do
    binary_search(ranges, n, 0, tuple_size(ranges) - 1)
  end

  defp binary_search(_ranges, _n, lo, hi) when lo > hi, do: false

  defp binary_search(ranges, n, lo, hi) do
    mid = div(lo + hi, 2)
    range = elem(ranges, mid)

    cond do
      n < range.first -> binary_search(ranges, n, lo, mid - 1)
      n > range.last -> binary_search(ranges, n, mid + 1, hi)
      true -> true
    end
  end
end

# pulling the parser out into the module quietens the brain
defmodule Advent2025.Day05.Input do
  def parse!(input) do
    [ranges_part, numbers_part] =
      input
      |> String.trim()
      |> String.split("\n\n")

    ranges =
      ranges_part
      |> String.split("\n")
      |> Enum.map(fn range ->
        [a, b] = String.split(range, "-")
        String.to_integer(a)..String.to_integer(b)
      end)

    numbers =
      numbers_part
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)

    %{ranges: ranges, numbers: numbers}
  end
end
