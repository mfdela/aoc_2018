defmodule Aoc.Day02 do
  def part1(args) do
    args
    |> parse_input()
    |> frequency()
    |> checksum()
    |> then(fn {two, three} -> two * three end)
  end

  def part2(args) do
    args
    |> parse_input()
    |> find_similar_boxes()
    |> then(fn {box1, box2} ->
      Enum.zip(box1, box2)
      |> Enum.filter(fn {a, b} -> a == b end)
      |> Enum.map(&elem(&1, 0))
    end)
    |> Enum.join()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def frequency(boxes) do
    boxes
    |> Enum.map(&Enum.frequencies/1)
  end

  def checksum(frequencies) do
    frequencies
    |> Enum.reduce({0, 0}, fn freq, {twos, threes} ->
      values = Map.values(freq)

      {twos + if(Enum.member?(values, 2), do: 1, else: 0),
       threes + if(Enum.member?(values, 3), do: 1, else: 0)}
    end)
  end

  def find_similar_boxes(boxes) do
    boxes
    |> Enum.reduce_while({nil, nil}, fn box1, acc ->
      found =
        Enum.find(boxes, fn box2 ->
          count = Enum.zip(box1, box2) |> Enum.count(fn {a, b} -> a == b end)
          count == length(box1) - 1
        end)

      case found do
        nil -> {:cont, acc}
        _ -> {:halt, {box1, found}}
      end
    end)
  end
end
