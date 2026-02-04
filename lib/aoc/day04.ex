defmodule AoC.Day04.GuardShift do
  defstruct [:guard_id, :shifts]
end

defmodule AoC.Day04.Shift do
  defstruct [:day, :asleep_minutes]
end

defmodule Aoc.Day04 do
  def part1(args) do
    args
    |> parse_input()
    |> schedule()
    |> find_sleepiest_guard()
    |> find_sleepiest_minute()
    |> then(fn {guard_id, minute} -> guard_id * minute end)
  end

  def part2(args) do
    args
    |> parse_input()
    |> schedule()
    |> find_most_frequent_guard_minute()
    |> then(fn {guard_id, minute, _count} -> guard_id * minute end)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.sort_by(&elem(&1, 0), NaiveDateTime)
  end

  def parse_line(line) do
    [time, action] =
      Regex.run(~r/\[(\d+-\d+-\d+ \d+:\d+)\] (.*)/, line, capture: :all_but_first)

    {:ok, ts} = NaiveDateTime.from_iso8601(time <> ":00")

    case action do
      "falls asleep" ->
        {ts, :sleep}

      "wakes up" ->
        {ts, :wake}

      _ ->
        {ts,
         {:guard,
          Regex.run(~r/#(\d+)/, action, capture: :all_but_first)
          |> List.first()
          |> String.to_integer()}}
    end
  end

  def schedule(records) do
    {_guard, _sleep_start, guardshifts} =
      for {ts, action} <- records, reduce: {nil, nil, []} do
        {current_guard, sleep_start, guardshifts} ->

          case action do
            {:guard, id} ->
              # New guard starts shift
              {id, nil, guardshifts}

            :sleep ->
              # Guard falls asleep, record the start time
              {current_guard, ts, guardshifts}

            :wake ->
              # Guard wakes up, add the sleep range to their shifts
              day = {ts.year, ts.month, ts.day}
              sleep_range = sleep_start.minute..(ts.minute - 1)

              updated_guardshifts = add_sleep_to_guard(guardshifts, current_guard, day, sleep_range)
              {current_guard, nil, updated_guardshifts}
          end
      end

    guardshifts
  end

  def add_sleep_to_guard(guardshifts, guard_id, day, sleep_range) do
    case Enum.find_index(guardshifts, fn g -> g.guard_id == guard_id end) do
      nil ->
        # Guard not in list yet, create new GuardShift
        new_guard = %AoC.Day04.GuardShift{
          guard_id: guard_id,
          shifts: [%AoC.Day04.Shift{day: day, asleep_minutes: [sleep_range]}]
        }
        [new_guard | guardshifts]

      index ->
        # Guard exists, update their shifts
        guard = Enum.at(guardshifts, index)
        updated_guard = add_shift_to_guard(guard, day, sleep_range)
        List.replace_at(guardshifts, index, updated_guard)
    end
  end

  def add_shift_to_guard(guard, day, sleep_range) do
    shifts = guard.shifts || []

    case Enum.find_index(shifts, fn s -> s.day == day end) do
      nil ->
        # No shift for this day yet, create new one
        new_shift = %AoC.Day04.Shift{day: day, asleep_minutes: [sleep_range]}
        %{guard | shifts: [new_shift | shifts]}

      index ->
        # Shift exists for this day, add sleep range to it
        shift = Enum.at(shifts, index)
        updated_shift = %{shift | asleep_minutes: [sleep_range | shift.asleep_minutes]}
        %{guard | shifts: List.replace_at(shifts, index, updated_shift)}
    end
  end

  def find_sleepiest_guard(guardshifts) do
    guardshifts
    |> Enum.max_by(&total_sleep_minutes/1)
  end

  def total_sleep_minutes(%AoC.Day04.GuardShift{shifts: shifts}) do
    shifts
    |> Enum.flat_map(fn shift -> shift.asleep_minutes end)
    |> Enum.map(&Range.size/1)
    |> Enum.sum()
  end



  def most_frequent_minute(%AoC.Day04.GuardShift{shifts: shifts}) do
    shifts
    |> Enum.flat_map(fn shift ->
      shift.asleep_minutes
      |> Enum.flat_map(&Enum.to_list/1)
    end)
    |> Enum.frequencies()
    |> Enum.max_by(fn {_minute, count} -> count end)
  end

  def find_sleepiest_minute(%AoC.Day04.GuardShift{guard_id: guard_id} = guard) do
    {minute, _count} = most_frequent_minute(guard)
    {guard_id, minute}
  end

  def find_most_frequent_guard_minute(guardshifts) do
    guardshifts
    |> Enum.flat_map(fn %AoC.Day04.GuardShift{guard_id: guard_id, shifts: shifts} ->
      # Get all minutes this guard slept
      minutes = 
        shifts
        |> Enum.flat_map(fn shift ->
          shift.asleep_minutes
          |> Enum.flat_map(&Enum.to_list/1)
        end)
      
      # Get frequency of each minute for this guard
      minutes
      |> Enum.frequencies()
      |> Enum.map(fn {minute, count} -> {guard_id, minute, count} end)
    end)
    |> Enum.max_by(fn {_guard_id, _minute, count} -> count end)
  end
end
