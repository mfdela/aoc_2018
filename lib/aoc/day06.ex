defmodule Aoc.Day06 do
  def part1(args) do
    coords = args |> parse_input()
    grid = coords |> infinite_grid()

    {areas, infinites} = voronoi(coords, grid)

    areas
    |> Enum.reject(fn {id, _} -> Map.get(infinites, id) end)
    |> Enum.max_by(fn {_, area} -> area end)
    |> elem(1)
  end

  def part2(args, max_distance \\ 10000) do
    coords = args |> parse_input()
    grid = coords |> infinite_grid()
    find_region(coords, grid, max_distance)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y] = String.split(line, ", ")
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  def infinite_grid(coords) do
    x = coords |> Enum.map(&elem(&1, 0))
    y = coords |> Enum.map(&elem(&1, 1))
    {min_x, max_x} = Enum.min_max(x)
    {min_y, max_y} = Enum.min_max(y)
    expand = Enum.max([max_x - min_x, max_y - min_y]) + 1
    {min_x - expand, max_x + expand, min_y - expand, max_y + expand}
  end

  def voronoi(coords, grid) do
    {min_x, max_x, min_y, max_y} = grid

    for x <- min_x..max_x, y <- min_y..max_y, reduce: {%{}, %{}} do
      {a, i} = acc ->
        dists =
          coords
          |> Enum.with_index()
          |> Enum.map(fn {{cx, cy}, index} ->
            {abs(x - cx) + abs(y - cy), index}
          end)
          |> Enum.sort_by(&elem(&1, 0))

        {min_dist, closest} = hd(dists)
        ties = dists |> Enum.count(fn {dist, _} -> dist == min_dist end)
        infinite? = x == min_x or x == max_x or y == min_y or y == max_y

        if ties > 1 do
          acc
        else
          case infinite? do
            false -> {Map.update(a, closest, 1, &(&1 + 1)), i}
            true -> {Map.update(a, closest, 1, &(&1 + 1)), Map.put(i, closest, true)}
          end
        end
    end
  end

  def find_region(coords, grid, max_distance) do
    {min_x, max_x, min_y, max_y} = grid

    for x <- min_x..max_x, y <- min_y..max_y, reduce: 0 do
      acc ->
        dist =
          coords
          |> Enum.reduce(0, fn {cx, cy}, sum ->
            sum + abs(x - cx) + abs(y - cy)
          end)

        if dist < max_distance do
          acc + 1
        else
          acc
        end
    end
  end
end
