defmodule Aoc.Day22 do
  def part1(args) do
    args
    |> parse_input()
    |> total_risk_level()
  end

  def part2(args) do
    args
    |> parse_input()
    |> shortest_path_to_target()
  end

  def parse_input(input) do
    [depth, target_string] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ": "))
      |> Enum.map(&Enum.at(&1, 1))

    target_pair = String.split(target_string, ",") |> Enum.map(&String.to_integer/1)

    {String.to_integer(depth), target_pair}
  end

  # Build erosion level grid iteratively to avoid exponential recalculation
  def build_erosion_grid(depth, [target_x, target_y]) do
    build_grid_with_bounds(depth, [target_x, target_y], target_x, target_y)
  end

  # Build grid with custom bounds, but respect the original target for geo_index
  def build_grid_with_bounds(depth, [target_x, target_y], max_x, max_y) do
    for x <- 0..max_x, y <- 0..max_y, reduce: %{} do
      cache ->
        geo_index =
          cond do
            (x == 0 and y == 0) or (x == target_x and y == target_y) -> 0
            x == 0 -> y * 48_271
            y == 0 -> x * 16_807
            true -> cache[{x - 1, y}] * cache[{x, y - 1}]
          end

        erosion = rem(geo_index + depth, 20183)
        Map.put(cache, {x, y}, erosion)
    end
  end

  def type_from_erosion(erosion) do
    case rem(erosion, 3) do
      0 -> :rocky
      1 -> :wet
      2 -> :narrow
    end
  end

  def risk_level(:rocky), do: 0
  def risk_level(:wet), do: 1
  def risk_level(:narrow), do: 2

  def total_risk_level({depth, [target_x, target_y] = target}) do
    erosion_grid = build_erosion_grid(depth, target)

    for x <- 0..target_x, y <- 0..target_y do
      erosion_grid[{x, y}]
      |> type_from_erosion()
      |> risk_level()
    end
    |> Enum.sum()
  end

  # Part 2: Pathfinding with equipment constraints

  # Tools that can be used in each region type
  def valid_tools(:rocky), do: [:climbing_gear, :torch]
  def valid_tools(:wet), do: [:climbing_gear, :neither]
  def valid_tools(:narrow), do: [:torch, :neither]

  # Check if a tool is valid for a region type
  def tool_valid_for_region?(tool, region_type) do
    tool in valid_tools(region_type)
  end

  # Get the region type for a coordinate from the pre-built grid
  def get_region_type({x, y}, erosion_grid, _depth, _target) when x >= 0 and y >= 0 do
    case Map.get(erosion_grid, {x, y}) do
      nil -> nil
      erosion -> type_from_erosion(erosion)
    end
  end

  def get_region_type(_, _, _, _), do: nil

  def shortest_path_to_target({depth, target}) do
    [target_x, target_y] = target
    # Build a larger grid to allow for paths that go around
    erosion_grid = build_grid_with_bounds(depth, target, target_x + 100, target_y + 100)

    # Dijkstra's algorithm
    # State: {position, tool} where position is {x, y}
    start_state = {{0, 0}, :torch}
    goal_state = {{target_x, target_y}, :torch}

    # Priority queue: {cost, state}
    initial_queue = :gb_sets.singleton({0, start_state})
    initial_visited = MapSet.new()
    initial_distances = %{start_state => 0}

    dijkstra(initial_queue, initial_visited, initial_distances, goal_state, erosion_grid, depth, target)
  end

  defp dijkstra(queue, visited, distances, goal_state, erosion_grid, depth, target) do
    if :gb_sets.is_empty(queue) do
      :infinity
    else
      {{cost, state}, new_queue} = :gb_sets.take_smallest(queue)

      if state == goal_state do
        cost
      else
        if MapSet.member?(visited, state) do
          dijkstra(new_queue, visited, distances, goal_state, erosion_grid, depth, target)
        else
          new_visited = MapSet.put(visited, state)
          {new_queue, new_distances} = explore_neighbors(state, cost, new_queue, distances, erosion_grid, depth, target, visited)
          dijkstra(new_queue, new_visited, new_distances, goal_state, erosion_grid, depth, target)
        end
      end
    end
  end

  defp explore_neighbors({{x, y} = pos, tool}, cost, queue, distances, erosion_grid, depth, target, visited) do
    current_region = get_region_type(pos, erosion_grid, depth, target)

    # Generate all possible next states
    neighbors =
      [
        # Move to adjacent regions (cost: 1 minute)
        {{x + 1, y}, tool},
        {{x - 1, y}, tool},
        {{x, y + 1}, tool},
        {{x, y - 1}, tool}
      ]
      |> Enum.filter(fn {{nx, ny}, _} -> nx >= 0 and ny >= 0 end)
      |> Enum.filter(fn {next_pos, next_tool} ->
        next_region = get_region_type(next_pos, erosion_grid, depth, target)
        next_region != nil and tool_valid_for_region?(next_tool, next_region)
      end)
      |> Enum.map(fn neighbor -> {neighbor, 1} end)

    # Switch tools (cost: 7 minutes)
    tool_switches =
      valid_tools(current_region)
      |> Enum.reject(fn t -> t == tool end)
      |> Enum.map(fn new_tool -> {{pos, new_tool}, 7} end)

    all_neighbors = neighbors ++ tool_switches

    # Update queue and distances for each neighbor
    Enum.reduce(all_neighbors, {queue, distances}, fn {neighbor_state, move_cost}, {q, d} ->
      new_cost = cost + move_cost
      old_cost = Map.get(d, neighbor_state, :infinity)

      if new_cost < old_cost and not MapSet.member?(visited, neighbor_state) do
        new_q = :gb_sets.add({new_cost, neighbor_state}, q)
        new_d = Map.put(d, neighbor_state, new_cost)
        {new_q, new_d}
      else
        {q, d}
      end
    end)
  end
end
