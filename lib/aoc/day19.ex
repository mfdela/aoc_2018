defmodule Aoc.Day19 do
  def part1(args) do
    {ip_reg, program} = args |> parse_input()
    registers = {0, 0, 0, 0, 0, 0}
    final_registers = execute_program(program, registers, ip_reg, 0)
    elem(final_registers, 0)
  end

  def part2(_args) do
    # The program computes sum of divisors of a target number
    #
    # Initialization phase (lines 17-35): Calculates the target number stored in register 5
    #   Part 1 (r0=0): r5 = ((2²) * 19 * 11) + ((5 * 22) + 4) = 950
    #   Part 2 (r0=1): r5 = 950 + ((27 * 28 + 29) * 30 * 14 * 32) = 10,551,350
    #
    # Main computation (lines 1-16): Nested loops that find all divisors
    #   for r2 = 1 to r5:
    #     for r4 = 1 to r5:
    #       if r2 * r4 == r5:
    #         r0 = r0 + r2

    target = 10_551_350
    sum_of_divisors(target)
  end

  def sum_of_divisors(n) do
    # Find all divisors efficiently by only checking up to sqrt(n)
    limit = trunc(:math.sqrt(n))

    1..limit
    |> Enum.reduce(0, fn i, acc ->
      if rem(n, i) == 0 do
        # i is a divisor
        other = div(n, i)
        if i == other do
          # Perfect square, only count once
          acc + i
        else
          # Count both i and n/i
          acc + i + other
        end
      else
        acc
      end
    end)
  end

  def parse_input(input) do
    lines = input |> String.split("\n", trim: true)

    [binding | instructions] = lines

    "#ip " <> ip_reg_str = binding
    ip_reg = String.to_integer(ip_reg_str)
    {ip_reg, instructions |> Enum.map(&parse_instruction/1)}
  end

  def parse_instruction(instruction) do
    [opcode, a, b, c] = String.split(instruction, " ", trim: true)
    {String.to_atom(opcode), String.to_integer(a), String.to_integer(b), String.to_integer(c)}
  end

  def execute_program(program, registers, ip_reg, ip) do
    # Check if instruction pointer is out of bounds (halt condition)
    if ip < 0 or ip >= length(program) do
      registers
    else
      # Get the instruction at current IP
      {opcode, a, b, c} = Enum.at(program, ip)

      # Write IP value to the bound register before execution
      registers_with_ip = put_elem(registers, ip_reg, ip)

      # Execute the instruction
      new_registers = execute(opcode, registers_with_ip, a, b, c)

      # Read the IP value back from the bound register
      new_ip = elem(new_registers, ip_reg)

      # Increment the IP and continue
      execute_program(program, new_registers, ip_reg, new_ip + 1)
    end
  end

  def execute(opcode, registers, a, b, c) do
    value =
      case opcode do
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
