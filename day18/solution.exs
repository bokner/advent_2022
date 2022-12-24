defmodule Day18.Solution do
def connected(cube1, cube2) do
  [x1, y1, z1] = cube1
  [x2, y2, z2] = cube2
  abs(x1-x2) + abs(y1-y2) + abs(z1-z2) == 1
end

def read(input) do
  input
  |> File.stream!()
  |> Stream.map(fn line ->
    line
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn str -> String.to_integer(str) end) end)
    |> Enum.into([])
end

 def count_sides(cubes) do
   length(cubes) * 6 - 2 * count_connections(cubes, 0)
 end

 def count_connections([], connections) do
   connections
 end
 def count_connections(cubes, connections) do
   [cube | rest] = cubes
   new_connections = Enum.reduce(rest, connections,
    fn other_cube, acc -> connected(cube, other_cube) && acc + 1 || acc end
   )
   count_connections(rest, new_connections)
 end

 def solve(input) do
   input
   |> read()
   |> count_sides()
 end

end
