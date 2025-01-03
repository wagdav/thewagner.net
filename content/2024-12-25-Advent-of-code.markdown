---
title: Advent of Code 2024
summary: Solving the Advent of Code 2024 puzzles in Clojure.
---

Since 2020, every year I solve the [Advent of Code](https://adventofcode.com/)
puzzles.  Also, every year I write an experience report about my 25+ day
journey in December.  Read my thoughts about previous years here:
[2020][Aoc2020], [2021][Aoc2021], [2022][AoC2022] and [2023][AoC2023].

**Spoiler alert**: If you still work or plan to work on the puzzles, stop
reading now.

# Puzzles

Between December 1 and December 25, a programming puzzle appears every day on
the Advent of Code website.  Each problem has two parts, the second part
unlocks after you complete the first.  To understand each day's puzzle, go to
the website and read the full description (for example [Day 1: Historian
Hysteria](https://adventofcode.com/2024/day/1)).

# Setup

My setup and goal remain the same as in the previous years: I use Clojure and I
try to write succinct and comprehensible programs.

I don't have a specific library of helper functions for the Advent of Code, but
I have a [best-first search implementation][search] that I find useful in many
problems. This year -- in particular in days [16][Day16], [18][Day18], and
[20][Day20] -- I expressed the solution using this function.

My [Day 16][Day16], [Day 22][Day22] and [Day 23][Day23] solutions run for about
a minute, but I didn't have the energy to optimize them.

# Highlights

The first difficulty arrived on [Day 12][Day12].  The puzzle asked for counting
the straight edges of polygonal "gardens".  Initially I didn't find a good
approach for identifying a garden's boundary.  When I started to track the
normal of each point that form the boundary, my solution started to make sense.

I solved [Day 13][Day13] with pen and paper then I implemented the resulting
formula in code.

[Day 14][Day14] had a picture of a Christmas tree hidden in the solution, so I wrote:

```text
(defn solve-part2 [input]
  (first (🎄 input)))
```

[Day 15][Day15] reminded me of
[Sokoban](https://en.wikipedia.org/wiki/Sokoban), one of the first games I
played on a computer.  I enjoyed this puzzle even if the second part of took me
a few attempts to get it right.  I experimented with using Clojure's dynamic
bindings to write  code that solve both parts of the puzzle.

Debugging the assembly code in the second part of [Day 17][Day17] went much
better than in a [similar problem in
2021](https://adventofcode.com/2021/day/24).  I worked on this problem together
with a colleague which made it even more fun.

I couldn't solve the second part of [Day 21][Day21].  The puzzle asked to find
a shortest command sequence to control a robot pressing buttons on a numeric
keypad using a series of directional keypads.  I keep thinking about this
problem, but so far I didn't have the motivation to go back to it.

On [Day 24][Day24] I didn't write any code for the second part.  The puzzle
asked for finding four incorrectly wired logic gates of a [full
adder](https://en.wikipedia.org/wiki/Adder_(electronics)#Full_adder).  Using
Graphviz, I generated a diagram from the puzzle input and I looked for nodes
which caused visible irregularities.

# Summary

I could solve all but one problem during the 2024 Advent of Code: my best year
so far.

You can read the code of my solutions on [GitHub][Repo].

# Acknowledgments

Thanks [Eric Wastl](https://twitter.com/ericwastl) for creating and running
[Advent of Code](https://adventofcode.com).

[AoC2020]: {filename}/2020-12-25-Advent-of-Code.markdown
[AoC2021]: {filename}/2021-12-25-Advent-of-Code.markdown
[AoC2022]: {filename}/2022-12-25-Advent-of-Code.markdown
[AoC2023]: {filename}/2023-12-25-Advent-of-Code.markdown

[Repo]: https://github.com/wagdav/advent-of-code-2024

[Reddit]: https://www.reddit.com/r/adventofcode/

[search]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/search.clj#L30

[Day01]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day01.clj
[Day02]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day02.clj
[Day03]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day03.clj
[Day04]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day04.clj
[Day05]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day05.clj
[Day06]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day06.clj
[Day07]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day07.clj
[Day08]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day08.clj
[Day09]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day09.clj
[Day10]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day10.clj
[Day11]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day11.clj
[Day12]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day12.clj
[Day13]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day13.clj
[Day14]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day14.clj
[Day15]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day15.clj
[Day16]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day16.clj
[Day17]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day17.clj
[Day18]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day18.clj
[Day19]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day19.clj
[Day20]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day20.clj
[Day21]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day21.clj
[Day22]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day22.clj
[Day23]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day23.clj
[Day24]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day24.clj
[Day25]: https://github.com/wagdav/advent-of-code/blob/main/src/aoc2024/day25.clj
