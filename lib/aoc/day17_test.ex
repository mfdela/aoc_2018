defmodule Aoc.Day17Test do
  use ExUnit.Case

  import Elixir.Aoc.Day17

  def test_input() do
    """
    x=495, y=2..7
    y=7, x=495..501
    x=501, y=3..7
    x=498, y=2..4
    x=506, y=1..2
    x=498, y=10..13
    x=504, y=10..13
    y=13, x=498..504
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 57
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 29
  end
end
