defmodule Aoc.Day09 do
  def part1(args) do
    [players, last_marble] =
      args
      |> parse_input()

    elf_turns(players, last_marble)
  end

  def part2(args) do
    args
  end

  def parse_input(input) do
    Regex.run(~r/(\d+) players; last marble is worth (\d+) points/, input,
      capture: :all_but_first
    )
    |> Enum.map(&String.to_integer/1)
  end

  def elf_turns(players, last_marble) do
    # Use a zipper: {before (reversed), current, after}
    initial_circle = {[], 0, []}
    initial_scores = Map.new(0..(players - 1), fn p -> {p, 0} end)

    {_circle, scores} =
      Enum.reduce(1..last_marble, {initial_circle, initial_scores}, fn marble, {circle, scores} ->
        player = rem(marble - 1, players)

        if rem(marble, 23) == 0 do
          # Special case
          {new_circle, removed} = remove_7_ccw(circle)
          new_score = scores[player] + marble + removed
          {new_circle, Map.put(scores, player, new_score)}
        else
          # Normal: move 1 clockwise, then insert after current
          circle_moved = move_cw(circle)
          {insert_after(circle_moved, marble), scores}
        end
      end)

    scores |> Map.values() |> Enum.max()
  end

  # Move 1 position clockwise: current moves to before, first of after becomes current
  def move_cw({before, current, []}) do
    # Wrap around: reverse before and current into after
    [first | rest] = Enum.reverse([current | before])
    {[], first, rest}
  end

  def move_cw({before, current, [next | after_]}) do
    {[current | before], next, after_}
  end

  # Insert after current position (new value becomes current)
  def insert_after({before, current, after_}, value) do
    {[current | before], value, after_}
  end

  # Remove 7 positions counter-clockwise
  def remove_7_ccw(circle) do
    # Move 7 times counter-clockwise
    circle7 =
      circle
      |> move_ccw()
      |> move_ccw()
      |> move_ccw()
      |> move_ccw()
      |> move_ccw()
      |> move_ccw()
      |> move_ccw()

    {before, current, after_} = circle7
    removed = current

    # Next element clockwise becomes current
    new_circle =
      case after_ do
        [next | rest] ->
          {before, next, rest}

        [] ->
          # Wrap around
          [first | rest] = Enum.reverse(before)
          {[], first, rest}
      end

    {new_circle, removed}
  end

  # Move 1 position counter-clockwise: first of before becomes current, current moves to after
  def move_ccw({[], current, after_}) do
    # Wrap around: reverse after and current into before
    [last | rest] = Enum.reverse([current | after_])
    {rest, last, []}
  end

  def move_ccw({[prev | before], current, after_}) do
    {before, prev, [current | after_]}
  end
end
