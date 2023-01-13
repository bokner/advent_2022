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
    {model, minutes, team_size, solver} =
      case part do
        :part1 -> {"model/valves-ext-team.mzn", 30, 1, "chuffed"}
        :part2 -> {"model/valves-ext-team.mzn", 26, 2, "chuffed"}
      end


    dzn = build_dzn(valves, connections, rates, minutes, team_size)




    {:ok, solution} =
      MinizincSolver.solve_sync(
        model,
        dzn,
        solver: solver,
        time_limit: 60 * 60 * 1000,
        solution_handler: Day16.MinizincHandler
      )

    MinizincResults.get_last_solution(solution)
    |> MinizincResults.get_solution_objective()
    |> tap(fn result ->
      Logger.info("Solution: #{result}")
    end)
  end

  defp build_dzn(valves, connections, rates, minutes, team_size) do
    {updated_rates, updated_valves, updated_connections} = List.foldr(Enum.zip([rates, valves, connections]), {[], [], []},

    fn {0, valve, conns}, {rates_acc, valves_acc, conns_acc} -> {[0 | rates_acc], [valve | valves_acc], [conns | conns_acc]}
      {rate, valve, conns}, {rates_acc, valves_acc, conns_acc} ->
        new_rates = [0, rate | rates_acc]
        dummy_valve = valve<>"_x"
        new_valves = [valve, dummy_valve | valves_acc]
        updated_connection = MapSet.put(conns, dummy_valve)
        new_connections = [updated_connection, conns |conns_acc]
        {new_rates, new_valves, new_connections}
    end)

    %{
      upper_bound: upper_bound(minutes, rates),
      minutes: minutes,
      team: 1..team_size |> Enum.map(fn i -> "t_#{i}" end) |> List.to_tuple(),
      valves: List.to_tuple(updated_valves),
      connections: {["valves"], updated_connections},
      rates: {["valves"], updated_rates}
    }
  end

  defp upper_bound(minutes, rates) do
    rates
    |> Enum.sort(:desc)
    |> Enum.with_index(1)
    |> Enum.take(minutes)
    |> Enum.map(fn {r, idx} -> r * (minutes - idx) end)
    |> Enum.sum
  end
end

defmodule Day16.MinizincHandler do
  @moduledoc false

  require Logger

  alias MinizincHandler.Default, as: DefaultHandler
  use MinizincHandler

  @doc false
  def handle_solution(solution = %{index: _count, data: _data}) do
    Logger.info("Objective: #{MinizincResults.get_solution_objective(solution)}")

    DefaultHandler.handle_solution(solution)
  end

  @doc false
  def handle_summary(summary) do
    last_solution = MinizincResults.get_last_solution(summary)

    Logger.debug(
      "MZN final status (#{summary.solver}): #{summary.status}, objective: #{MinizincResults.get_solution_objective(last_solution)}"
    )
    summary &&
    (
      Logger.debug("Time elapsed: #{summary.time_elapsed}")
    )
    DefaultHandler.handle_summary(summary)
  end

  @doc false
  def handle_minizinc_error(error) do
    Logger.debug("Minizinc error: #{inspect(error)}")
    DefaultHandler.handle_minizinc_error(error)
  end
end
