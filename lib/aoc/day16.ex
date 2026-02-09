defmodule Aoc.Day16 do
  def part1(input) do
    samples = parse_samples(input)

    samples
    |> Enum.count(fn sample ->
      matching_opcodes = count_matching_opcodes(sample)
      matching_opcodes >= 3
    end)
  end

  def part2(input) do
    {samples, program} = parse_input(input)

    # Deduce the opcode mapping
    opcode_map = deduce_opcodes(samples)

    # Execute the test program
    registers = {0, 0, 0, 0}
    final_registers = execute_program(program, registers, opcode_map)

    elem(final_registers, 0)
  end

  def parse_input(input) do
    # Split input into samples section and program section
    # They're separated by multiple blank lines
    parts = String.split(input, ~r/\n\n\n+/, parts: 2)

    samples = if length(parts) > 0 do
      parse_samples(Enum.at(parts, 0))
    else
      []
    end

    program = if length(parts) > 1 do
      parse_program(Enum.at(parts, 1))
    else
      []
    end

    {samples, program}
  end

  def parse_samples(input) do
    # Split into lines and group into samples
    lines = String.split(input, "\n", trim: true)

    lines
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.filter(fn chunk ->
      length(chunk) == 3 and
      Enum.at(chunk, 0) |> String.starts_with?("Before:") and
      Enum.at(chunk, 2) |> String.starts_with?("After:")
    end)
    |> Enum.map(&parse_sample/1)
  end

  def parse_program(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [opcode, a, b, c] = String.split(line) |> Enum.map(&String.to_integer/1)
      {opcode, a, b, c}
    end)
  end

  def parse_sample([before_line, instruction_line, after_line]) do
    # Parse "Before: [3, 2, 1, 1]"
    before =
      Regex.run(~r/Before:\s*\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]/, before_line)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    # Parse "9 2 1 2"
    [opcode, a, b, c] =
      String.split(instruction_line)
      |> Enum.map(&String.to_integer/1)

    # Parse "After:  [3, 2, 2, 1]"
    after_regs =
      Regex.run(~r/After:\s*\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]/, after_line)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    %{
      before: before,
      opcode: opcode,
      a: a,
      b: b,
      c: c,
      after: after_regs
    }
  end

  def count_matching_opcodes(sample) do
    all_opcodes()
    |> Enum.count(fn opcode ->
      result = execute(opcode, sample.before, sample.a, sample.b, sample.c)
      result == sample.after
    end)
  end

  def all_opcodes do
    [
      :addr, :addi,
      :mulr, :muli,
      :banr, :bani,
      :borr, :bori,
      :setr, :seti,
      :gtir, :gtri, :gtrr,
      :eqir, :eqri, :eqrr
    ]
  end

  def get_matching_opcodes(sample) do
    all_opcodes()
    |> Enum.filter(fn opcode ->
      result = execute(opcode, sample.before, sample.a, sample.b, sample.c)
      result == sample.after
    end)
    |> MapSet.new()
  end

  def deduce_opcodes(samples) do
    # Build a map of opcode_number -> possible operations
    possibilities =
      samples
      |> Enum.reduce(%{}, fn sample, acc ->
        matching = get_matching_opcodes(sample)
        Map.update(acc, sample.opcode, matching, fn existing ->
          MapSet.intersection(existing, matching)
        end)
      end)

    # Use constraint propagation to deduce the unique mapping
    solve_opcode_mapping(possibilities, %{})
  end

  def solve_opcode_mapping(possibilities, solved) do
    # Find opcodes with only one possibility
    case Enum.find(possibilities, fn {_num, ops} -> MapSet.size(ops) == 1 end) do
      nil ->
        # All solved or no more can be solved
        solved

      {opcode_num, ops} ->
        operation = MapSet.to_list(ops) |> hd()

        # Add to solved
        new_solved = Map.put(solved, opcode_num, operation)

        # Remove this operation from all other possibilities
        new_possibilities =
          possibilities
          |> Map.delete(opcode_num)
          |> Enum.map(fn {num, ops} ->
            {num, MapSet.delete(ops, operation)}
          end)
          |> Map.new()

        solve_opcode_mapping(new_possibilities, new_solved)
    end
  end

  def execute_program(program, registers, opcode_map) do
    Enum.reduce(program, registers, fn {opcode_num, a, b, c}, regs ->
      operation = Map.get(opcode_map, opcode_num)
      execute(operation, regs, a, b, c)
    end)
  end

  def execute(opcode, registers, a, b, c) do
    value = case opcode do
      # Addition
      :addr -> elem(registers, a) + elem(registers, b)
      :addi -> elem(registers, a) + b

      # Multiplication
      :mulr -> elem(registers, a) * elem(registers, b)
      :muli -> elem(registers, a) * b

      # Bitwise AND
      :banr -> Bitwise.band(elem(registers, a), elem(registers, b))
      :bani -> Bitwise.band(elem(registers, a), b)

      # Bitwise OR
      :borr -> Bitwise.bor(elem(registers, a), elem(registers, b))
      :bori -> Bitwise.bor(elem(registers, a), b)

      # Assignment
      :setr -> elem(registers, a)
      :seti -> a

      # Greater-than testing
      :gtir -> if a > elem(registers, b), do: 1, else: 0
      :gtri -> if elem(registers, a) > b, do: 1, else: 0
      :gtrr -> if elem(registers, a) > elem(registers, b), do: 1, else: 0

      # Equality testing
      :eqir -> if a == elem(registers, b), do: 1, else: 0
      :eqri -> if elem(registers, a) == b, do: 1, else: 0
      :eqrr -> if elem(registers, a) == elem(registers, b), do: 1, else: 0
    end

    put_elem(registers, c, value)
  end
end
