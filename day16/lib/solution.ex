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
    |> String.split(
      [
        "Valve ",
        " has flow rate=",
        " tunnels lead ",
        " tunnel leads ",
        "to valves ",
        "to valve ",
        ";"
      ],
      trim: true
    )
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

  def solve(input, part \\ :part1) do
    read(input)
    |> solve_mzn(part)
  end

  defp solve_mzn({valves, connections, rates} = _data, part) do
    {model, minutes} =
      case part do
        :part1 -> {"model/valves.mzn", 30}
        :part2 -> {"model/valves_part2.mzn", 26}
      end

    dzn = %{
      minutes: minutes,
      valves: List.to_tuple(valves),
      connections: {["valves"], connections},
      rates: {["valves"], rates}
    }

    {:ok, solution} =
      MinizincSolver.solve_sync(
        model,
        dzn,
        solver: "or-tools",
        time_limit: 60 * 60 * 1000
      )

    MinizincResults.get_last_solution(solution)
    |> MinizincResults.get_solution_objective()
    |> tap(fn result ->
      Logger.info("Solution: #{result}")
    end)
  end
end
