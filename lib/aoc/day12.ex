defmodule Aoc.Day12 do
  def part1(args) do
    {state, zero_index} =
      args
      |> parse_input()
      |> simulate(20)

    state
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {char, index}, sum ->
      if char == "#", do: sum + index - zero_index, else: sum
    end)
  end

  def part2(args) do
    {initial_state, rules} = parse_input(args)

    # Find when the pattern stabilizes (same shape, just shifting)
    {stable_gen, stable_state, stable_zero, _shift_per_gen} =
      find_stable_pattern({initial_state, rules})

    # Calculate sum at stable generation
    sum_at_stable = calculate_sum(stable_state, stable_zero)

    # Calculate how the sum changes per generation by simulating one more
    {next_state, next_zero} = next_generation(stable_state, rules, stable_zero)
    sum_at_next = calculate_sum(next_state, next_zero)
    sum_delta_per_gen = sum_at_next - sum_at_stable

    # Calculate how many more generations to go
    target = 50_000_000_000
    remaining_gens = target - stable_gen

    # The sum increases linearly after stabilization
    sum_at_stable + sum_delta_per_gen * remaining_gens
  end

  def calculate_sum(state, zero_index) do
    state
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {char, index}, sum ->
      if char == "#", do: sum + index - zero_index, else: sum
    end)
  end

  def find_stable_pattern({initial_state, rules}) do
    # Simulate until we find two consecutive generations with the same pattern
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({initial_state, 0, nil, nil, nil}, fn gen,
                                                               {state, zero_index, prev_state,
                                                                prev_zero, prev_prev_zero} ->
      {new_state, new_zero} = next_generation(state, rules, zero_index)

      # Check if the pattern is the same as previous (just shifted)
      if new_state == prev_state && prev_prev_zero != nil do
        # Pattern has stabilized!
        # The shift per generation is consistent
        shift_per_gen = prev_zero - prev_prev_zero
        # Return current generation, its state and zero index
        {:halt, {gen, new_state, new_zero, shift_per_gen}}
      else
        {:cont, {new_state, new_zero, state, zero_index, prev_zero}}
      end
    end)
  end

  def parse_input(input) do
    [initial_state_string | rules] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)

    initial_state =
      initial_state_string
      |> String.split(":", trim: true)
      |> Enum.at(1)
      |> String.trim()


    rules =
      rules
      |> Enum.map(&String.split(&1, " => ", trim: true))
      |> Enum.map(fn [pattern, result] -> {pattern, result} end)
      |> Enum.into(%{})

    {initial_state, rules}
  end

  def next_generation(state, rules, zero_index) do
    # Add padding to ensure we can evaluate patterns at the edges
    padded_state = "...." <> state <> "...."

    new_state =
      padded_state
      |> String.graphemes()
      |> Enum.chunk_every(5, 1, :discard)
      |> Enum.map(&Enum.join/1)
      |> Enum.map(&Map.get(rules, &1, "."))
      |> Enum.join()

    # When we add 4 dots to the left and process with a sliding window of 5,
    # the first output corresponds to position -2 relative to the original
    new_zero_index = zero_index + 2

    # Trim leading/trailing dots to keep state manageable
    {trimmed_state, trim_offset} = trim_dots(new_state)

    {trimmed_state, new_zero_index - trim_offset}
  end

  def trim_dots(state) do
    left_trim = String.length(state) - String.length(String.trim_leading(state, "."))
    trimmed = state |> String.trim(".")
    {trimmed, left_trim}
  end

  def simulate({initial_state, rules}, generations) do
    Enum.reduce(1..generations, {initial_state, 0}, fn _, {state, zero_index} ->
      next_generation(state, rules, zero_index)
    end)
  end
end
