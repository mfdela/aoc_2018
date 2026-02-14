defmodule Elixir.Mix.Tasks.D25.P2 do
  use Mix.Task

  import Elixir.Aoc.Day25

  @shortdoc "Day 25 Part 2"
  def run(args) do
    input = Aoc.Input.get!(25, 2018)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
