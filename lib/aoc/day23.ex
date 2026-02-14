defmodule Aoc.Day23 do
  def part1(args) do
    beacons =
      args
      |> parse_input()

    origin = find_strongest_beacon(beacons)

    find_beacons_in_range(beacons, origin)
    |> Enum.count()
  end

  def part2(args) do
    beacons =
      args
      |> parse_input()

    find_best_coordinate(beacons)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [_, x, y, z, r] = Regex.run(~r/pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(-?\d+)/, line)
    {String.to_integer(x), String.to_integer(y), String.to_integer(z), String.to_integer(r)}
  end

  def find_strongest_beacon(beacons) do
    beacons
    |> Enum.max_by(fn {_, _, _, r} -> r end)
  end

  def find_beacons_in_range(beacons, origin) do
    beacons
    |> Enum.filter(fn {x, y, z, _} -> in_range?(origin, {x, y, z}) end)
  end

  def in_range?({x1, y1, z1, r}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2) <= r
  end

  def find_best_coordinate(beacons) do
    # Find the bounds of all beacons
    {min_x, max_x, min_y, max_y, min_z, max_z} = find_bounds(beacons)

    # Start with a large search space
    size = max(max(max_x - min_x, max_y - min_y), max_z - min_z)
    size = next_power_of_2(size)

    # Use priority queue (heap) to search regions
    # Priority: (negative beacons_in_range, distance_to_origin, size)
    initial_region = {min_x, min_y, min_z, size}
    beacons_in_range = count_beacons_in_range_of_region(beacons, initial_region)
    dist = manhattan_distance({min_x, min_y, min_z}, {0, 0, 0})

    queue = :gb_sets.singleton({-beacons_in_range, dist, size, initial_region})

    search(queue, beacons)
  end

  def find_bounds(beacons) do
    {min_x, max_x} = beacons |> Enum.map(fn {x, _, _, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = beacons |> Enum.map(fn {_, y, _, _} -> y end) |> Enum.min_max()
    {min_z, max_z} = beacons |> Enum.map(fn {_, _, z, _} -> z end) |> Enum.min_max()
    {min_x, max_x, min_y, max_y, min_z, max_z}
  end

  def next_power_of_2(n) do
    next_power_of_2(n, 1)
  end

  def next_power_of_2(n, power) when power >= n, do: power
  def next_power_of_2(n, power), do: next_power_of_2(n, power * 2)

  def search(queue, beacons) do
    case :gb_sets.is_empty(queue) do
      true ->
        0

      false ->
        {{_neg_count, dist, size, region}, queue} = :gb_sets.take_smallest(queue)

        if size == 1 do
          # Found a single point
          dist
        else
          # Subdivide region into 8 octants
          {x, y, z, size} = region
          new_size = div(size, 2)

          new_regions =
            for dx <- [0, new_size],
                dy <- [0, new_size],
                dz <- [0, new_size] do
              {x + dx, y + dy, z + dz, new_size}
            end

          # Add all new regions to queue
          queue =
            Enum.reduce(new_regions, queue, fn new_region, acc ->
              count = count_beacons_in_range_of_region(beacons, new_region)
              {nx, ny, nz, _} = new_region
              new_dist = manhattan_distance({nx, ny, nz}, {0, 0, 0})
              :gb_sets.add({-count, new_dist, new_size, new_region}, acc)
            end)

          search(queue, beacons)
        end
    end
  end

  def count_beacons_in_range_of_region(beacons, {x, y, z, size}) do
    beacons
    |> Enum.count(fn beacon ->
      region_intersects_beacon?(beacon, {x, y, z, size})
    end)
  end

  def region_intersects_beacon?({bx, by, bz, r}, {x, y, z, size}) do
    # Find the closest point in the region to the beacon
    closest_x = max(x, min(bx, x + size - 1))
    closest_y = max(y, min(by, y + size - 1))
    closest_z = max(z, min(bz, z + size - 1))

    # Check if closest point is within beacon's range
    manhattan_distance({bx, by, bz}, {closest_x, closest_y, closest_z}) <= r
  end

  def manhattan_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end
end
