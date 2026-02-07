defmodule Aoc.Day13 do
  def part1(input) do
    {tracks, carts} = parse_input(input)

    simulate_until_crash(tracks, carts)
  end

  def part2(input) do
    {tracks, carts} = parse_input(input)

    simulate_until_one_cart(tracks, carts)
  end

  def parse_input(input) do
    lines = String.split(input, "\n", trim: false)

    {tracks, carts} =
      lines
      |> Enum.with_index()
      |> Enum.reduce({%{}, []}, fn {line, y}, {tracks_acc, carts_acc} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({tracks_acc, carts_acc}, fn {char, x}, {t_acc, c_acc} ->
          case char do
            "^" -> {Map.put(t_acc, {x, y}, "|"), [{x, y, :up, :left} | c_acc]}
            "v" -> {Map.put(t_acc, {x, y}, "|"), [{x, y, :down, :left} | c_acc]}
            "<" -> {Map.put(t_acc, {x, y}, "-"), [{x, y, :left, :left} | c_acc]}
            ">" -> {Map.put(t_acc, {x, y}, "-"), [{x, y, :right, :left} | c_acc]}
            " " -> {t_acc, c_acc}
            track when track in ["|", "-", "/", "\\", "+"] ->
              {Map.put(t_acc, {x, y}, track), c_acc}
            _ -> {t_acc, c_acc}
          end
        end)
      end)

    {tracks, Enum.reverse(carts)}
  end

  def simulate_until_crash(tracks, carts) do
    case tick(tracks, carts) do
      {:crash, x, y} -> {x, y}
      {:ok, new_carts} -> simulate_until_crash(tracks, new_carts)
    end
  end

  def simulate_until_one_cart(tracks, carts) do
    case tick_remove_crashes(tracks, carts) do
      {:last_cart, x, y} -> {x, y}
      {:ok, new_carts} -> simulate_until_one_cart(tracks, new_carts)
    end
  end

  def tick(tracks, carts) do
    # Sort carts by position (top to bottom, left to right)
    sorted_carts = Enum.sort_by(carts, fn {x, y, _, _} -> {y, x} end)

    move_carts(tracks, sorted_carts, [])
  end

  def move_carts(_tracks, [], moved), do: {:ok, Enum.reverse(moved)}

  def move_carts(tracks, [{x, y, dir, next_turn} | rest], moved) do
    # Move the cart
    {new_x, new_y} = move_position(x, y, dir)

    # Check for collision with already moved carts or carts yet to move
    all_other_carts = moved ++ rest

    if Enum.any?(all_other_carts, fn {cx, cy, _, _} -> cx == new_x && cy == new_y end) do
      {:crash, new_x, new_y}
    else
      # Update direction based on track
      track = tracks[{new_x, new_y}]
      {new_dir, new_next_turn} = update_direction(dir, track, next_turn)

      move_carts(tracks, rest, [{new_x, new_y, new_dir, new_next_turn} | moved])
    end
  end

  def tick_remove_crashes(tracks, carts) do
    # Sort carts by position (top to bottom, left to right)
    sorted_carts = Enum.sort_by(carts, fn {x, y, _, _} -> {y, x} end)

    case move_carts_remove_crashes(tracks, sorted_carts, []) do
      [cart] ->
        {x, y, _, _} = cart
        {:last_cart, x, y}
      carts -> {:ok, carts}
    end
  end

  def move_carts_remove_crashes(_tracks, [], moved), do: Enum.reverse(moved)

  def move_carts_remove_crashes(tracks, [{x, y, dir, next_turn} | rest], moved) do
    # Move the cart
    {new_x, new_y} = move_position(x, y, dir)

    # Check for collision
    crashed_in_moved = Enum.find_index(moved, fn {cx, cy, _, _} -> cx == new_x && cy == new_y end)
    crashed_in_rest = Enum.find_index(rest, fn {cx, cy, _, _} -> cx == new_x && cy == new_y end)

    cond do
      crashed_in_moved != nil ->
        # Remove the crashed cart from moved and don't add current cart
        new_moved = List.delete_at(moved, crashed_in_moved)
        move_carts_remove_crashes(tracks, rest, new_moved)

      crashed_in_rest != nil ->
        # Remove the crashed cart from rest and don't add current cart
        new_rest = List.delete_at(rest, crashed_in_rest)
        move_carts_remove_crashes(tracks, new_rest, moved)

      true ->
        # No crash, update direction and continue
        track = tracks[{new_x, new_y}]
        {new_dir, new_next_turn} = update_direction(dir, track, next_turn)
        move_carts_remove_crashes(tracks, rest, [{new_x, new_y, new_dir, new_next_turn} | moved])
    end
  end

  def move_position(x, y, :up), do: {x, y - 1}
  def move_position(x, y, :down), do: {x, y + 1}
  def move_position(x, y, :left), do: {x - 1, y}
  def move_position(x, y, :right), do: {x + 1, y}

  def update_direction(dir, track, next_turn) do
    case track do
      "|" -> {dir, next_turn}
      "-" -> {dir, next_turn}
      "/" -> {turn_slash(dir), next_turn}
      "\\" -> {turn_backslash(dir), next_turn}
      "+" -> turn_at_intersection(dir, next_turn)
      nil -> raise "Cart moved off track at direction #{dir}, track is nil"
    end
  end

  def turn_slash(:up), do: :right
  def turn_slash(:down), do: :left
  def turn_slash(:left), do: :down
  def turn_slash(:right), do: :up

  def turn_backslash(:up), do: :left
  def turn_backslash(:down), do: :right
  def turn_backslash(:left), do: :up
  def turn_backslash(:right), do: :down

  def turn_at_intersection(dir, :left) do
    new_dir = case dir do
      :up -> :left
      :left -> :down
      :down -> :right
      :right -> :up
    end
    {new_dir, :straight}
  end

  def turn_at_intersection(dir, :straight) do
    {dir, :right}
  end

  def turn_at_intersection(dir, :right) do
    new_dir = case dir do
      :up -> :right
      :right -> :down
      :down -> :left
      :left -> :up
    end
    {new_dir, :left}
  end
end
