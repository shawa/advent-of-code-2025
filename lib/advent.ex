defmodule Advent do
  defmacro __using__(opts) do
    day = Keyword.fetch!(opts, :day)
    input_mode = Keyword.fetch!(opts, :input)

    quote do
      def input, do: Advent.fetch_input!(unquote(day), unquote(input_mode))
    end
  end

  def fetch_input!(day, :binary) do
    day_str = String.pad_leading("#{day}", 2, "0")
    File.read!("priv/input/#{day_str}.txt")
  end

  def fetch_input!(day, :lines) do
    day
    |> fetch_input!(:binary)
    |> String.trim()
    |> String.split("\n")
  end

  def fetch_input!(day, module) when is_atom(module) do
    day |> fetch_input!(:binary) |> module.parse!()
  end

  def fetch_input!(day, {Nx.Tensor, opts}) do
    type = Keyword.get(opts, :type, :u8)
    mapping = Keyword.get(opts, :remap, nil)

    day
    |> fetch_input!(:lines)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
      |> Enum.map(fn
        c when is_map(mapping) -> Map.fetch!(mapping, c)
        c -> c
      end)
    end)
    |> Nx.tensor(type: type, backend: EMLX.Backend)
  end
end
