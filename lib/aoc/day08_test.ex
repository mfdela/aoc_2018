defmodule Aoc.Day08Test do
  use ExUnit.Case

  import Elixir.Aoc.Day08

  def test_input() do
    """
    2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 138
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 66
  end

end
