## Advent of Code 2022, day 19 ##

### Solution method ###

The MiniZinc model (model/day19.mzn) solves the puzzle.
Elixir code parses puzzle input into the input for the model, then calls
the solver and handles the results. 

### How to run ###

Install MiniZinc (https://www.minizinc.org/software.html) 

```bash
cd day19
mix deps.get
iex -S mix
```

```elixir
iex(1)> Day19.Solution.solve_part1("data/day19.data")

iex(2)> Day19.Solution.solve_part2("data/day19.data")

```

