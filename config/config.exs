import Config
import_config ".env.exs"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

config :aoc, :input,
  year: 2018,
  allow_network?: true,
  session_cookie: System.get_env("ADVENT_OF_CODE_SESSION_COOKIE")
