## Advent of Code 2022, day 19 ##

### Solution method ###


The MiniZinc model (model/shortest_path/valves_shortest_path.mzn) solves the puzzle.
Elixir code parses puzzle input into the input for the model, pre-builds shortest paths in a graph with AA and valves with positive rates,
then runs the MiniZinc model and handles the results. 

### How to run ###

Install MiniZinc (https://www.minizinc.org/software.html) 

```bash
cd day16
mix deps.get
iex -S mix
```

```elixir
## Runtime for part 1: less than 1 sec
iex(1)> Day16.Solution.solve("data/day19.data", :part1)

## Runtime for part 2: less than 7 sec
iex(2)> Day19.Solution.solve("data/day19.data", :part2)

```

