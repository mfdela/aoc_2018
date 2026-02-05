defmodule Aoc.Day09Test do
  use ExUnit.Case

  import Elixir.Aoc.Day09

  def test_input() do
    """
    10 players; last marble is worth 1618 points
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 8317
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
