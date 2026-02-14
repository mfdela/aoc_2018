defmodule Aoc.Day25Test do
  use ExUnit.Case

  import Elixir.Aoc.Day25

  def test_input() do
    """
    0,0,0,0
    3,0,0,0
    0,3,0,0
    0,0,3,0
    0,0,0,3
    0,0,0,6
    9,0,0,0
    12,0,0,0
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 2
  end

  test "part1 example 2" do
    input = """
    -1,2,2,0
    0,0,2,-2
    0,0,0,-2
    -1,2,0,0
    -2,-2,-2,2
    3,0,2,-1
    -1,3,2,2
    -1,0,-1,0
    0,2,1,-2
    3,0,0,0
    """

    assert part1(input) == 4
  end

  test "part1 example 3" do
    input = """
    1,-1,0,1
    2,0,-1,0
    3,2,-1,0
    0,0,3,1
    0,0,-1,-1
    2,3,-2,0
    -2,2,0,0
    2,-2,0,-1
    1,-1,0,-1
    3,2,0,2
    """

    assert part1(input) == 3
  end

  test "part1 example 4" do
    input = """
    1,-1,-1,-2
    -2,-2,0,1
    0,2,1,3
    -2,3,-2,1
    0,2,3,-2
    -1,-1,1,-2
    0,-2,-1,0
    -2,2,3,-1
    1,2,2,0
    -1,-2,0,-2
    """

    assert part1(input) == 8
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
