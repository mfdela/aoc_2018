defmodule Aoc.Day03Test do
  use ExUnit.Case

  import Elixir.Aoc.Day03

  def test_input() do
    """
    #1 @ 1,3: 4x4
    #2 @ 3,1: 4x4
    #3 @ 5,5: 2x2
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 4
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 3
  end
end
