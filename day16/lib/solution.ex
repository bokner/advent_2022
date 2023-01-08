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
    {model, minutes, solver} =
      case part do
        :part1 -> {"model/valves.mzn", 30, "or_tools"}
        :part1_ext -> {"model/valves-ext.mzn", 30, "chuffed"}
        :part2 -> {"model/valves_part2.mzn", 26, "or-tools"}
      end


    dzn = build_dzn(valves, connections, rates)
    |> Map.put(:minutes, minutes)



    {:ok, solution} =
      MinizincSolver.solve_sync(
        model,
        dzn,
        solver: solver,
        time_limit: 60 * 60 * 1000
      )

    MinizincResults.get_last_solution(solution)
    |> MinizincResults.get_solution_objective()
    |> tap(fn result ->
      Logger.info("Solution: #{result}")
    end)
  end

  defp build_dzn(valves, connections, rates) do
    {updated_rates, updated_valves, updated_connections} = List.foldr(Enum.zip([rates, valves, connections]), {[], [], []},

    fn {0, valve, conns}, {rates_acc, valves_acc, conns_acc} -> {[0 | rates_acc], [valve | valves_acc], [conns | conns_acc]}
      {rate, valve, conns}, {rates_acc, valves_acc, conns_acc} ->
        new_rates = [0, rate | rates_acc]
        dummy_valve = valve<>"_closed"
        new_valves = [valve, dummy_valve | valves_acc]
        updated_connection = MapSet.put(conns, dummy_valve)
        new_connections = [updated_connection, conns |conns_acc]
        {new_rates, new_valves, new_connections}
    end)

    IO.inspect(Enum.zip(updated_rates, updated_valves) |> Enum.filter(fn {r, _} -> r == 0 end))

    %{
      valves: List.to_tuple(updated_valves),
      connections: {["valves"], updated_connections},
      rates: {["valves"], updated_rates}
    }
  end

end
