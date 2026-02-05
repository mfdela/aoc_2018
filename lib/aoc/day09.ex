defmodule Aoc.Day09 do
  def part1(args) do
    [players, last_marble] = parse_input(args)
    play_game(players, last_marble)
  end

  def part2(args) do
    [players, last_marble] = parse_input(args)
    play_game(players, last_marble * 100)
  end

  def parse_input(input) do
    Regex.run(~r/(\d+) players; last marble is worth (\d+) points/, input,
      capture: :all_but_first
    )
    |> Enum.map(&String.to_integer/1)
  end

  def play_game(players, last_marble) do
    # Map-based circular doubly-linked list
    # Each marble maps to {prev, next}
    # Start with marble 0 pointing to itself
    initial_circle = %{0 => {0, 0}}
    initial_scores = Map.new(0..(players - 1), fn p -> {p, 0} end)

    {_circle, _current, scores} =
      Enum.reduce(1..last_marble, {initial_circle, 0, initial_scores}, fn marble, {circle, current, scores} ->
        player = rem(marble - 1, players)

        if rem(marble, 23) == 0 do
          # Move 7 counter-clockwise and remove
          target = move_ccw(circle, current, 7)
          {prev, next} = circle[target]

          # Remove target from circle
          new_circle =
            circle
            |> Map.delete(target)
            |> Map.update!(prev, fn {pp, _} -> {pp, next} end)
            |> Map.update!(next, fn {_, nn} -> {prev, nn} end)

          # Update score
          new_score = scores[player] + marble + target
          new_scores = Map.put(scores, player, new_score)

          {new_circle, next, new_scores}
        else
          # Move 1 clockwise, insert after
          {_, next1} = circle[current]
          {_, next2} = circle[next1]

          # Insert marble between next1 and next2
          new_circle =
            circle
            |> Map.put(marble, {next1, next2})
            |> Map.update!(next1, fn {p, _} -> {p, marble} end)
            |> Map.update!(next2, fn {_, n} -> {marble, n} end)

          {new_circle, marble, scores}
        end
      end)

    scores |> Map.values() |> Enum.max()
  end

  # Move N positions counter-clockwise
  def move_ccw(_circle, current, 0), do: current
  def move_ccw(circle, current, n) do
    {prev, _} = circle[current]
    move_ccw(circle, prev, n - 1)
  end
end
