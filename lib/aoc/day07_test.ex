defmodule Aoc.Day07Test do
  use ExUnit.Case

  import Elixir.Aoc.Day07

  def test_input() do
    """
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == "CABDFE"
  end

  test "part2" do
    input = test_input()
    # Example uses 2 workers and base time of 0
    result = part2(input, 2, 0)

    assert result == 15
  end
end
