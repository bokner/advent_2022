defmodule Day16.Solution do
  require Logger

  def read(input) do
    File.stream!(input)
    |> Enum.into([])
    |> Enum.map(fn line ->
      parse_valve(line)
    end)
    |> valve_data()
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

  defp valve_data(data) do
    data
    |> Enum.sort_by(& &1.valve)
    |> List.foldr({[], [], []}, fn rec, {valves, connections, rates} ->
      {[rec.valve | valves], [rec.connected_to | connections], [rec.rate | rates]}
    end)
  end

  def solve(input, minutes \\ 30) do
    read(input)
    |> solve_mzn(minutes)
  end

  defp solve_mzn({valves, connections, rates} = _data, minutes) do
    dzn = %{
      minutes: minutes,
      valves: List.to_tuple(valves),
      connections: {["valves"], connections},
      rates: {["valves"], rates}
    }
    {:ok, solution} =
      MinizincSolver.solve_sync(
        "model/valves.mzn",
        dzn,
        solver: "or-tools"
      )

    MinizincResults.get_last_solution(solution)
    |> MinizincResults.get_solution_objective()
    |> tap(fn result ->
      Logger.info("Solution: #{result}")
    end)
  end

end
