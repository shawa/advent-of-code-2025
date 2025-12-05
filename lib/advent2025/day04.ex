defmodule Advent2025.Day04 do
  use Advent, day: 4, input: {Nx.Tensor, remap: %{?@ => 1, ?. => 0}}

  import Nx
  import Nx.Defn

  def part_1, do: input() |> accessible() |> sum() |> to_number()

  def part_2 do
    grid = input()
    final = y(grid, &remove_accessible/1)
    subtract(grid, final) |> sum() |> to_number()
  end

  defn remove_accessible(grid) do
    grid - accessible(grid)
  end

  defn accessible(grid) do
    neighbours(grid) < 4 and grid
  end

  @kernel [
    [1, 1, 1],
    [1, 0, 1],
    [1, 1, 1]
  ]
  defn neighbours(grid) do
    {h, w} = shape(grid)
    kernel = tensor(@kernel) |> reshape({1, 1, 3, 3})
    grid |> reshape({1, 1, h, w}) |> conv(kernel, padding: :same) |> squeeze()
  end

  # the dreaded orange (fixpoint) combinator
  # run f repeatedly until it's idempotent
  defp y(tensor, f) do
    next = f.(tensor)

    if equal(tensor, next) |> all() |> to_number() == 1 do
      tensor
    else
      y(next, f)
    end
  end
end
