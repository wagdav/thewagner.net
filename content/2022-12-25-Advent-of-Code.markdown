---
title: Advent of Code 2022
summary: Solving the Advent of Code 2022 puzzles in Clojure.
---

Since 2020, every year I solve the [Advent of Code](https://adventofcode.com/)
puzzles.  This post, like those of [previous][Aoc2020] [years][AoC2021], is an
experience report of my 25+ day journey in December.

**Spoiler alert**: If you're still working or planning to work on the puzzles
stop reading now.

# Puzzles

Between December 1 and December 25, a programming puzzle appears every day at
Advent of Code website.  Each problem has two parts, the second part unlocks
after you complete the first.  To understand each day's puzzle, go to the
website and read the full description (for example [Day 1: Calorie
Counting](https://adventofcode.com/2022/day/1)).

# Setup

In  previous years, I used the Advent of Code to learn a new programming
language.  I used Rust in [2020][Aoc2020], and Clojure in [2021][AoC2021].

This year I stayed with Clojure.  I feel it's a good fit for the Advent of
Code.  Clojure's support for interactive development, the built-in data
structures, and the core library functions allowed me to write clear, concise
code that is almost exclusively about the problem at hand.

I wanted to write idiomatic, readable code.  I don't compete on the global
leaderboard, I don't care about coding speed, code size and performance.

# Highlights

This year I enjoyed all puzzles, even the hardest ones.  The first two weeks
went well and I followed a regular daily schedule: I solved the day's problem
before going to work, sometimes I coded a bit in the evening to polish my
solution.

The difficulties started on [Day 15][Day15].  I didn't pay attention to the
problem description and I came up with an overly complicated, long, and buggy
solution.  Looking back, I should have stepped away from the problem for a day
or two.  Instead, I kept going and my performance in the next days suffered.

Exhausted from the previous day, I took another hit on [Day 16][Day16]  which
was about opening valves to release pressure from a cave.  I tried to formulate
the solution as a shortest-path problem.  My program solved correctly the given
example but it ran out of memory when I gave it the real input.  I also failed
to solve the day as a search problem, as there were too many possibilities to
explore.  Finally, I looked at solutions online and an [implementation using
dynamic programming][Day16] gave me a good solution.

[Day 17][Day17] was about playing a variant of Tetris.  The second part asked
how many rows the board has after dropping a _trillion_ rocks.  Here I also
used some help from others.  The solution runs fast, but the implementation is
clunky: I made it work but I was too tired to clean it up.

[Day 19][Day19] was about building mining robots that can mine different
resources.  From the description, the problem looked similar to that of [Day
16][Day16].  Now I suspect that this similarity was a trap because an efficient
solution ended up looking different.  I borrowed the key idea from [Johnathan
Paulson][Paulson19]: a depth-first search with a limit on the number of mining
robots and the accumulated stock gave a correct and fast solution.

My favorite day was [Day 22][Day22] which was about moving around on a map with
"interesting" boundary conditions.  I loved the plot twist in the second part
which I don't want to spoil.  Many people gave up here, so I'm proud I made it.
Later I'd like to generalize my solution because now it only works on the input
generated for my account.

# Summary

I had a great 2022 Advent of Code, this is my best year so far.  My solutions
are decent and they are my own except parts of [Day 16][Day16], [Day 17][Day17]
and [Day 19][Day19] where I used external help.  Maybe next year I'll recognize
similar problems to solve all days on my own.

Solving the puzzles for 25 days next to my full-time job is exhausting.  Perhaps
for a few days, I pushed too hard and I should take more breaks next year.

As usual, after solving the puzzles I like to see how others approached the
same problem.  Here are some repositories I regularly checked:

* [Jahn Kornél (Julia)](https://github.com/KornelJahn/advent-of-code-2022)
* [Jonathan Paulson (Python)](https://github.com/jonathanpaulson/AdventOfCode/tree/master/2022)
* [Liz Fong Jones (Go)](https://github.com/lizthegrey/adventofcode/tree/main/2021)
* [Olivier Dormond (Python)](https://github.com/odormond/adventofcode/tree/master/2021)
* [Peter Norvig (Python)](https://github.com/norvig/pytudes/blob/main/ipynb/Advent-2022.ipynb)

My solutions are available on [GitHub][Repo].

# Acknowledgments

Thanks [Eric Wastl](https://twitter.com/ericwastl) for creating and running
[Advent of Code](https://adventofcode.com).

I enjoyed exchanging ideas and analyzing solutions with my friend
[Kornél](https://github.com/KornelJahn/).

[AoC2020]: {filename}/2020-12-25-Advent-of-Code.markdown
[AoC2021]: {filename}/2021-12-25-Advent-of-Code.markdown

[Repo]: https://github.com/wagdav/advent-of-code-2022

[Day01]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day01.clj
[Day02]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day02.clj
[Day03]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day03.clj
[Day04]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day04.clj
[Day05]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day05.clj
[Day06]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day06.clj
[Day07]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day07.clj
[Day08]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day08.clj
[Day09]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day09.clj
[Day10]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day10.clj
[Day11]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day11.clj
[Day12]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day12.clj
[Day13]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day13.clj
[Day14]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day14.clj
[Day15]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day15.clj
[Day16]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day16.clj
[Day17]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day17.clj
[Day18]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day18.clj
[Day19]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day19.clj
[Day20]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day20.clj
[Day21]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day21.clj
[Day22]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day22.clj
[Day23]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day23.clj
[Day24]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day24.clj
[Day25]: https://github.com/wagdav/advent-of-code-2022/blob/main/src/aoc2022/day25.clj

[Paulson19]: https://github.com/jonathanpaulson/AdventOfCode/blob/master/2022/19.py
