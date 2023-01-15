defmodule Day16.ShortestPath do
  import Day16.Solution

  def build_graph(input) when is_binary(input) do
    read(input)
    |> build_dzn(:part1)
    |> Map.get(:dzn)
    |> then(fn dzn ->
      build_graph(dzn)
      |> build_distance_matrix()
      |> then(fn d ->
        Map.put(dzn, :distance, {["valves", "valves"], d})
        |> truncate_rates()
      end)
    end)
    |> Map.take([:distance, :rates, :minutes, :valves])
  end

  def build_graph(dzn) do
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
    |> Enum.filter(fn {_, "AA"} -> true
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
        if v1 == v2 do
          0
        else
          length(Graph.get_shortest_path(graph, v1, v2)) - 1
        end

      #{v1, v2, path_length}
      path_length
    end
  end
  end

  defp build_distance_matrix(distances) do
    distances
  end
end
