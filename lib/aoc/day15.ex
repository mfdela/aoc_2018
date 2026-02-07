defmodule Aoc.Day15 do
  defmodule Unit do
    defstruct [:id, :type, :pos, :hp, :attack]

    def new(id, type, pos) do
      %Unit{id: id, type: type, pos: pos, hp: 200, attack: 3}
    end
  end

  def part1(input) do
    {grid, units} = parse_input(input)
    {rounds, remaining_units} = simulate(grid, units)

    total_hp = Enum.reduce(remaining_units, 0, fn {_id, unit}, acc ->
      if unit.hp > 0, do: acc + unit.hp, else: acc
    end)
    rounds * total_hp
  end

  def part2(input) do
    {grid, initial_units} = parse_input(input)
    initial_elf_count = Enum.count(initial_units, fn {_id, u} -> u.type == :elf end)

    # Binary search for minimum elf attack power
    find_minimum_attack_power(grid, initial_units, initial_elf_count, 4, 200)
  end

  def find_minimum_attack_power(grid, initial_units, elf_count, low, high) do
    if low >= high do
      # Found the minimum - run simulation one more time to get the outcome
      units = set_elf_attack(initial_units, low)
      {rounds, final_units} = simulate(grid, units)
      total_hp = Enum.reduce(final_units, 0, fn {_id, u}, acc ->
        if u.hp > 0, do: acc + u.hp, else: acc
      end)
      rounds * total_hp
    else
      mid = div(low + high, 2)
      units = set_elf_attack(initial_units, mid)

      case simulate_check_elf_deaths(grid, units, elf_count) do
        {:elves_win, true} ->
          # All elves survived, try lower attack
          find_minimum_attack_power(grid, initial_units, elf_count, low, mid)
        _ ->
          # Elves died or lost, need higher attack
          find_minimum_attack_power(grid, initial_units, elf_count, mid + 1, high)
      end
    end
  end

  def set_elf_attack(units, attack_power) do
    units
    |> Enum.map(fn {id, unit} ->
      if unit.type == :elf do
        {id, %{unit | attack: attack_power}}
      else
        {id, unit}
      end
    end)
    |> Enum.into(%{})
  end

  def simulate_check_elf_deaths(grid, units, expected_elf_count) do
    {_rounds, final_units} = simulate(grid, units)

    living_elves = Enum.count(final_units, fn {_id, u} -> u.type == :elf && u.hp > 0 end)
    living_goblins = Enum.count(final_units, fn {_id, u} -> u.type == :goblin && u.hp > 0 end)

    cond do
      living_elves == expected_elf_count && living_goblins == 0 ->
        {:elves_win, true}
      living_elves < expected_elf_count ->
        {:elves_win, false}
      true ->
        {:goblins_win, false}
    end
  end

  def parse_input(input) do
    lines = String.split(input, "\n", trim: true)

    {grid, units, _id} =
      lines
      |> Enum.with_index()
      |> Enum.reduce({%{}, %{}, 0}, fn {line, y}, {grid_acc, units_acc, id} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({grid_acc, units_acc, id}, fn {char, x}, {g, u, next_id} ->
          pos = {x, y}
          case char do
            "#" -> {Map.put(g, pos, :wall), u, next_id}
            "." -> {Map.put(g, pos, :open), u, next_id}
            "E" ->
              unit = Unit.new(next_id, :elf, pos)
              {Map.put(g, pos, :open), Map.put(u, next_id, unit), next_id + 1}
            "G" ->
              unit = Unit.new(next_id, :goblin, pos)
              {Map.put(g, pos, :open), Map.put(u, next_id, unit), next_id + 1}
            _ -> {g, u, next_id}
          end
        end)
      end)

    {grid, units}
  end

  def simulate(grid, units) do
    do_round(grid, units, 0)
  end

  def do_round(grid, units, round_num) do
    # Get units in reading order
    unit_order = units
    |> Enum.map(fn {id, unit} -> {id, unit.pos} end)
    |> Enum.sort_by(fn {_id, {x, y}} -> {y, x} end)
    |> Enum.map(fn {id, _pos} -> id end)

    case process_turns(grid, units, unit_order, false) do
      {:complete, new_units} -> do_round(grid, new_units, round_num + 1)
      {:ended, final_units, incomplete} ->
        {if(incomplete, do: round_num, else: round_num + 1), final_units}
    end
  end

  def process_turns(_grid, units, [], _incomplete) do
    {:complete, units}
  end

  def process_turns(grid, units, [unit_id | rest], incomplete) do
    unit = units[unit_id]

    # Skip if unit is dead
    if !unit || unit.hp <= 0 do
      process_turns(grid, units, rest, incomplete)
    else
      # Check if there are enemies left
      enemies = get_enemies(units, unit.type)

      if Enum.empty?(enemies) do
        # Combat ends
        {:ended, units, true}
      else
        # Take turn
        new_units = take_turn(grid, units, unit_id)
        process_turns(grid, new_units, rest, incomplete)
      end
    end
  end

  def get_enemies(units, type) do
    enemy_type = if type == :elf, do: :goblin, else: :elf
    units
    |> Enum.filter(fn {_id, unit} -> unit.type == enemy_type && unit.hp > 0 end)
    |> Enum.map(fn {_id, unit} -> unit end)
  end

  def take_turn(grid, units, unit_id) do
    unit = units[unit_id]
    enemies = get_enemies(units, unit.type)

    # Move if not in range
    unit_after_move = if in_range?(unit, enemies) do
      unit
    else
      move_unit(grid, units, unit) || unit
    end

    # Update position in units map
    units = Map.put(units, unit_id, unit_after_move)

    # Attack
    attack_unit(units, unit_after_move)
  end

  def in_range?(unit, enemies) do
    Enum.any?(enemies, fn enemy ->
      manhattan_distance(unit.pos, enemy.pos) == 1
    end)
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def move_unit(grid, units, unit) do
    enemies = get_enemies(units, unit.type)
    occupied = get_occupied_positions(units, unit.id)

    # Find all in-range positions (adjacent to enemies)
    in_range_positions = enemies
    |> Enum.flat_map(fn enemy -> get_adjacent_open(grid, enemy.pos, occupied) end)
    |> Enum.uniq()

    if Enum.empty?(in_range_positions) do
      nil
    else
      # BFS from current position to find distances to all reachable in-range positions
      distances = bfs_distances(grid, unit.pos, occupied)

      # Find reachable in-range positions with their distances
      reachable_targets = in_range_positions
      |> Enum.filter(fn pos -> Map.has_key?(distances, pos) end)
      |> Enum.map(fn pos -> {pos, distances[pos]} end)

      if Enum.empty?(reachable_targets) do
        nil
      else
        # Choose target: minimum distance, ties broken by reading order
        {target_pos, _min_dist} = Enum.min_by(reachable_targets, fn {pos, dist} ->
          {dist, elem(pos, 1), elem(pos, 0)}
        end)

        # Find which adjacent square to step into
        next_pos = find_next_step(grid, unit.pos, target_pos, occupied)
        if next_pos, do: %{unit | pos: next_pos}, else: nil
      end
    end
  end

  def get_occupied_positions(units, exclude_id) do
    units
    |> Enum.filter(fn {id, unit} -> id != exclude_id && unit.hp > 0 end)
    |> Enum.map(fn {_id, unit} -> unit.pos end)
    |> MapSet.new()
  end

  def get_adjacent_open(grid, {x, y}, occupied) do
    [{0, -1}, {-1, 0}, {1, 0}, {0, 1}]
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(fn pos ->
      grid[pos] == :open && !MapSet.member?(occupied, pos)
    end)
  end

  # BFS from start position, returns a map of position -> distance
  def bfs_distances(grid, start, occupied) do
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])
    distances = %{start => 0}

    bfs_distances_loop(grid, queue, visited, distances, occupied)
  end

  def bfs_distances_loop(grid, queue, visited, distances, occupied) do
    case :queue.out(queue) do
      {:empty, _} -> distances
      {{:value, {pos, dist}}, new_queue} ->
        # Get adjacent positions in reading order: up, left, right, down
        neighbors = get_adjacent_open(grid, pos, occupied)
        |> Enum.reject(&MapSet.member?(visited, &1))

        new_visited = Enum.reduce(neighbors, visited, &MapSet.put(&2, &1))
        new_distances = Enum.reduce(neighbors, distances, fn n, acc ->
          Map.put(acc, n, dist + 1)
        end)
        new_queue = Enum.reduce(neighbors, new_queue, fn n, q ->
          :queue.in({n, dist + 1}, q)
        end)

        bfs_distances_loop(grid, new_queue, new_visited, new_distances, occupied)
    end
  end

  # Find which adjacent square to step into to reach target
  def find_next_step(grid, start, target, occupied) do
    # For each adjacent square (in reading order: up, left, right, down)
    # BFS to see if it can reach the chosen target
    # Choose the one with minimum distance to target
    adjacent = get_adjacent_open(grid, start, occupied)

    if Enum.empty?(adjacent) do
      nil
    else
      # For each adjacent position, calculate distance to target
      # The current position (start) should not be considered occupied
      # since the unit is moving out of it
      adjacent_with_distances = adjacent
      |> Enum.map(fn adj_pos ->
        # BFS from adjacent position to target
        distances = bfs_distances(grid, adj_pos, occupied)
        dist = Map.get(distances, target, :infinity)
        {adj_pos, dist}
      end)
      |> Enum.filter(fn {_pos, dist} -> dist != :infinity end)

      if Enum.empty?(adjacent_with_distances) do
        nil
      else
        # Choose minimum distance, ties broken by reading order
        {next_pos, _dist} = Enum.min_by(adjacent_with_distances, fn {pos, dist} ->
          {dist, elem(pos, 1), elem(pos, 0)}
        end)
        next_pos
      end
    end
  end

  def attack_unit(units, attacker) do
    enemies = get_enemies(units, attacker.type)

    # Find adjacent enemies
    adjacent = enemies
    |> Enum.filter(fn enemy ->
      manhattan_distance(attacker.pos, enemy.pos) == 1
    end)

    if Enum.empty?(adjacent) do
      units
    else
      # Choose target: lowest HP, then reading order
      target = Enum.min_by(adjacent, fn e -> {e.hp, elem(e.pos, 1), elem(e.pos, 0)} end)

      # Deal damage
      new_hp = target.hp - attacker.attack
      updated_target = %{target | hp: new_hp}

      Map.put(units, target.id, updated_target)
    end
  end
end
