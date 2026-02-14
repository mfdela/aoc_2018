defmodule Aoc.Day23Test do
  use ExUnit.Case

  import Elixir.Aoc.Day23

  def test_input() do
    """
    pos=<0,0,0>, r=4
    pos=<1,0,0>, r=1
    pos=<4,0,0>, r=3
    pos=<0,2,0>, r=1
    pos=<0,5,0>, r=3
    pos=<0,0,3>, r=1
    pos=<1,1,1>, r=1
    pos=<1,1,2>, r=1
    pos=<1,3,1>, r=1
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 7
  end

  def test_input_part2() do
    """
    pos=<10,12,12>, r=2
    pos=<12,14,12>, r=2
    pos=<16,12,12>, r=4
    pos=<14,14,14>, r=6
    pos=<50,50,50>, r=200
       pos=<10,10,10>, r=5
    """
  end

  test "part2" do
    input = test_input_part2()
    result = part2(input)

    assert result == 36
  end
end
