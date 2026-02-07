input = """
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
"""

{grid, units} = Aoc.Day15.parse_input(input)

# Print initial state
IO.puts("Initial state:")

for y <- 0..6 do
  for x <- 0..6 do
    unit = Enum.find(units, fn {_id, u} -> u.pos == {x, y} && u.hp > 0 end)

    cond do
      unit != nil ->
        {_id, u} = unit
        if u.type == :elf, do: IO.write("E"), else: IO.write("G")

      grid[{x, y}] == :wall ->
        IO.write("#")

      grid[{x, y}] == :open ->
        IO.write(".")

      true ->
        IO.write("?")
    end
  end

  IO.puts("")
end

IO.puts("")

{rounds, remaining_units} = Aoc.Day15.simulate(grid, units)

IO.puts("Final state after #{rounds} rounds:")

for y <- 0..6 do
  for x <- 0..6 do
    unit = Enum.find(remaining_units, fn {_id, u} -> u.pos == {x, y} && u.hp > 0 end)

    cond do
      unit != nil ->
        {_id, u} = unit
        if u.type == :elf, do: IO.write("E"), else: IO.write("G")

      grid[{x, y}] == :wall ->
        IO.write("#")

      grid[{x, y}] == :open ->
        IO.write(".")

      true ->
        IO.write("?")
    end
  end

  # Print HP on the right
  units_on_row =
    Enum.filter(remaining_units, fn {_id, u} -> elem(u.pos, 1) == y && u.hp > 0 end)
    |> Enum.sort_by(fn {_id, u} -> elem(u.pos, 0) end)

  if !Enum.empty?(units_on_row) do
    IO.write("   ")

    Enum.each(units_on_row, fn {_id, u} ->
      IO.write("#{if u.type == :elf, do: "E", else: "G"}(#{u.hp}) ")
    end)
  end

  IO.puts("")
end

IO.puts("")

total_hp = Enum.reduce(remaining_units, 0, fn {_id, unit}, acc -> acc + unit.hp end)
IO.puts("Total HP: #{total_hp}")
IO.puts("Outcome: #{rounds * total_hp}")
