defmodule Aoc.Day19Test do
  use ExUnit.Case

  import Elixir.Aoc.Day19

  def test_input() do
    """
    #ip 0
    seti 5 0 1
    seti 6 0 2
    addi 0 1 0
    addr 1 2 3
    setr 1 0 0
    seti 8 0 4
    seti 9 0 5
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 6
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
