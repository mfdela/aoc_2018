defmodule Aoc.Day20Test do
  use ExUnit.Case

  import Elixir.Aoc.Day20

  def test_input() do
    "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$"
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 18
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
