defmodule Aoc.Day13Test do
  use ExUnit.Case

  import Elixir.Aoc.Day13

  def test_input() do
    ~S"""
    /->-\
    |   |  /----\
    | /-+--+-\  |
    | | |  | v  |
    \-+-/  \-+--/
      \------/
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == {7, 3}
  end

  @tag :skip
  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
