defmodule Aoc.Day11Test do
  use ExUnit.Case

  import Elixir.Aoc.Day11

  def test_input() do
    18
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == {33, 45}
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == {90, 269, 16}
  end
end
