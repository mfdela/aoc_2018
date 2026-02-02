defmodule Mix.Tasks.Aoc.Generate.Day do
  use Igniter.Mix.Task

  @example "mix aoc.generate.day 1"

  @shortdoc "Generates scaffold for an advent of code solution"
  @moduledoc """
  #{@shortdoc}

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * [day] The day of the month to generate. Defaults to the current day in the Eastern time zone.
  * [year] The year to generate. Defaults to the current year.
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      positional: [{:day, optional: true}]
    }
  end

  def igniter(igniter) do
    day = advent_day(igniter.args.positional[:day])
    year = advent_year()

    full_day_number = String.pad_leading(to_string(day), 2, "0")

    day_module_name = Igniter.Project.Module.parse("Aoc.Day#{full_day_number}")
    test_module_name = Igniter.Project.Module.parse("Aoc.Day#{full_day_number}Test")

    igniter
    |> Igniter.assign(
      day_module_name: day_module_name,
      full_day_number: full_day_number,
      day: day,
      year: year
    )
    |> Igniter.Project.Module.create_module(day_module_name, """
      def part1(args) do
        args
      end

      def part2(args) do
        args
      end
    """)
    |> add_mix_task(1)
    |> add_mix_task(2)
    |> Igniter.Project.Module.create_module(
      test_module_name,
      """
        use ExUnit.Case

        import #{day_module_name}

        def test_input() do
          ""
        end

        test "part1" do
          input = test_input()
          result = part1(input)

          assert result
        end

        test "part2" do
          input = test_input()
          result = part2(input)

          assert result
        end
      """,
      path: Igniter.Project.Module.proper_location(igniter, test_module_name)
      # Igniter.Code.Module.proper_test_location(test_module_name)
    )
  end

  defp add_mix_task(igniter, part) do
    template_path = Path.expand("templates/day_mix_task.eex")

    part_module_name =
      Igniter.Project.Module.parse("Mix.Tasks.D#{igniter.assigns[:full_day_number]}.P#{part}")

    assigns =
      Keyword.merge(
        Map.to_list(igniter.assigns),
        part: part,
        module_name: part_module_name
      )

    Igniter.copy_template(
      igniter,
      template_path,
      Igniter.Project.Module.proper_location(igniter, part_module_name),
      assigns
    )
  end

  defp advent_day(nil) do
    {:ok, now} = DateTime.now("America/New_York")
    now.day
  end

  defp advent_day(day) when is_binary(day) do
    case Integer.parse(day) do
      {day, _} when day in 1..25 ->
        day

      _ ->
        raise ArgumentError, "provide a valid day number from 1–25"
    end
  end

  defp advent_year() do
    config = Application.get_env(:aoc, :input)
    Keyword.get(config, :year, 2018)
  end
end
