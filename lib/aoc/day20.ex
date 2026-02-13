defmodule Aoc.Day20 do
  def part1(input) do
    regex = String.trim(input)
    doors = build_door_map(regex)
    print_map_dimensions(doors)
    find_furthest_room(doors)
  end

  def part2(input) do
    regex = String.trim(input)
    doors = build_door_map(regex)
    print_map_dimensions(doors)
    count_rooms_at_least(doors, 1000)
  end

  def map_dimensions(input) do
    regex = String.trim(input)
    doors = build_door_map(regex)

    # Get all unique rooms from the doors
    rooms =
      doors
      |> Enum.flat_map(fn {from, to} -> [from, to] end)
      |> MapSet.new()

    {min_x, max_x} = rooms |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = rooms |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()

    width = max_x - min_x + 1
    height = max_y - min_y + 1
    total_rooms = MapSet.size(rooms)
    total_doors = MapSet.size(doors)

    IO.puts("Map dimensions:")
    IO.puts("  Width: #{width} (x: #{min_x} to #{max_x})")
    IO.puts("  Height: #{height} (y: #{min_y} to #{max_y})")
    IO.puts("  Total rooms: #{total_rooms}")
    IO.puts("  Total doors: #{total_doors}")

    {width, height, total_rooms, total_doors}
  end

  def build_door_map(regex) do
    # Remove ^ and $
    regex = regex |> String.slice(1..-2//1)

    # Parse the regex and build a map of all doors
    {doors, _} = parse(regex, {0, 0}, MapSet.new(), [])
    doors
  end

  def print_map_dimensions(doors) do
    # Get all unique rooms from the doors
    rooms =
      doors
      |> Enum.flat_map(fn {from, to} -> [from, to] end)
      |> MapSet.new()

    {min_x, max_x} = rooms |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = rooms |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()

    width = max_x - min_x + 1
    height = max_y - min_y + 1
    total_rooms = MapSet.size(rooms)
    total_doors = MapSet.size(doors)

    IO.puts("Map dimensions:")
    IO.puts("  Width: #{width} (x: #{min_x} to #{max_x})")
    IO.puts("  Height: #{height} (y: #{min_y} to #{max_y})")
    IO.puts("  Total rooms: #{total_rooms}")
    IO.puts("  Total doors: #{total_doors}")
  end

  def parse(regex, pos, doors, stack) do
    parse_chars(String.graphemes(regex), pos, doors, stack)
  end

  def parse_chars([], pos, doors, _stack) do
    {doors, pos}
  end

  def parse_chars([char | rest], pos, doors, stack) do
    case char do
      "N" ->
        {x, y} = pos
        new_pos = {x, y - 1}
        new_doors = MapSet.put(doors, {pos, new_pos})
        parse_chars(rest, new_pos, new_doors, stack)

      "S" ->
        {x, y} = pos
        new_pos = {x, y + 1}
        new_doors = MapSet.put(doors, {pos, new_pos})
        parse_chars(rest, new_pos, new_doors, stack)

      "E" ->
        {x, y} = pos
        new_pos = {x + 1, y}
        new_doors = MapSet.put(doors, {pos, new_pos})
        parse_chars(rest, new_pos, new_doors, stack)

      "W" ->
        {x, y} = pos
        new_pos = {x - 1, y}
        new_doors = MapSet.put(doors, {pos, new_pos})
        parse_chars(rest, new_pos, new_doors, stack)

      "(" ->
        # Start of branch - save current position
        parse_chars(rest, pos, doors, [pos | stack])

      "|" ->
        # Alternative branch - return to saved position
        [saved_pos | _] = stack
        parse_chars(rest, saved_pos, doors, stack)

      ")" ->
        # End of branch - pop the stack
        [_ | new_stack] = stack
        parse_chars(rest, pos, doors, new_stack)

      _ ->
        parse_chars(rest, pos, doors, stack)
    end
  end

  def find_furthest_room(doors) do
    # BFS from starting position {0, 0}
    start = {0, 0}
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])

    bfs(queue, visited, doors, 0)
  end

  def count_rooms_at_least(doors, min_distance) do
    # BFS from starting position {0, 0} and count rooms with distance >= min_distance
    start = {0, 0}
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])

    bfs_count(queue, visited, doors, min_distance, 0)
  end

  def bfs(queue, visited, doors, max_dist) do
    case :queue.out(queue) do
      {{:value, {pos, dist}}, new_queue} ->
        new_max = max(max_dist, dist)

        # Find all neighbors
        neighbors = get_neighbors(pos, doors)

        # Add unvisited neighbors to queue
        {updated_queue, updated_visited} =
          Enum.reduce(neighbors, {new_queue, visited}, fn neighbor, {q, v} ->
            if MapSet.member?(v, neighbor) do
              {q, v}
            else
              new_q = :queue.in({neighbor, dist + 1}, q)
              new_v = MapSet.put(v, neighbor)
              {new_q, new_v}
            end
          end)

        bfs(updated_queue, updated_visited, doors, new_max)

      {:empty, _} ->
        max_dist
    end
  end

  def bfs_count(queue, visited, doors, min_distance, count) do
    case :queue.out(queue) do
      {{:value, {pos, dist}}, new_queue} ->
        # Increment count if distance is at least min_distance
        new_count = if dist >= min_distance, do: count + 1, else: count

        # Find all neighbors
        neighbors = get_neighbors(pos, doors)

        # Add unvisited neighbors to queue
        {updated_queue, updated_visited} =
          Enum.reduce(neighbors, {new_queue, visited}, fn neighbor, {q, v} ->
            if MapSet.member?(v, neighbor) do
              {q, v}
            else
              new_q = :queue.in({neighbor, dist + 1}, q)
              new_v = MapSet.put(v, neighbor)
              {new_q, new_v}
            end
          end)

        bfs_count(updated_queue, updated_visited, doors, min_distance, new_count)

      {:empty, _} ->
        count
    end
  end

  def get_neighbors(pos, doors) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(fn {dx, dy} ->
      {x, y} = pos
      {x + dx, y + dy}
    end)
    |> Enum.filter(fn neighbor ->
      # Check if there's a door between pos and neighbor
      MapSet.member?(doors, {pos, neighbor}) or MapSet.member?(doors, {neighbor, pos})
    end)
  end
end
