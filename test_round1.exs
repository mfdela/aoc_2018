defmodule RoundTracer do
  def trace_rounds(grid, units, max_rounds) do
    do_round(grid, units, 0, max_rounds)
  end

  defp do_round(grid, units, round_num, max_rounds) when round_num >= max_rounds do
    {round_num, units}
  end

  defp do_round(grid, units, round_num, max_rounds) do
    print_state(grid, units, round_num)

    unit_order =
      units
      |> Enum.map(fn {id, unit} -> {id, unit.pos} end)
      |> Enum.sort_by(fn {_id, {x, y}} -> {y, x} end)
      |> Enum.map(fn {id, _pos} -> id end)

    case process_turns(grid, units, unit_order, false) do
      {:complete, new_units} ->
        do_round(grid, new_units, round_num + 1, max_rounds)

      {:ended, final_units, _incomplete} ->
        print_state(grid, final_units, round_num + 1)
        {round_num + 1, final_units}
    end
  end

  defp process_turns(grid, units, [], _incomplete) do
    {:complete, units}
  end

  defp process_turns(grid, units, [unit_id | rest], incomplete) do
    unit = units[unit_id]

    if !unit || unit.hp <= 0 do
      process_turns(grid, units, rest, incomplete)
    else
      enemies =
        Enum.filter(units, fn {_id, u} ->
          u.type != unit.type && u.hp > 0
        end)

      if Enum.empty?(enemies) do
        {:ended, units, true}
      else
        new_units = Aoc.Day15.send(:take_turn, [grid, units, unit_id])
        process_turns(grid, new_units, rest, incomplete)
      end
    end
  end

  def print_state(grid, units, round) do
    IO.puts("\nAfter round #{round}:")

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

      units_on_row =
        Enum.filter(units, fn {_id, u} -> elem(u.pos, 1) == y && u.hp > 0 end)
        |> Enum.sort_by(fn {_id, u} -> elem(u.pos, 0) end)

      if !Enum.empty?(units_on_row) do
        IO.write("   ")

        Enum.each(units_on_row, fn {_id, u} ->
          IO.write("#{if u.type == :elf, do: "E", else: "G"}(#{u.hp}) ")
        end)
      end

      IO.puts("")
    end
  end
end

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
RoundTracer.trace_rounds(grid, units, 3)
