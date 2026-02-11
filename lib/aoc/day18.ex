defmodule Aoc.Day18 do
  def part1(args) do
    map = args
    |> parse_input()

    final_map = simulate(map, 10)
    count_tiles(final_map, "|") * count_tiles(final_map, "#")

  end

  def part2(args) do
    map = args
    |> parse_input()

    # Find the cycle
    {cycle_start, cycle_length} = find_cycle(map)

    # Calculate which iteration in the cycle corresponds to 1_000_000_000
    target = 1_000_000_000
    remaining = target - cycle_start
    position_in_cycle = rem(remaining, cycle_length)
    final_iteration = cycle_start + position_in_cycle

    # Simulate to that point
    final_map = simulate(map, final_iteration)

    count_tiles(final_map, "|") * count_tiles(final_map, "#")
  end

  def find_cycle(map) do
    find_cycle_helper(map, %{}, 0)
  end

  defp find_cycle_helper(map, seen, iteration) do
    map_hash = :erlang.phash2(map)

    if Map.has_key?(seen, map_hash) do
      cycle_start = seen[map_hash]
      cycle_length = iteration - cycle_start
      {cycle_start, cycle_length}
    else
      new_map = simulate_step(nil, map)
      find_cycle_helper(new_map, Map.put(seen, map_hash, iteration), iteration + 1)
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn row -> Enum.with_index(row) end)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} -> Enum.map(row, fn {char, x} -> {{x, y}, char} end) end)
    |> Enum.into(%{})
  end

  def count_tiles(map, tile) do
    map
    |> Enum.filter(fn {_, value} -> value == tile end)
    |> Enum.count()
  end

  def count_adjacent_tiles(map, {x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
    |> Enum.filter(fn {x, y} -> Map.has_key?(map, {x, y}) end)
    |> Enum.map(fn {x, y} -> Map.get(map, {x, y}) end)
    |> Enum.frequencies()
  end

  def simulate(map, steps) do
    Enum.reduce(1..steps, map, &simulate_step/2)
  end

  def simulate_step(_, map) do
    map
    |> Enum.map(fn {{x, y}, tile} ->
      adjacent_tiles = count_adjacent_tiles(map, {x, y})
      tree_count = Map.get(adjacent_tiles, "|", 0)
      lumberyard_count = Map.get(adjacent_tiles, "#", 0)

      case tile do
        "." when tree_count >= 3-> {{x, y}, "|"}
        "|" when lumberyard_count >= 3 -> {{x, y}, "#"}
        "#" when lumberyard_count >= 1 and tree_count >= 1 -> {{x, y}, "#"}
        "#" -> {{x, y}, "."}
        _ -> {{x, y}, tile}
      end
    end)
    |> Enum.into(%{})
  end



end
