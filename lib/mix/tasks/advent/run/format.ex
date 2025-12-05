defmodule Mix.Tasks.Advent.Run.Format do
  import IO.ANSI, only: [bright: 0, cyan: 0, faint: 0, reset: 0, white: 0, yellow: 0]
  import String, only: [pad_leading: 3, pad_trailing: 2]

  def print(results) do
    widths = column_widths(results)

    IO.puts(title())
    IO.puts(table_header(widths))
    Enum.each(results, &print_row(&1, widths))
    IO.puts("")
  end

  def pad(n), do: pad_leading("#{n}", 2, "0")

  defp title do
    [
      bright(),
      cyan(),
      "\n  ❈ Advent of Code 2025 ❈ \n",
      reset()
    ]
  end

  defp table_header({w1, w2}) do
    [
      faint(),
      "  Day   ",
      pad_trailing("Part 1", w1),
      "   ",
      pad_trailing("Part 2", w2),
      reset()
    ]
  end

  defp print_row({day, parts}, {w1, w2}) do
    part_1 = find_part(parts, 1)
    part_2 = find_part(parts, 2)

    IO.puts([
      yellow(),
      "   #{pad(day)}   ",
      reset(),
      bright(),
      white(),
      String.pad_trailing(part_1, w1),
      reset(),
      "   ",
      bright(),
      white(),
      String.pad_trailing(part_2, w2),
      reset()
    ])
  end

  defp find_part(parts, n) do
    case Enum.find(parts, fn {_, part, _} -> part == n end) do
      {_, _, result} -> "#{result}"
      nil -> ""
    end
  end

  defp column_widths(results) do
    all_parts = Enum.flat_map(results, fn {_, parts} -> parts end)

    w1 = max_width(all_parts, 1, 6)
    w2 = max_width(all_parts, 2, 6)

    {w1, w2}
  end

  defp max_width(parts, n, min) do
    parts
    |> Enum.filter(fn {_, part, _} -> part == n end)
    |> Enum.map(fn {_, _, result} -> String.length("#{result}") end)
    |> Enum.max(fn -> 0 end)
    |> max(min)
  end
end
