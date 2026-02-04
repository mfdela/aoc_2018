defmodule Aoc.Day05Test do
  use ExUnit.Case

  import Elixir.Aoc.Day05

  def test_input() do
    """
    dabAcCaCBAcCcaDA
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 10
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
