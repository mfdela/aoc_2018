defmodule Aoc.Day22Test do
  use ExUnit.Case

  import Elixir.Aoc.Day22

  def test_input() do
    """
    depth: 510
    target: 10,10
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 114
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 45
  end
end
