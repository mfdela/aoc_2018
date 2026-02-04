defmodule Aoc.Day07 do
  def part1(args) do
    dependencies = parse_input(args)

    # Build a map of step -> list of steps that depend on it
    # Also collect all unique steps
    all_steps = dependencies |> all_steps()

    # Build dependency map: step -> set of prerequisites
    prereqs = dependencies |> prereqs()

    # Perform topological sort with alphabetical ordering
    topological_sort(all_steps, prereqs, [])
    |> Enum.reverse()
    |> Enum.join("")
  end

  def part2(args, num_workers \\ 5, base_time \\ 60) do
    dependencies = parse_input(args)

    # Collect all unique steps
    all_steps = dependencies |> all_steps()

    # Build dependency map: step -> set of prerequisites
    prereqs = dependencies |> prereqs()

    # Simulate parallel execution
    simulate_workers(all_steps, prereqs, num_workers, base_time, 0, [], MapSet.new())
  end

  defp simulate_workers(
         remaining_steps,
         prereqs,
         num_workers,
         base_time,
         current_time,
         workers,
         completed
       ) do
    # workers is a list of {step, finish_time}

    # Check if we're done
    if MapSet.size(remaining_steps) == 0 and Enum.empty?(workers) do
      current_time
    else
      # Find workers that finish at current time
      {finished_now, still_working} =
        Enum.split_with(workers, fn {_step, time} -> time == current_time end)

      # Mark finished steps as completed
      new_completed =
        finished_now
        |> Enum.map(fn {step, _} -> step end)
        |> Enum.reduce(completed, fn step, acc -> MapSet.put(acc, step) end)

      # Update prerequisites by removing completed steps
      new_prereqs =
        prereqs
        |> Enum.map(fn {step, deps} ->
          {step,
           Enum.reduce(new_completed, deps, fn completed_step, d ->
             MapSet.delete(d, completed_step)
           end)}
        end)
        |> Enum.into(%{})

      # Find available steps (no prerequisites and not already being worked on or completed)
      working_steps = Enum.map(still_working, fn {step, _} -> step end) |> MapSet.new()

      available =
        remaining_steps
        |> Enum.filter(fn step ->
          deps = Map.get(new_prereqs, step, MapSet.new())
          MapSet.size(deps) == 0 and not MapSet.member?(working_steps, step)
        end)
        |> Enum.sort()

      # Assign work to available workers
      available_workers = num_workers - length(still_working)
      steps_to_start = Enum.take(available, available_workers)

      new_workers =
        steps_to_start
        |> Enum.map(fn step ->
          duration = base_time + (step |> String.to_charlist() |> hd() |> Kernel.-(64))
          {step, current_time + duration}
        end)
        |> Kernel.++(still_working)

      # Remove started steps from remaining
      new_remaining =
        Enum.reduce(steps_to_start, remaining_steps, fn step, acc ->
          MapSet.delete(acc, step)
        end)

      # Advance time to next event (either a worker finishes or we're done)
      next_time =
        if Enum.empty?(new_workers) do
          current_time
        else
          new_workers |> Enum.map(fn {_, time} -> time end) |> Enum.min()
        end

      simulate_workers(
        new_remaining,
        new_prereqs,
        num_workers,
        base_time,
        next_time,
        new_workers,
        new_completed
      )
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [from, to] =
        Regex.run(~r/Step (\w) must be finished before step (\w) can begin./, line,
          capture: :all_but_first
        )

      {from, to}
    end)
  end

  def all_steps(dependencies) do
    dependencies
    |> Enum.flat_map(fn {from, to} -> [from, to] end)
    |> Enum.uniq()
    |> MapSet.new()
  end

  def prereqs(dependencies) do
    Enum.reduce(dependencies, %{}, fn {from, to}, acc ->
      Map.update(acc, to, MapSet.new([from]), fn set -> MapSet.put(set, from) end)
    end)
  end

  def topological_sort(remaining_steps, prereqs, result) do
    if MapSet.size(remaining_steps) == 0 do
      result
    else
      # Find all steps with no prerequisites
      available =
        remaining_steps
        |> Enum.filter(fn step ->
          deps = Map.get(prereqs, step, MapSet.new())
          MapSet.size(deps) == 0
        end)
        |> Enum.sort()

      # Pick the first alphabetically
      next_step = hd(available)

      # Remove this step from remaining and from all prerequisites
      new_remaining = MapSet.delete(remaining_steps, next_step)

      new_prereqs =
        prereqs
        |> Enum.map(fn {step, deps} -> {step, MapSet.delete(deps, next_step)} end)
        |> Enum.into(%{})

      topological_sort(new_remaining, new_prereqs, [next_step | result])
    end
  end
end
