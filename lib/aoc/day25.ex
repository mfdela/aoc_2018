defmodule Aoc.Day25 do
  def part1(args) do
    args
    |> parse_input()
    |> find_constellations()
    |> Enum.count()
  end

  def part2(args) do
    args
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> Enum.map(fn [x, y, z, t] ->
      {String.to_integer(x), String.to_integer(y), String.to_integer(z), String.to_integer(t)}
    end)
  end

  def find_constellations(points) do
    Enum.reduce(points, MapSet.new(), fn point, constellations ->
      # Find all constellations that this point is close to
      {matching, non_matching} =
        Enum.split_with(constellations, fn constellation ->
          Enum.any?(constellation, &(distance(point, &1) <= 3))
        end)

      # Merge all matching constellations and add the new point
      merged =
        matching
        |> Enum.reduce(MapSet.new([point]), fn constellation, acc ->
          MapSet.union(acc, constellation)
        end)

      # Add the merged constellation to non-matching ones
      non_matching
      |> MapSet.new()
      |> MapSet.put(merged)
    end)
  end

  def distance({x1, y1, z1, t1}, {x2, y2, z2, t2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2) + abs(t1 - t2)
  end
end
