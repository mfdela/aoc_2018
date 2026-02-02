defmodule Aoc.Day03 do
  def part1(args) do
    args
    |> parse_input()
    |> count_overlapping_inches()
  end

  def part2(args) do
    args
    |> parse_input()
    |> find_non_overlapping_claim()
    |> elem(0)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_claim/1)
  end

  def parse_claim(claim) do
    [id, x, y, w, h] =
      claim
      |> String.split(~r/[\s#@,:x]/, trim: true)
      |> Enum.map(&String.to_integer/1)

    {id, {x, y}, {w, h}}
  end

  def count_overlapping_inches(claims) do
    claims
    |> Enum.reduce(%{}, fn {_, {x, y}, {w, h}}, acc ->
      for i <- x..(x + w - 1), j <- y..(y + h - 1), reduce: acc do
        acc -> Map.update(acc, {i, j}, 1, &(&1 + 1))
      end
    end)
    |> Enum.count(&(elem(&1, 1) > 1))
  end

  def find_non_overlapping_claim(claims) do
    claims
    |> Enum.reduce_while(nil, fn claim, acc ->
      found =
        Enum.find(claims, fn other ->
          not (claim == other) and
            claim |> overlap?(other)
        end)

      if found do
        {:cont, acc}
      else
        {:halt, claim}
      end
    end)
  end

  def overlap?({_, {x1, y1}, {w1, h1}}, {_, {x2, y2}, {w2, h2}}) do
    {left1, left2} = {x1, x2}
    {right1, right2} = {x1 + w1, x2 + w2}
    {top1, top2} = {y1, y2}
    {bottom1, bottom2} = {y1 + h1, y2 + h2}

    not (right1 <= left2 or
           right2 <= left1 or
           bottom1 <= top2 or
           bottom2 <= top1)
  end
end
