defmodule Aoc.Day21 do
  def part1(args) do
    # To find the lowest non-negative integer for register 0 that causes the program
    # to halt after executing the fewest instructions, we need to understand when
    # the program halts. Examining the input, instruction 28 is "eqrr 3 0 4" which
    # compares register 3 to register 0. If they're equal, register 4 becomes 1,
    # which causes instruction 29 (addr 4 5 5) to skip ahead and halt.
    #
    # The key insight: the program will halt the first time register 3 equals register 0.
    # To minimize instructions executed, we want this comparison to succeed on the
    # FIRST time it's checked. Therefore, we need to find what value is in register 3
    # when instruction 28 is executed for the first time, and set register 0 to that value.
    #
    # The solution: run the program with register 0 = 0, monitor when we reach instruction 28,
    # and capture the value in register 3 at that moment. That's our answer.

    {ip_reg, program} = args |> parse_input()
    registers = {0, 0, 0, 0, 0, 0}
    find_first_r3_value(program, registers, ip_reg, 0)
  end

  def part2(args) do
    # To find the value for register 0 that causes the program to halt after executing
    # the MOST instructions (while still halting), we need to understand the loop behavior.
    #
    # The program repeatedly executes instruction 28 (eqrr 3 0 4) with different values
    # in register 3. Each time, it checks if register 3 equals register 0. If they match,
    # the program halts. If not, it continues and eventually generates a new value in register 3.
    #
    # Key insight: register 3 will eventually cycle through a sequence of values. Once it
    # starts repeating values we've seen before, it will loop forever (unless register 0
    # matches one of those values).
    #
    # To maximize instructions executed while still halting:
    # - Track all unique values that appear in register 3 at instruction 28
    # - When we see a repeated value, we know the cycle is complete
    # - Set register 0 to the LAST unique value seen before the repetition
    # - This ensures the program goes through all unique values before halting

    {ip_reg, program} = args |> parse_input()
    registers = {0, 0, 0, 0, 0, 0}
    find_last_unique_r3_value(program, registers, ip_reg, 0, MapSet.new(), nil)
  end

  def find_first_r3_value(program, registers, ip_reg, ip) do
    # Check if we're at instruction 28 (the eqrr 3 0 4 instruction)
    if ip == 28 do
      # Return the value in register 3
      elem(registers, 3)
    else
      # Check if instruction pointer is out of bounds
      if ip < 0 or ip >= length(program) do
        nil
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
        find_first_r3_value(program, new_registers, ip_reg, new_ip + 1)
      end
    end
  end

  def find_last_unique_r3_value(program, registers, ip_reg, ip, seen, last_value) do
    # Check if we're at instruction 28 (the eqrr 3 0 4 instruction)
    if ip == 28 do
      r3_value = elem(registers, 3)

      # If we've seen this value before, return the last unique value
      if MapSet.member?(seen, r3_value) do
        IO.puts("Found cycle after #{MapSet.size(seen)} unique values")
        last_value
      else
        # Add this value to our seen set and continue
        new_seen = MapSet.put(seen, r3_value)

        # Print progress every 1000 values
        if rem(MapSet.size(new_seen), 1000) == 0 do
          IO.puts("Seen #{MapSet.size(new_seen)} unique values, current: #{r3_value}")
        end

        # Execute the current instruction and continue
        {opcode, a, b, c} = Enum.at(program, ip)
        registers_with_ip = put_elem(registers, ip_reg, ip)
        new_registers = execute(opcode, registers_with_ip, a, b, c)
        new_ip = elem(new_registers, ip_reg)

        find_last_unique_r3_value(program, new_registers, ip_reg, new_ip + 1, new_seen, r3_value)
      end
    else
      # Check if instruction pointer is out of bounds
      if ip < 0 or ip >= length(program) do
        last_value
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
        find_last_unique_r3_value(program, new_registers, ip_reg, new_ip + 1, seen, last_value)
      end
    end
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
