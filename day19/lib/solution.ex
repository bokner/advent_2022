defmodule Day19.Solution do

  require Logger

  def read(input) do
    File.stream!(input)
    |> Enum.into([])
    |> Enum.map(fn bp_line ->
      parse_blueprint(bp_line)
    end)
  end

  def solve(input) do
    input
    |> read()
    |> solve_all()
    |> Enum.sum()
  end

  defp solve_all(blueprints) do
    blueprints
    |> Enum.map(fn bp -> String.to_integer(bp.blueprint_id) * solve_mzn(bp) end)
  end

  defp solve_mzn(blueprint) do
    {:ok, solution}  =
      MinizincSolver.solve_sync("model/day19.mzn", build_dzn(blueprint), solver: "chuffed")
    MinizincResults.get_last_solution(solution) |> MinizincResults.get_solution_objective()
      |> tap(fn result -> Logger.debug("Solution for #{blueprint.blueprint_id}: #{result}") end)
  end

  defp build_dzn(blueprint) do
    minerals = ["ore", "clay", "obsidian"]
    robots = ["ore", "clay", "obsidian", "geode"]
    %{blueprint: {["robots", "minerals"],
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
