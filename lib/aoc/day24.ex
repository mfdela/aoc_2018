defmodule Aoc.Day24 do
  defmodule Group do
    defstruct [:id, :army, :units, :hp, :attack_damage, :attack_type, :initiative, :weaknesses, :immunities]

    def effective_power(group), do: group.units * group.attack_damage

    def damage_to(attacker, defender) do
      base_damage = effective_power(attacker)

      cond do
        attacker.attack_type in defender.immunities -> 0
        attacker.attack_type in defender.weaknesses -> base_damage * 2
        true -> base_damage
      end
    end
  end

  def part1(args) do
    {immune_system, infection} = parse_input(args)
    groups = immune_system ++ infection

    final_groups = simulate_combat(groups)
    Enum.sum(Enum.map(final_groups, & &1.units))
  end

  def part2(args) do
    {immune_system, infection} = parse_input(args)
    find_minimum_boost(immune_system, infection)
  end

  def find_minimum_boost(immune_system, infection) do
    # Binary search for the minimum boost
    find_boost(immune_system, infection, 1, 10000)
  end

  def find_boost(immune_system, infection, low, high) when low >= high do
    # Try the current boost
    boosted_immune = apply_boost(immune_system, low)
    groups = boosted_immune ++ infection

    case simulate_combat(groups) do
      final_groups ->
        immune_won? = immune_wins?(final_groups)

        if immune_won? do
          Enum.sum(Enum.map(final_groups, & &1.units))
        else
          # If even the high value doesn't work, we need to go higher
          find_boost(immune_system, infection, low * 2, high * 2)
        end
    end
  end

  def find_boost(immune_system, infection, low, high) do
    mid = div(low + high, 2)

    boosted_immune = apply_boost(immune_system, mid)
    groups = boosted_immune ++ infection

    final_groups = simulate_combat(groups)
    immune_won? = immune_wins?(final_groups)

    if immune_won? do
      # Try a smaller boost
      if mid == low do
        Enum.sum(Enum.map(final_groups, & &1.units))
      else
        # Check if mid - 1 also wins
        boosted_immune_lower = apply_boost(immune_system, mid - 1)
        groups_lower = boosted_immune_lower ++ infection
        final_groups_lower = simulate_combat(groups_lower)
        immune_won_lower? = immune_wins?(final_groups_lower)

        if immune_won_lower? do
          find_boost(immune_system, infection, low, mid - 1)
        else
          Enum.sum(Enum.map(final_groups, & &1.units))
        end
      end
    else
      # Need a bigger boost
      find_boost(immune_system, infection, mid + 1, high)
    end
  end

  def apply_boost(immune_system, boost) do
    Enum.map(immune_system, fn group ->
      %{group | attack_damage: group.attack_damage + boost}
    end)
  end

  def immune_wins?(groups) do
    immune_alive? = Enum.any?(groups, &(&1.army == :immune))
    infection_alive? = Enum.any?(groups, &(&1.army == :infection))

    # Immune wins only if immune has units AND infection has no units
    immune_alive? and not infection_alive?
  end

  def simulate_combat(groups) do
    case combat_round(groups) do
      {^groups, _} -> groups  # Stalemate - no units killed
      {new_groups, _} ->
        immune_alive? = Enum.any?(new_groups, &(&1.army == :immune))
        infection_alive? = Enum.any?(new_groups, &(&1.army == :infection))

        if immune_alive? and infection_alive? do
          simulate_combat(new_groups)
        else
          new_groups
        end
    end
  end

  def combat_round(groups) do
    # Target selection phase
    targets = select_targets(groups)

    # Attacking phase
    attack(groups, targets)
  end

  def select_targets(groups) do
    # Sort by effective power (desc), then initiative (desc)
    sorted_groups = Enum.sort_by(groups, &{-Group.effective_power(&1), -&1.initiative})

    sorted_groups
    |> Enum.reduce({%{}, MapSet.new()}, fn attacker, {targets, chosen} ->
      enemy_groups = Enum.filter(groups, &(&1.army != attacker.army and &1.id not in chosen))

      case find_best_target(attacker, enemy_groups) do
        nil ->
          {targets, chosen}

        target ->
          {Map.put(targets, attacker.id, target.id), MapSet.put(chosen, target.id)}
      end
    end)
    |> elem(0)
  end

  def find_best_target(attacker, defenders) do
    defenders
    |> Enum.map(fn defender ->
      damage = Group.damage_to(attacker, defender)
      {defender, damage}
    end)
    |> Enum.filter(fn {_defender, damage} -> damage > 0 end)
    |> Enum.sort_by(
      fn {defender, damage} ->
        {-damage, -Group.effective_power(defender), -defender.initiative}
      end
    )
    |> case do
      [] -> nil
      [{defender, _damage} | _] -> defender
    end
  end

  def attack(groups, targets) do
    # Sort by initiative (desc)
    sorted_groups = Enum.sort_by(groups, & -&1.initiative)

    {final_groups, total_killed} = Enum.reduce(sorted_groups, {groups, 0}, fn attacker, {current_groups, killed_count} ->
      # Find current state of attacker
      current_attacker = Enum.find(current_groups, &(&1.id == attacker.id))

      # Skip if attacker is dead
      if current_attacker == nil or current_attacker.units <= 0 do
        {current_groups, killed_count}
      else
        target_id = Map.get(targets, attacker.id)

        if target_id do
          current_defender = Enum.find(current_groups, &(&1.id == target_id))

          if current_defender && current_defender.units > 0 do
            damage = Group.damage_to(current_attacker, current_defender)
            units_killed = div(damage, current_defender.hp)
            new_units = max(0, current_defender.units - units_killed)

            updated_groups = Enum.map(current_groups, fn g ->
              if g.id == target_id do
                %{g | units: new_units}
              else
                g
              end
            end)

            {updated_groups, killed_count + units_killed}
          else
            {current_groups, killed_count}
          end
        else
          {current_groups, killed_count}
        end
      end
    end)

    # Remove dead groups
    surviving_groups = Enum.filter(final_groups, &(&1.units > 0))
    {surviving_groups, total_killed}
  end

  def parse_input(input) do
    [immune_section, infection_section] = String.split(input, "\n\n", trim: true)

    immune_groups = parse_army(immune_section, :immune)
    infection_groups = parse_army(infection_section, :infection)

    {immune_groups, infection_groups}
  end

  def parse_army(section, army_type) do
    section
    |> String.split("\n", trim: true)
    |> Enum.drop(1)  # Skip header line
    |> Enum.with_index(1)
    |> Enum.map(fn {line, idx} ->
      parse_group(line, army_type, idx)
    end)
  end

  def parse_group(line, army_type, id) do
    # Example: "17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2"

    regex = ~r/(\d+) units each with (\d+) hit points(?: \(([^)]+)\))? with an attack that does (\d+) (\w+) damage at initiative (\d+)/

    [_, units, hp, modifiers, attack_damage, attack_type, initiative] = Regex.run(regex, line)

    {weaknesses, immunities} = parse_modifiers(modifiers)

    %Group{
      id: {army_type, id},
      army: army_type,
      units: String.to_integer(units),
      hp: String.to_integer(hp),
      attack_damage: String.to_integer(attack_damage),
      attack_type: String.to_atom(attack_type),
      initiative: String.to_integer(initiative),
      weaknesses: weaknesses,
      immunities: immunities
    }
  end

  def parse_modifiers(""), do: {[], []}
  def parse_modifiers(nil), do: {[], []}
  def parse_modifiers(modifiers) do
    parts = String.split(modifiers, "; ", trim: true)

    Enum.reduce(parts, {[], []}, fn part, {weak, immune} ->
      cond do
        String.starts_with?(part, "weak to ") ->
          types = part
                  |> String.replace_prefix("weak to ", "")
                  |> String.split(", ")
                  |> Enum.map(&String.to_atom/1)
          {weak ++ types, immune}

        String.starts_with?(part, "immune to ") ->
          types = part
                  |> String.replace_prefix("immune to ", "")
                  |> String.split(", ")
                  |> Enum.map(&String.to_atom/1)
          {weak, immune ++ types}

        true ->
          {weak, immune}
      end
    end)
  end
end
