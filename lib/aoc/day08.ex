defmodule Aoc.Day08 do
  def part1(args) do
    args
    |> parse_input()
    |> parse_node()
    |> elem(0)
    |> sum_metadata()
  end

  def part2(args) do
    args
    |> parse_input()
    |> parse_node()
    |> elem(0)
    |> node_value()
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  # Parse a node and return {node, remaining_numbers}
  # Node structure: %{children: [...], metadata: [...]}
  def parse_node([num_children, num_metadata | rest]) do
    # Parse all child nodes
    {children, after_children} = parse_children(num_children, rest, [])

    # Take metadata entries
    metadata = Enum.take(after_children, num_metadata)
    remaining = Enum.drop(after_children, num_metadata)

    node = %{children: children, metadata: metadata}
    {node, remaining}
  end

  # Parse N child nodes recursively
  def parse_children(0, remaining, acc), do: {Enum.reverse(acc), remaining}

  def parse_children(n, remaining, acc) when n > 0 do
    {child, after_child} = parse_node(remaining)
    parse_children(n - 1, after_child, [child | acc])
  end

  # Sum all metadata entries in the tree
  def sum_metadata(%{children: children, metadata: metadata}) do
    children_sum = Enum.reduce(children, 0, fn child, acc -> acc + sum_metadata(child) end)
    metadata_sum = Enum.sum(metadata)
    children_sum + metadata_sum
  end

  # Calculate the value of a node according to part 2 rules
  def node_value(%{children: [], metadata: metadata}) do
    # If no children, value is sum of metadata
    Enum.sum(metadata)
  end

  def node_value(%{children: children, metadata: metadata}) do
    # If has children, metadata entries are 1-based indexes into children
    # Sum the values of referenced children
    metadata
    |> Enum.map(fn index ->
      # index is 1-based, convert to 0-based
      # If index is 0 or out of bounds, return 0
      if index > 0 and index <= length(children) do
        Enum.at(children, index - 1) |> node_value()
      else
        0
      end
    end)
    |> Enum.sum()
  end
end
