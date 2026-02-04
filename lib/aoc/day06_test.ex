defmodule Aoc.Day06Test do
  use ExUnit.Case

  import Elixir.Aoc.Day06

  def test_input() do
    """
    1, 1
    1, 6
    8, 3
    3, 4
    5, 5
    8, 9
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 17
  end

  test "part2" do
    input = test_input()
    result = part2(input, 32)

    assert result == 16
  end
end
