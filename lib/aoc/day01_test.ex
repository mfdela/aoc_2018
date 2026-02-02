defmodule Aoc.Day01Test do
  use ExUnit.Case

  import Elixir.Aoc.Day01

  test "part1 examples" do
    assert part1("+1\n-2\n+3\n+1") == 3
    assert part1("+1\n+1\n+1") == 3
    assert part1("+1\n+1\n-2") == 0
    assert part1("-1\n-2\n-3") == -6
  end

  test "part2 examples" do
    assert part2("+1\n-2\n+3\n+1") == 2
    assert part2("+1\n-1") == 0
    assert part2("+3\n+3\n+4\n-2\n-4") == 10
    assert part2("-6\n+3\n+8\n+5\n-6") == 5
    assert part2("+7\n+7\n-2\n-7\n-4") == 14
  end
end
