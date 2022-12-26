defmodule Day19.Solution do
  require Logger

  def read(input) do
    File.stream!(input)
    |> Enum.into([])
    |> Enum.map(fn bp_line ->
      parse_blueprint(bp_line)
    end)
  end

  def solve_part1(input) do
    input
    |> read()
    |> solve(24, 30)
    |> Enum.reduce({0, 1}, fn sol, {sum, idx} = _acc -> {sum + sol * idx, idx + 1} end)
    |> then(fn {answer, _} -> answer end)
  end

  def solve_part2(input) do
    input
    |> read()
    |> solve(32, 3)
    |> Enum.product()
  end

  defp solve(blueprints, minutes, how_many) do
    blueprints
    |> Enum.take(how_many)
    |> Enum.map(fn bp ->
      solve_mzn(bp, minutes)
    end)
  end

  defp solve_mzn(blueprint, minutes) do
    {:ok, solution} =
      MinizincSolver.solve_sync(
        "model/day19.mzn",
        build_dzn(blueprint, minutes),
        solver: "chuffed"
      )

    MinizincResults.get_last_solution(solution)
    |> MinizincResults.get_solution_objective()
    |> tap(fn result ->
      Logger.info("Solution for #{blueprint.blueprint_id}: #{result}")
    end)
  end

  defp build_dzn(blueprint, minutes) do
    minerals = ["ore", "clay", "obsidian"]
    robots = ["ore", "clay", "obsidian", "geode"]

    %{
      minutes: minutes,
      blueprint:
        {["robots", "minerals"],
         for r <- robots do
           for m <- minerals do
             Map.get(blueprint, r) |> Map.get(m, 0)
           end
         end}
    }
  end

  defp parse_blueprint(blueprint) do
    blueprint
    |> String.trim()
    |> String.split(["Blueprint", ":", "Each", ".", "costs", " "], trim: true)
    |> then(fn [blueprint_id | description] ->
      parse_description(description)
      |> Map.put(:blueprint_id, blueprint_id)
    end)
  end

  defp parse_description(description) do
    parse_description(description, %{})
  end

  defp parse_description([], acc) do
    Map.delete(acc, :current_robot)
  end

  defp parse_description([robot, "robot", cost, mineral | rest], acc) do
    parse_description(
      rest,
      Map.put(acc, robot, %{mineral => String.to_integer(cost)})
      |> Map.put(:current_robot, robot)
    )
  end

  defp parse_description(["and", cost, mineral | rest], acc) do
    current_robot = Map.get(acc, :current_robot, :not_found)

    {_, new_acc} =
      Map.get_and_update(acc, current_robot, fn current ->
        {current, Map.put(current, mineral, String.to_integer(cost))}
      end)

    parse_description(rest, new_acc)
  end
end
