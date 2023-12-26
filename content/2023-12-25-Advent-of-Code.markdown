---
title: Advent of Code 2023
summary: Solving the Advent of Code 2023 puzzles in Clojure.
---

Since 2020, every year I solve the [Advent of Code](https://adventofcode.com/)
puzzles.  This post, like [those][Aoc2020] of [previous][Aoc2021]
[years][AoC2022], is an experience report of my 25+ day journey in December.

**Spoiler alert**: If you're still working or planning to work on the puzzles
stop reading now.

# Puzzles

Between December 1 and December 25, a programming puzzle appears every day on
the Advent of Code website.  Each problem has two parts, the second part
unlocks after you complete the first.  To understand each day's puzzle, go to
the website and read the full description (for example [Day 1:
Trebuchet?!](https://adventofcode.com/2023/day/1)).

# Setup

This year again, now the third time, I wrote my solutions in Clojure.  Every
year I understand more of the standard library and I feel I write more
concise and more idiomatic code than in the previous years.

Usually I solved the day's problem before going to work, sometimes I coded a
bit in the evening to polish my solution.

My [Day 14][Day14] and [Day 22][Day22] solutions are slow: they run for about a
hundred seconds to find the solution.  I suspect that these programs would be
more efficient if I wrote them as a loop updating some local mutable state.
Next year, I want to study profiling and optimizing Clojure code.

# Highlights

On [Day 12][Day12] I was proud to find a recursive solution using dynamic
programming.  In previous years,  for example [Day 10 in
2020](https://adventofcode.com/2020/day/10), I struggled with similar problems.

I solved [Day 14][Day14] and [Day 20][Day20] by finding cycles in a periodic
solution.  This is also something I was more comfortable this year than before.

It was difficult to wrap my head around the interval arithmetics required to
solve [Day 5][Day05] and [Day 19][Day19].  Finally, I brute forced Day 5 and
put aside the second part of Day 19 for a few days.

The second parts of [Day 18][Day18], [Day 21][Day21], [Day 23][Day23] and [Day
24][Day24] were the hardest to crack.  I couldn't solve these problems on my
own and I used some help from [Reddit][Reddit].

On [Day 18][Day18] I was on the right track, but I didn't figure out how to
apply [Pick's theorem](https://en.wikipedia.org/wiki/Pick%27s_theorem) to find
the solution.

[Day 21][Day21] was just too hard for me: I had some ideas, but nothing worked.
I failed to recognize the hidden patterns in the input data. A typical Advent
of Code puzzle.

[Day 23][Day23] asked to find the longest path in a labyrinth. This is, as I
learned this year, a much harder problem than finding the shortest path.  I
understood how to reduce the size of the search space, but my code is messy
and I made a lot of mistakes during the implementation.

[Day 24][Day24] was about line intersections.  I understand well the underlying
mathematical models but I failed to find a set of linear equations that yielded
the solution.  During the fourth week, I was tired and impatient to do symbolic
math.

[Day 25][Day25] asked to remove three vertices from a graph to create two
isolated groups of nodes.  Instead of writing code, I solved this problem
graphically: I visualized the graph with the [Graphviz](https://graphviz.org/)
and manually selected the nodes to remove.

# Summary

2023 Advent of Code started well and I had a few small victories on some harder
days.  The second parts of Day 18, Day 21, Day 23 and Day 24 were too hard for
me and I used external help.  As always, on these tough days I learned the
most.

As usual, after solving the puzzles I like to see how others approached the
same problem.  Here are some repositories I regularly checked:

* [Jahn Kornél (Python)](https://github.com/KornelJahn/advent-of-code-2023)
* [Jonathan Paulson (Python)](https://github.com/jonathanpaulson/AdventOfCode/tree/master/2023)
* [Olivier Dormond (Python)](https://github.com/odormond/adventofcode/tree/master/2023)

My solutions are available on [GitHub][Repo].

# Acknowledgments

Thanks [Eric Wastl](https://twitter.com/ericwastl) for creating and running
[Advent of Code](https://adventofcode.com).

I enjoyed exchanging ideas and analyzing solutions with my friend
[Kornél](https://github.com/KornelJahn/).

[AoC2020]: {filename}/2020-12-25-Advent-of-Code.markdown
[AoC2021]: {filename}/2021-12-25-Advent-of-Code.markdown
[AoC2022]: {filename}/2022-12-25-Advent-of-Code.markdown

[Repo]: https://github.com/wagdav/advent-of-code-2023

[Reddit]: https://www.reddit.com/r/adventofcode/

[Day01]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day01.clj
[Day02]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day02.clj
[Day03]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day03.clj
[Day04]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day04.clj
[Day05]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day05.clj
[Day06]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day06.clj
[Day07]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day07.clj
[Day08]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day08.clj
[Day09]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day09.clj
[Day10]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day10.clj
[Day11]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day11.clj
[Day12]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day12.clj
[Day13]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day13.clj
[Day14]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day14.clj
[Day15]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day15.clj
[Day16]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day16.clj
[Day17]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day17.clj
[Day18]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day18.clj
[Day19]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day19.clj
[Day20]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day20.clj
[Day21]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day21.clj
[Day22]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day22.clj
[Day23]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day23.clj
[Day24]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day24.clj
[Day25]: https://github.com/wagdav/advent-of-code-2023/blob/main/src/aoc2023/day25.clj
