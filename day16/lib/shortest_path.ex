defmodule Day16.Solution do
  import Day16.First.Solution

  require Logger

  def solve(input, part) do
    read(input)
    |> build_dzn(part)
    |> build_graph()
    |> finish_dzn(part)
    |> solve_mzn(part)
  end

  defp solve_mzn(model_data, part) do
    model_params = get_model_params(part)

    {:ok, solution} =
      MinizincSolver.solve_sync(
        model_params.model,
        model_data,
        solver: model_params.solver,
        time_limit: 15 * 60 * 1000,
        solution_handler: Day16.MinizincHandler
      )

    MinizincResults.get_last_solution(solution)
    |> MinizincResults.get_solution_objective()
    |> tap(fn result ->
      Logger.info("Solution: #{result}")
    end)
  end

  def build_graph(data) when is_map(data) do
    data
    |> Map.get(:dzn)
    |> then(fn dzn ->
      build_shortest_paths(dzn)
      |> then(fn d ->
        Map.put(dzn, :distance, {["valves", "valves"], d})
        |> truncate_rates()
      end)
    end)
  end

  def finish_dzn(data, part) do
    data
    |> Map.take([:distance, :rates, :minutes, :valves, :upper_bound])
    |> Map.put(:team, part == :part1 && 1 || 2)
  end

  def build_shortest_paths(dzn) do
    vertices = Tuple.to_list(dzn.valves)
    {_label, rates} = dzn.rates
    {_label, connections} = dzn.connections

    Enum.reduce(
      Enum.zip([vertices, connections, rates]),
      Graph.new(),
      fn {vertex, connections, rate}, acc ->
        Enum.reduce(connections, acc, fn c, acc2 ->
          Graph.add_edge(acc2, vertex, c)
          |> Graph.label_vertex(vertex, [rate])
        end)
      end
    )
    |> then(fn graph ->
      vertices = filter_positive_rates(graph)
      get_shortest_paths(graph, vertices)
    end)
  end

  defp filter_positive_rates(graph) do
    graph
    |> Graph.vertices()
    |> Enum.filter(fn
      v -> hd(Graph.vertex_labels(graph, v)) > 0
    end)
  end

  defp truncate_rates(dzn) do
    {rates_label, rates} = Map.get(dzn, :rates)

    {truncated_rates, truncated_valves} =
      Enum.zip(rates, Tuple.to_list(Map.get(dzn, :valves)))
      |> Enum.filter(fn
        {_, "AA"} -> true
        {rate, _valve} -> rate > 0
      end)
      |> Enum.unzip()

    Map.put(dzn, :rates, {rates_label, truncated_rates})
    |> Map.put(:valves, List.to_tuple(truncated_valves))
  end

  defp get_shortest_paths(graph, vertices) do
    vertices = ["AA" | vertices]

    for v1 <- Enum.sort(vertices) do
      for v2 <- Enum.sort(vertices) do
        path_length =
          cond do
            v1 == v2 -> 0
            v2 == "AA" -> 0
            true -> length(Graph.get_shortest_path(graph, v1, v2)) - 1
          end

        # {v1, v2, path_length}
        path_length
      end
    end
  end

  defp get_model_params(_part) do
    %{solver: "chuffed", model: "model/shortest_path/valves_shortest_path.mzn"}
  end
end
