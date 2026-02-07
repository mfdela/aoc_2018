defmodule Aoc.Day11 do
  def part1(args) do
    args
    |> create_grid()
    |> cells_square(3)
    |> Enum.max_by(fn {_pos, fuel} -> fuel end)
    |> elem(0)
    |> then(fn {x, y, _size} -> {x, y} end)
  end

  def part2(args) do
    args
    |> create_grid()
    |> find_max_square()
    |> IO.inspect()
  end

  def create_grid(serial_number) do
    for x <- 1..300, y <- 1..300, reduce: %{} do
      acc ->
        Map.put(acc, {x, y}, power_level(x, y, serial_number))
    end
  end

  def power_level(x, y, serial_number) do
    rack_id = x + 10

    (rack_id * y + serial_number)
    |> Kernel.*(rack_id)
    |> div(100)
    |> rem(10)
    |> Kernel.-(5)
  end

  def cells_square(grid, size) do
    for x <- 1..(300 - size + 1), y <- 1..(300 - size + 1), reduce: %{} do
      acc ->
        fuel_cells =
          for dx <- 0..(size - 1), dy <- 0..(size - 1) do
            grid[{x + dx, y + dy}]
          end
          |> Enum.sum()

        Map.put(acc, {x, y, size}, fuel_cells)
    end
  end

  def find_max_square(grid) do
    # Build summed-area table for O(1) range sum queries
    sat = build_summed_area_table(grid)

    for size <- 1..300,
        x <- 1..(300 - size + 1),
        y <- 1..(300 - size + 1),
        reduce: {0, {0, 0, 0}} do
      {max_fuel, max_pos} ->
        fuel = square_sum_sat(sat, x, y, size)

        if fuel > max_fuel do
          {fuel, {x, y, size}}
        else
          {max_fuel, max_pos}
        end
    end
    |> elem(1)
  end

  # Build a summed-area table where sat[{x,y}] = sum of all cells from (1,1) to (x,y)
  def build_summed_area_table(grid) do
    for y <- 1..300, x <- 1..300, reduce: %{} do
      sat ->
        value = grid[{x, y}]
        left = Map.get(sat, {x - 1, y}, 0)
        top = Map.get(sat, {x, y - 1}, 0)
        top_left = Map.get(sat, {x - 1, y - 1}, 0)

        Map.put(sat, {x, y}, value + left + top - top_left)
    end
  end

  # Get sum of square using summed-area table in O(1)
  def square_sum_sat(sat, x, y, size) do
    x2 = x + size - 1
    y2 = y + size - 1

    total = Map.get(sat, {x2, y2}, 0)
    left = Map.get(sat, {x - 1, y2}, 0)
    top = Map.get(sat, {x2, y - 1}, 0)
    top_left = Map.get(sat, {x - 1, y - 1}, 0)

    total - left - top + top_left
  end
end
