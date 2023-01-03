defmodule Day16.Solution do
  require Logger

  def read(input) do
    File.stream!(input)
    |> Enum.into([])
    |> Enum.map(fn line ->
      parse_valve(line)
    end)
    |> make_dzn()
  end

  defp parse_valve(line) do
    # Example: Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    line
    |> String.trim()
    |> String.split(["Valve ", " has flow rate=", " tunnels lead ", " tunnel leads ", "to valves ", "to valve ", ";"], trim: true)
    |> then(fn [valve, rate, tunnels] ->
      %{
        valve: valve,
        rate: String.to_integer(rate),
        connected_to: MapSet.new(String.split(tunnels, [",", " "], trim: true))
      }
    end)
  end

  defp make_dzn(data) do
    data
    |> Enum.sort_by(& &1.valve)
    |> List.foldr({[], [], []}, fn rec, {valves, connections, rates} ->
      {[rec.valve | valves], [rec.connected_to | connections], [rec.rate | rates]}
    end)
  end

end
