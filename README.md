# Aoc2018

This is a project to solve the Advent of Code 2018 puzzles in [Elixir](https://elixir-lang.org/).

The scaffolding for the project is heavily lifted from [advent-generator](https://github.com/ChristianAlexander/advent-generator)
and uses [Igniter](https://github.com/ash-project/igniter) to generate each day project files and downloading input files.
You need to hardcode the year in the `config.exs` file (I like to have a different repo for each year).


## Usage
```
mix aoc.generate.day 1
mix d01.p1
mix d01.p2
```
