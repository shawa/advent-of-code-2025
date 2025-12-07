defmodule Mix.Tasks.Advent.Benchmark do
  use Mix.Task

  @shortdoc "Benchmark Advent of Code solutions"

  @days 1..25
  @warmup_runs 3
  @benchmark_runs 10

  def run(args) do
    Mix.Task.run("compile")

    detailed = "--detailed" in args

    results =
      @days
      |> Enum.map(&day_module/1)
      |> Enum.filter(&Code.ensure_loaded?(elem(&1, 1)))
      |> Enum.map(&benchmark_day/1)

    if detailed do
      print_detailed(results)
    else
      print_summary(results)
    end
  end

  defp print_summary(results) do
    IO.puts(title())
    IO.puts(header())
    IO.puts(separator())
    Enum.each(results, &print_row/1)
    IO.puts(separator())
    IO.puts("")
  end

  defp print_detailed(results) do
    IO.puts(title())
    Enum.each(results, &print_detailed_day/1)
    IO.puts("")
  end

  defp day_module(day), do: {day, Module.concat([Advent2025, :"Day#{pad(day)}"])}

  defp benchmark_day({day, module}) do
    part_1 = benchmark_part(module, :part_1)
    part_2 = benchmark_part(module, :part_2)
    {day, part_1, part_2}
  end

  defp benchmark_part(module, function) do
    if function_exported?(module, function, 0) do
      warmup(module, function)
      times = collect_samples(module, function)
      calculate_stats(times)
    else
      nil
    end
  end

  defp warmup(module, function) do
    for _ <- 1..@warmup_runs do
      :erlang.garbage_collect()
      apply(module, function, [])
    end
  end

  defp collect_samples(module, function) do
    for _ <- 1..@benchmark_runs do
      :erlang.garbage_collect()
      {time, _result} = :timer.tc(module, function, [])
      time
    end
  end

  defp calculate_stats(times) do
    sorted = Enum.sort(times)
    count = length(sorted)

    min = List.first(sorted)
    max = List.last(sorted)
    sum = Enum.sum(sorted)
    mean = sum / count

    median =
      if rem(count, 2) == 0 do
        mid = div(count, 2)
        (Enum.at(sorted, mid - 1) + Enum.at(sorted, mid)) / 2
      else
        Enum.at(sorted, div(count, 2))
      end

    variance = Enum.sum(Enum.map(sorted, fn t -> (t - mean) * (t - mean) end)) / count
    std_dev = :math.sqrt(variance)

    p99_index = min(round(count * 0.99), count - 1)
    p99 = Enum.at(sorted, p99_index)

    %{
      min: min,
      max: max,
      mean: mean,
      median: median,
      std_dev: std_dev,
      p99: p99
    }
  end

  defp title do
    import IO.ANSI

    [
      "\n",
      bright(),
      cyan(),
      "  * Advent of Code 2025 - Benchmark *\n",
      reset(),
      faint(),
      "  #{@warmup_runs} warmup runs, #{@benchmark_runs} benchmark runs\n",
      reset()
    ]
  end

  defp header do
    import IO.ANSI

    [
      "\n",
      faint(),
      "  Day  |            Part 1             |            Part 2             ",
      reset(),
      "\n",
      faint(),
      "       |   mean       p99      std dev |   mean       p99      std dev ",
      reset()
    ]
  end

  defp separator do
    import IO.ANSI
    [faint(), "  -----+-------------------------------+-------------------------------", reset()]
  end

  defp print_row({day, part_1, part_2}) do
    import IO.ANSI

    IO.puts([
      yellow(),
      "    #{pad(day)}",
      reset(),
      faint(),
      " |",
      reset(),
      format_stats(part_1),
      faint(),
      " |",
      reset(),
      format_stats(part_2)
    ])
  end

  defp print_detailed_day({day, part_1, part_2}) do
    import IO.ANSI
    IO.puts(["\n", bright(), yellow(), "  Day #{pad(day)}", reset()])
    IO.puts([faint(), "  ", String.duplicate("-", 50), reset()])
    print_detailed_part("Part 1", part_1)
    print_detailed_part("Part 2", part_2)
  end

  defp print_detailed_part(label, nil) do
    import IO.ANSI
    IO.puts([faint(), "  #{label}: not implemented", reset()])
  end

  defp print_detailed_part(label, stats) do
    import IO.ANSI
    IO.puts([bright(), "  #{label}:", reset()])
    IO.puts(["    min:     ", format_time_padded(stats.min)])
    IO.puts(["    max:     ", format_time_padded(stats.max)])
    IO.puts([bright(), "    mean:    ", format_time_padded(stats.mean), reset()])
    IO.puts(["    median:  ", format_time_padded(stats.median)])
    IO.puts(["    std dev: ", format_time_padded(stats.std_dev)])
    IO.puts(["    p99:     ", format_time_padded(stats.p99)])
  end

  defp format_stats(nil), do: String.duplicate(" ", 31)

  defp format_stats(stats) do
    import IO.ANSI

    [
      " ",
      bright(),
      white(),
      String.pad_leading(format_time(stats.mean), 8),
      reset(),
      "  ",
      String.pad_leading(format_time(stats.p99), 8),
      "  ",
      faint(),
      String.pad_leading(format_time(stats.std_dev), 8),
      reset()
    ]
  end

  defp format_time(us) when us < 1000, do: "#{Float.round(us * 1.0, 1)} us"
  defp format_time(us) when us < 1_000_000, do: "#{Float.round(us / 1000, 2)} ms"
  defp format_time(us), do: "#{Float.round(us / 1_000_000, 2)} s"

  defp format_time_padded(us), do: String.pad_leading(format_time(us), 12)

  defp pad(n), do: String.pad_leading("#{n}", 2, "0")
end
