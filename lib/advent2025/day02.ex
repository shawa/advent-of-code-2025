defmodule Advent2025.Day02 do
  use Advent, day: 2, input: :binary

  import Integer, only: [pow: 2]

  def part_1, do: solve(&repunits(&1, exactly: 2))
  def part_2, do: solve(&repunits(&1, at_least: 2))

  defp solve(finder) do
    input()
    |> parse_ranges()
    |> Enum.flat_map(finder)
    |> Enum.sum()
  end

  defp parse_ranges(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn range ->
      [a, b] = String.split(range, "-")
      String.to_integer(a)..String.to_integer(b)
    end)
  end

  defp repunits(%{first: a, last: b}, opts) do
    max_digits = length(Integer.digits(b))
    {min_n, max_n} = n_bounds(opts, max_digits)

    # :) it's like a list monad
    for k <- 1..div(max_digits, 2),
        n <- min_n..min(max_n, div(max_digits, k)),
        multiplier = multiplier(k, n),
        base <- base_range(k),
        result = base * multiplier,
        result >= a and result <= b do
      result
    end
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp n_bounds([exactly: n], _max), do: {n, n}
  defp n_bounds([at_least: n], max), do: {n, max}

  defp multiplier(k, n) do
    div(pow(10, k * n) - 1, pow(10, k) - 1)
  end

  defp base_range(k), do: max(1, pow(10, k - 1))..(pow(10, k) - 1)
end
