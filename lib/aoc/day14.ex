defmodule Aoc.Day14 do
  def part1(args) do
    Enum.reduce(1..args, {[3, 7], 0, 1}, fn _, {recipes, elf1, elf2} ->
      combine_recipes(recipes, elf1, elf2)
    end)
    |> elem(0)
    |> Enum.slice(args, 10)
    |> Enum.join("")
  end

  def part2(args) do
    # Convert input to string for pattern matching
    target_str = Integer.to_string(args)

    target_len = String.length(target_str)

    # Use ETS table for efficient random access
    :ets.new(:recipes, [:set, :public, :named_table])
    :ets.insert(:recipes, {0, 3})
    :ets.insert(:recipes, {1, 7})

    result = find_sequence_ets(2, 0, 1, target_str, target_len, "37")

    :ets.delete(:recipes)
    result
  end

  def find_sequence_ets(count, elf1, elf2, target, target_len, last_chars) do
    # Get scores
    [{_, score1}] = :ets.lookup(:recipes, elf1)
    [{_, score2}] = :ets.lookup(:recipes, elf2)

    # Create new recipe(s)
    new_score = score1 + score2
    new_digits = Integer.digits(new_score)

    # Add to ETS and build string of new digits
    new_str = Enum.reduce(new_digits, {count, ""}, fn digit, {idx, str} ->
      :ets.insert(:recipes, {idx, digit})
      {idx + 1, str <> Integer.to_string(digit)}
    end) |> elem(1)

    new_count = count + length(new_digits)

    # Update elf positions
    new_elf1 = rem(elf1 + 1 + score1, new_count)
    new_elf2 = rem(elf2 + 1 + score2, new_count)

    # Check for target in the last few characters
    # We only need to check the tail since we only added 1 or 2 digits
    check_str = last_chars <> new_str
    check_len = String.length(check_str)

    cond do
      # Check if target is at the very end
      check_len >= target_len && String.slice(check_str, (check_len - target_len)..(check_len - 1)) == target ->
        new_count - target_len

      # Check if target is one position before (when 2 digits added)
      check_len >= target_len + 1 && String.slice(check_str, (check_len - target_len - 1)..(check_len - 2)) == target ->
        new_count - target_len - 1

      true ->
        # Keep only the last target_len characters for next check
        keep_str = if check_len > target_len + 5 do
          String.slice(check_str, (check_len - target_len - 2)..(check_len - 1))
        else
          check_str
        end
        find_sequence_ets(new_count, new_elf1, new_elf2, target, target_len, keep_str)
    end
  end

  def combine_recipes(recipes, elf1, elf2) do
    elf1_score = Enum.at(recipes, elf1)
    elf2_score = Enum.at(recipes, elf2)

    new_score = elf1_score + elf2_score
    digits = Integer.digits(new_score)
    new_recipe = Enum.concat(recipes, digits)
    len = length(new_recipe)
    {new_recipe, rem(elf1 + 1 + elf1_score, len), rem(elf2 + 1 + elf2_score, len)}
  end
end
