defmodule Advent2025.Day09 do
  use Advent, day: 9, input: Advent2025.Day09.Parser

  # 𝑶𝑯 𝑫𝑬𝑨𝑹
  def part_1 do
    input()
    |> pairs()
    |> Enum.map(&rectangle_area/1)
    |> Enum.max()
  end

  def part_2 do
    red_tiles = input()
    edges = build_edges(red_tiles)

    red_tiles
    |> pairs()
    |> Enum.filter(&rectangle_valid?(&1, edges))
    |> Enum.map(&rectangle_area/1)
    |> Enum.max()
  end

  defp rectangle_valid?({{x1, y1}, {x2, y2}}, edges) do
    {min_x, max_x} = {min(x1, x2), max(x1, x2)}
    {min_y, max_y} = {min(y1, y2), max(y1, y2)}

    corners_inside_or_on_boundary =
      Enum.all?([{x1, y1}, {x1, y2}, {x2, y1}, {x2, y2}], fn {x, y} ->
        inside_or_on_boundary?(x, y, edges)
      end)

    no_edge_crosses_interior =
      not Enum.any?(edges, &edge_crosses_interior?(&1, min_x, max_x, min_y, max_y))

    center_inside = point_inside_polygon?((min_x + max_x) / 2, (min_y + max_y) / 2, edges)

    corners_inside_or_on_boundary and no_edge_crosses_interior and center_inside
  end

  defp edge_crosses_interior?({:v, x, y_min, y_max}, min_x, max_x, min_y, max_y) do
    min_x < x and x < max_x and max(y_min, min_y) < min(y_max, max_y)
  end

  defp edge_crosses_interior?({:h, y, x_min, x_max}, min_x, max_x, min_y, max_y) do
    min_y < y and y < max_y and max(x_min, min_x) < min(x_max, max_x)
  end

  defp point_inside_polygon?(px, py, edges) do
    crossings =
      Enum.count(edges, fn
        {:v, x, y_min, y_max} -> x > px and y_min <= py and py < y_max
        {:h, _, _, _} -> false
      end)

    rem(crossings, 2) == 1
  end

  defp build_edges(red_tiles) do
    red_tiles
    |> Stream.concat([hd(red_tiles)])
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.map(fn [{x1, y1}, {x2, y2}] ->
      if x1 == x2 do
        {:v, x1, min(y1, y2), max(y1, y2)}
      else
        {:h, y1, min(x1, x2), max(x1, x2)}
      end
    end)
  end

  defp on_boundary?(x, y, edges) do
    Enum.any?(edges, fn
      {:v, ex, y_min, y_max} -> ex == x and y_min <= y and y <= y_max
      {:h, ey, x_min, x_max} -> ey == y and x_min <= x and x <= x_max
    end)
  end

  defp inside_or_on_boundary?(x, y, edges) do
    on_boundary?(x, y, edges) or point_inside_polygon?(x, y, edges)
  end

  defp pairs(tiles) do
    for {a, i} <- Enum.with_index(tiles),
        {b, j} <- Enum.with_index(tiles),
        i < j do
      {a, b}
    end
  end

  defp rectangle_area({{x1, y1}, {x2, y2}}) do
    (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
  end
end

defmodule Advent2025.Day09.Parser do
  def parse!(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y] = line |> String.split(",") |> Enum.map(&String.to_integer/1)
      {x, y}
    end)
  end
end
