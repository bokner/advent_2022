defmodule Day19.Solution do
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
    :ok
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
      Map.put(acc, robot, %{mineral => cost})
      |> Map.put(:current_robot, robot)
    )
  end

  defp parse_description(["and", cost, mineral | rest], acc) do
    current_robot = Map.get(acc, :current_robot, :not_found)

    {_, new_acc} =
      Map.get_and_update(acc, current_robot, fn current ->
        {current, Map.put(current, mineral, cost)}
      end)

    parse_description(rest, new_acc)
  end
end
