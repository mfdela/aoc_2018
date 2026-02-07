defmodule Aoc.Day12Test do
  use ExUnit.Case

  import Elixir.Aoc.Day12

  def test_input() do
    """
    initial state: #..#.#..##......###...###

    ...## => #
    ..#.. => #
    .#... => #
    .#.#. => #
    .#.## => #
    .##.. => #
    .#### => #
    #.#.# => #
    #.### => #
    ##.#. => #
    ##.## => #
    ###.. => #
    ###.# => #
    ####. => #
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 325
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result
  end
end
