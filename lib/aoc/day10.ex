defmodule Aoc.Day10 do
  def part1(args) do
    points = parse_input(args)

    # Find the time when the message appears (smallest bounding box)
    {message, _time} = find_message(points)

    IO.puts("\nPart 1 - Message:")
    IO.puts(message)
    message
  end

  def part2(args) do
    points = parse_input(args)

    # Return the number of seconds it takes for the message to appear
    {_message, time} = find_message(points)
    time
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    ~r/position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>/
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [px, py, vx, vy] -> {{px, py}, {vx, vy}} end)
  end

  def find_message(points) do
    # The message appears when points are closest together (minimum bounding box area)
    # We'll simulate forward until the bounding box starts growing again
    find_smallest_bounding_box(points, 0, nil, nil)
  end

  def find_smallest_bounding_box(points, time, prev_area, prev_points) do
    area = bounding_box_area(points)

    cond do
      # If area is growing and we had a previous area, we've passed the minimum
      prev_area != nil && area > prev_area ->
        message = render_points(prev_points)
        {message, time - 1}

      # Keep going
      true ->
        next_points = step_forward(points)
        find_smallest_bounding_box(next_points, time + 1, area, points)
    end
  end

  def step_forward(points) do
    Enum.map(points, fn {{px, py}, {vx, vy}} ->
      {{px + vx, py + vy}, {vx, vy}}
    end)
  end

  def bounding_box_area(points) do
    positions = Enum.map(points, fn {{x, y}, _} -> {x, y} end)

    xs = Enum.map(positions, fn {x, _} -> x end)
    ys = Enum.map(positions, fn {_, y} -> y end)

    min_x = Enum.min(xs)
    max_x = Enum.max(xs)
    min_y = Enum.min(ys)
    max_y = Enum.max(ys)

    (max_x - min_x) * (max_y - min_y)
  end

  def render_points(points) do
    positions = Enum.map(points, fn {{x, y}, _} -> {x, y} end) |> MapSet.new()

    xs = Enum.map(positions, fn {x, _} -> x end)
    ys = Enum.map(positions, fn {_, y} -> y end)

    min_x = Enum.min(xs)
    max_x = Enum.max(xs)
    min_y = Enum.min(ys)
    max_y = Enum.max(ys)

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        if MapSet.member?(positions, {x, y}), do: "#", else: "."
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
  end
end
