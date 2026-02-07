defmodule Aoc.Day15Test do
  use ExUnit.Case

  import Elixir.Aoc.Day15

  def test_input() do
    """
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 27730
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
