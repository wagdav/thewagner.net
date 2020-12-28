---
title: Advent of Code 2020
---

This year I participated the first time in the [Advent of
Code](https://adventofcode.com/), a series of programming puzzles before
Christmas.  This post is an experience report of my 25+ day journey in
December.

**Spoiler alert**: If you're still working or planning to work on the puzzles
stop reading now.

# Puzzles

From December 1 to December 25, a programming puzzle appears each day at Advent
of Code website.  To understand each day's two-part puzzle, go to the website
and read the full description (for example [Day 1: Report
Repair](https://adventofcode.com/2020/day/1)).

# Setup

I decided to write all solutions in Rust because I wanted to learn the
language.  This was my only "hard" requirement, the rest was just to have fun.
After solving the first couple of puzzles I set the following boundaries for
myself:

* _Language_: I write the solutions in Rust with minimal external dependencies.
  I used the only the [regex](https://docs.rs/regex) and
  [itertools](https://docs.rs/itertools) crates.
* _Independent programs_: Each day's solution is a separate, independent
  executable with no code reuse among the solutions.
* _Tests_: I always transform the provided examples into automated tests.
  Sometimes I add more tests, but I'm not strict about them.  [GitHub
  Actions][Workflow] run the tests on every commit.
* _Explore_: I rewrite code as I learn new features of the Rust language and
  its standard library.  The code what you see now in the [GitHub
  repository][Repo] is often not my first attempt.

I also decided what were _not_ my goals:

* _No code golf_: I wanted readable and concise solutions, but in no way I
  tried to minimize the lines of source code.
* _Coding speed_: I had no ambition (or chance) competing on the global
  leaderboard.  I solved the problems at my own speed, next to my full-time
  job.  Often it took me days to finish a puzzle.
* _Code performance_:  I didn't measure or optimize my code's performance
  in any way.  Nevertheless, the execution time of every solution is less than
  a few seconds.

# Highlights

Variations on [Conway's Game of Life][Life] appeared on multiple days: on [day
11][Day11] the cells evolved on a fixed grid, on [day 17][Day17] in three and
four dimensions, and on [day 24][Day24] the solution was expected on a
hexagonal grid.  I enjoyed these problems and learned a lot about Rust
iterators and iterator adapters.

[Day 18][Day18] was about a small expression evaluator with custom precedence
and associativity rules.  I learned about [Dijkstra's shunting yard
algorithm][ShuntingYard] and I used it to transform the expressions specified
in infix notation to reverse Polish notation.

The second part of the puzzle on [day 13][Day13] caused me headaches.
Someone on a Reddit thread suggested that the [Chinese remainder
theorem][Remainder] is relevant here.  I learned the basics of this theorem
and recognized how to use it in the solution.

[Day 10][Day10] took me multiple days to finish.  I failed recognize that
relevant strategy to solve this puzzle was [dynamic programming][Dynamic] on
which [I even wrote an article]({filename}2018-04-30-Coin-exchange.markdown).
Perhaps I should read it again...

# In the weeds

There were also days when the problem itself was not particularly difficult,
but I still struggled.  On these days I ended up with code that sort of works,
but not particularly nice:

* [Day 19][Day19]: The problem input represented a language akin to regular
  expressions.  My parsing code became quite messy, maybe I should have used
  actual regular expressions to parse the input file.
* [Day 20][Day20]: I made many mistakes during the implementation, the solution
  was tedious with much bookkeeping and little reward.
* [Day 21][Day21]: I couldn't connect to the problem because I found it too
  convoluted.  After I looked at other people's solution it was clear that I
  was missing the underlying search algorithm therefore my implementation
  turned out to be less than great.

# Learning Rust

Solving these puzzles was great for learning Rust. From these last three weeks
I'd underline these topics:

* _Cargo_: The cargo package manager works well and easy to use. The project
  was easy to start and the file layout is clear and simple.
* _Testing_: Rust has a built-in testing framework that integrates well with
  cargo.  It's easy to add tests and maintain tests because the test code is
  close to the application code.
* _Cargo watch_: [Cargo Watch](https://github.com/passcod/cargo-watch) can run
  the tests every time a change occurs in  project's source.  I only introduced
  this tool at [day 16][Day16]. I should have done it right at the beginning.
* _Vec_: For almost every puzzle I used
  [Vec](https://doc.rust-lang.org/std/vec/struct.Vec.html) from the standard
  library.
* _Iterators_: I learned to use methods of the
  [Iterator](https://doc.rust-lang.org/std/iter/trait.Iterator.html) trait. I
  used `map`, `filter`, `count` almost every day.  Long iterator chains take a
  bit of getting used to, but they are idiomatic in Rust.
* `itertools crate`: `multi_cartesian_product` from the
  [itertools](https://docs.rs/itertools) crate was a life-saver for
  implementing Game of Life in arbitrary dimensions.
* `Regex crate`:  Well, regular expressions are just everywhere.
* `enum`: In Rust `enum` is a real sum type where the variants can contain data
  too. I used an `enum` as a central type on days [4][Day04], [8][Day08],
  [14][Day14], [18][Day18] and [19][Day19].

# Summary

Completing the Advent of Code and learning a new programming language was
challenging.  I learned a lot in these last 25 days about puzzles, algorithms
and about the Rust language.

I particularly enjoyed the puzzles where [knowing an
algorithm]({filename}2018-03-10-Algorithms.md) is rewarding and makes your code
concise and readable.  When my code is long and messy I know that I'm missing
something: a data structure, an algorithm or a language feature.  The hard part
is to figure out which one.

The source code of all solutions are available on [GitHub][Repo].

# Acknowledgment

Thanks [Eric Wastl](https://twitter.com/ericwastl) for creating and running
[Advent of Code](https://adventofcode.com).

[Dynamic]: https://en.wikipedia.org/wiki/Dynamic_programming
[Life]: https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
[Remainder]: https://en.wikipedia.org/wiki/Chinese_remainder_theorem
[Repo]: https://github.com/wagdav/advent-of-code-2020
[ShuntingYard]: https://en.wikipedia.org/wiki/Shunting-yard_algorithm
[Workflow]: https://github.com/wagdav/advent-of-code-2020/blob/main/.github/workflows/test.yml

[Day01]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day01.rs
[Day02]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day02.rs
[Day03]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day03.rs
[Day04]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day04.rs
[Day05]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day05.rs
[Day06]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day06.rs
[Day07]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day07.rs
[Day08]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day08.rs
[Day09]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day09.rs
[Day10]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day10.rs
[Day11]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day11.rs
[Day12]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day12.rs
[Day13]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day13.rs
[Day14]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day14.rs
[Day15]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day15.rs
[Day16]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day16.rs
[Day17]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day17.rs
[Day18]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day18.rs
[Day19]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day19.rs
[Day20]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day20.rs
[Day21]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day21.rs
[Day22]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day22.rs
[Day23]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day23.rs
[Day24]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day24.rs
[Day25]: https://github.com/wagdav/advent-of-code-2020/blob/main/src/bin/day25.rs
