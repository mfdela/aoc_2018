defmodule Aoc.Day16Test do
  use ExUnit.Case

  import Elixir.Aoc.Day16

  def test_input() do
    """
    Before: [3, 2, 1, 1]
    9 2 1 2
    After:  [3, 2, 2, 1]
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    # This sample behaves like 3 opcodes (mulr, addi, seti)
    # So 1 sample behaves like 3+ opcodes
    assert result == 1
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
