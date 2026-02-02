defmodule Aoc.Day01 do
  def part1(args) do
    args
    |> parse_input()
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input()
    |> Stream.cycle()
    |> Enum.reduce_while({0, MapSet.new([0])}, fn change, {freq, seen} ->
      new_freq = freq + change

      if MapSet.member?(seen, new_freq) do
        {:halt, new_freq}
      else
        {:cont, {new_freq, MapSet.put(seen, new_freq)}}
      end
    end)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
