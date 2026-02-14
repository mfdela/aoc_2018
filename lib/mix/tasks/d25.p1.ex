defmodule Elixir.Mix.Tasks.D25.P1 do
  use Mix.Task

  import Elixir.Aoc.Day25

  @shortdoc "Day 25 Part 1"
  def run(args) do
    input = Aoc.Input.get!(25, 2018)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
