defmodule Aoc.Day17 do
  def part1(input) do
    clay = parse_input(input)
    {min_y, max_y} = get_y_bounds(clay)

    grid = simulate_water(clay, max_y)

    grid
    |> Enum.count(fn {{_x, y}, tile} ->
      y >= min_y and y <= max_y and tile in [:water, :settled]
    end)
  end

  def part2(input) do
    clay = parse_input(input)
    {min_y, max_y} = get_y_bounds(clay)

    grid = simulate_water(clay, max_y)

    grid
    |> Enum.count(fn {{_x, y}, tile} ->
      y >= min_y and y <= max_y and tile == :settled
    end)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&parse_line/1)
    |> Enum.into(%{}, fn pos -> {pos, :clay} end)
  end

  def parse_line(line) do
    cond do
      String.starts_with?(line, "x=") ->
        [x_part, y_part] = String.split(line, ", ")
        x = x_part |> String.replace("x=", "") |> String.to_integer()
        [y_start, y_end] = y_part |> String.replace("y=", "") |> String.split("..") |> Enum.map(&String.to_integer/1)
        for y <- y_start..y_end, do: {x, y}

      String.starts_with?(line, "y=") ->
        [y_part, x_part] = String.split(line, ", ")
        y = y_part |> String.replace("y=", "") |> String.to_integer()
        [x_start, x_end] = x_part |> String.replace("x=", "") |> String.split("..") |> Enum.map(&String.to_integer/1)
        for x <- x_start..x_end, do: {x, y}
    end
  end

  def get_y_bounds(clay) do
    y_values = clay |> Map.keys() |> Enum.map(fn {_x, y} -> y end)
    {Enum.min(y_values), Enum.max(y_values)}
  end

  def simulate_water(clay, max_y) do
    flow(clay, 500, 0, max_y)
  end

  # Main flow function - returns the updated grid
  def flow(grid, x, y, max_y) do
    cond do
      # Out of bounds
      y > max_y ->
        grid

      # Hit clay - stop
      Map.get(grid, {x, y}) == :clay ->
        grid

      # Hit settled water - stop
      Map.get(grid, {x, y}) == :settled ->
        grid

      # Already flowing water - try to process it anyway
      Map.get(grid, {x, y}) == :water ->
        # Try to flow downward first
        grid = flow(grid, x, y + 1, max_y)

        # Check what's below now
        below = Map.get(grid, {x, y + 1})

        # If there's support below, try to fill horizontally
        if below in [:clay, :settled] do
          fill(grid, x, y, max_y)
        else
          # No support, water just flows through
          grid
        end

      true ->
        # Mark this position as flowing water
        grid = Map.put(grid, {x, y}, :water)

        # Try to flow downward
        grid = flow(grid, x, y + 1, max_y)

        # Check what's below now
        below = Map.get(grid, {x, y + 1})

        # If there's support below, try to fill horizontally
        if below in [:clay, :settled] do
          fill(grid, x, y, max_y)
        else
          # No support, water just flows through
          grid
        end
    end
  end

  # Fill horizontally and settle if bounded
  def fill(grid, x, y, max_y) do
    # Scan left and right to find boundaries
    left_bound = scan_left(grid, x - 1, y)
    right_bound = scan_right(grid, x + 1, y)

    case {left_bound, right_bound} do
      {{:wall, left_x}, {:wall, right_x}} ->
        # Bounded on both sides - settle the water
        Enum.reduce((left_x + 1)..right_x - 1, grid, fn sx, g ->
          Map.put(g, {sx, y}, :settled)
        end)

      {{:wall, left_x}, {:fall, right_x}} ->
        # Falls off right side
        grid = Enum.reduce((left_x + 1)..right_x, grid, fn sx, g ->
          Map.put(g, {sx, y}, :water)
        end)
        # Continue flowing from fall point
        flow(grid, right_x, y, max_y)

      {{:fall, left_x}, {:wall, right_x}} ->
        # Falls off left side
        grid = Enum.reduce(left_x..(right_x - 1), grid, fn sx, g ->
          Map.put(g, {sx, y}, :water)
        end)
        # Continue flowing from fall point
        flow(grid, left_x, y, max_y)

      {{:fall, left_x}, {:fall, right_x}} ->
        # Falls off both sides
        grid = Enum.reduce(left_x..right_x, grid, fn sx, g ->
          Map.put(g, {sx, y}, :water)
        end)
        # Continue flowing from both fall points
        grid = flow(grid, left_x, y, max_y)
        flow(grid, right_x, y, max_y)
    end
  end

  # Scan left until we hit a wall or a fall-off point
  # Returns {:wall, x} or {:fall, x}
  def scan_left(grid, x, y) do
    tile = Map.get(grid, {x, y})
    below = Map.get(grid, {x, y + 1})

    cond do
      # Hit a wall
      tile == :clay ->
        {:wall, x}

      # No support below - this is where water falls
      below not in [:clay, :settled] ->
        {:fall, x}

      # Has support, continue scanning
      true ->
        scan_left(grid, x - 1, y)
    end
  end

  # Scan right until we hit a wall or a fall-off point
  # Returns {:wall, x} or {:fall, x}
  def scan_right(grid, x, y) do
    tile = Map.get(grid, {x, y})
    below = Map.get(grid, {x, y + 1})

    cond do
      # Hit a wall
      tile == :clay ->
        {:wall, x}

      # No support below - this is where water falls
      below not in [:clay, :settled] ->
        {:fall, x}

      # Has support, continue scanning
      true ->
        scan_right(grid, x + 1, y)
    end
  end
end
