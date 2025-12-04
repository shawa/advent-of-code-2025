defmodule Advent2025.Day01 do
  use Advent, day: 1, input: :lines

  def part_1, do: walk(&lands_on_zero/2)
  def part_2, do: walk(&crosses_zero/2)

  defp walk(count) do
    input()
    |> Enum.reduce({50, 0}, fn move, {pos, total} ->
      delta = parse(move)
      {wrap(pos + delta), total + count.(pos, delta)}
    end)
    |> elem(1)
  end

  defp parse(<<"R", n::binary>>), do: String.to_integer(n)
  defp parse(<<"L", n::binary>>), do: -String.to_integer(n)

  defp wrap(n), do: Integer.mod(n, 100)

  defp lands_on_zero(pos, delta), do: if(wrap(pos + delta) == 0, do: 1, else: 0)

  defp crosses_zero(pos, delta) when delta > 0, do: zero_crossings(100 - pos, delta)
  defp crosses_zero(pos, delta) when delta < 0, do: zero_crossings(pos, -delta)
  defp crosses_zero(_, 0), do: 0

  defp zero_crossings(dist_to_zero, dist_traveled) when dist_to_zero == 0,
    do: zero_crossings(100, dist_traveled)

  defp zero_crossings(dist_to_zero, dist_traveled) when dist_to_zero > dist_traveled, do: 0
  defp zero_crossings(dist_to_zero, dist_traveled), do: 1 + div(dist_traveled - dist_to_zero, 100)
end
