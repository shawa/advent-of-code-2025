defmodule Mix.Tasks.Advent.Run do
  use Mix.Task

  @days 1..12

  def run(_) do
    Mix.Task.run("compile")

    @days
    |> Enum.map(&day_module/1)
    |> Enum.filter(&Code.ensure_loaded?(elem(&1, 1)))
    |> Enum.flat_map(&tasks_for_day/1)
    |> Task.await_many(:infinity)
    |> Enum.sort()
    |> Enum.each(fn {day, part, result} ->
      IO.puts("#{pad(day)}, #{part}: #{result}")
    end)
  end

  defp day_module(day), do: {day, Module.concat([Advent2025, :"Day#{pad(day)}"])}

  defp pad(n), do: String.pad_leading("#{n}", 2, "0")

  defp tasks_for_day({day, module}) do
    for part <- 1..2, function_exported?(module, :"part_#{part}", 0) do
      Task.async(fn -> {day, part, apply(module, :"part_#{part}", [])} end)
    end
  end
end
