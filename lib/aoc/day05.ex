defmodule Aoc.Day05 do
  def part1(args) do
    args
    |> parse_input()
    |> reduce_polymer()
    |> String.length()
  end

  def part2(args) do
    args
    |> parse_input()
    |> remove_all_units()
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.to_charlist()
  end

  def reduce_polymer(polymer) do
    {reduced_polymer, reduced?} =
      polymer
      |> Enum.reduce({[], false}, fn char, {stack, reduced} ->
        if Enum.empty?(stack) || abs(hd(stack) - char) != 32 do
          {[char | stack], reduced}
        else
          {Enum.drop(stack, 1), true}
        end
      end)
      |> then(fn {r, flag} -> {Enum.reverse(r), flag} end)

    case reduced? do
      false -> reduced_polymer |> List.to_string()
      true -> reduce_polymer(reduced_polymer)
    end
  end

  def remove_unit(polymer, unit) do
    polymer
    |> Enum.filter(fn char -> abs(char - unit) != 32 and char != unit end)
  end

  def remove_all_units(polymer) do
    polymer
    |> Enum.uniq()
    |> Enum.map(fn unit -> remove_unit(polymer, unit) end)
    |> Enum.map(&reduce_polymer/1)
    |> Enum.map(&String.length/1)
    |> Enum.min()
  end
end
