---
title: Advent of Code 2021
summary: Solving the Advent of Code 2021 puzzles in Clojure.
---

I solved the [Advent of Code](https://adventofcode.com/), puzzles.  This post,
[like the one from last year]({filename}/2020-12-25-Advent-of-Code.markdown),
is an experience report of my 25+ day journey in December.

**Spoiler alert**: If you're still working or planning to work on the puzzles
stop reading now.

# Puzzles

Between December 1 and December 25, a programming puzzle appears every day at
Advent of Code website.  Each problem has two parts, the second part unlocks
after you complete the first.  To understand each day's puzzle, go to the
website and read the full description (for example [Day 1: Sonar
Sweep](https://adventofcode.com/2021/day/1)).

# Setup

I decided to learn Clojure and to solve the puzzles in this functional dialect
of the Lisp language.  In the past few years I believe I watched every
available conference talk of Rich Hickey, the creator of Clojure. It was time
for a full-immersion into the language he designed.

I knew from last year, when I implemented the solutions in Rust, that learning
a new programming language while thinking about challenging puzzles is
frustrating.  So I decided to learn some Clojure before the puzzle series
begins.

In November I read a few chapters of [The Joy of
Clojure](http://www.joyofclojure.com/) and I [rewrote][Warmup] some of my
Advent of Code 2020 solutions in Clojure. With this preparation I could write
decent code from Day 1 but I often restructured my older programs as I learned
more about the language.

Just like last year, I didn't care about code size, performance optimizations
(only when it was the goal of the puzzle) and coding speed.

# Highlights

My favorite puzzles were [Day 8][Day08] and [Day 13][Day13].  The former was
about decoding the activation signals of a broken seven-segment display and the
latter was about folding a large sheet of transparent paper to reveal a secret
code.  Both problem statements were funny and they fit well into the
Christmas-themed story line.

The core algorithms of [Day 12][Day12], [Day 15][Day15] and [Day 23][Day23]
were about graph manipulation.  I enjoyed implementing traversals and solutions
to the shortest path problem.

The puzzles of [Day 9][Day09], [Day 11][Day11], [Day 15][Day15] and [Day
25][Day25] were stated on a two-dimensional grid.  The task of updating the
grid or parts of it appeared in many forms.  In some cases I could write
expressive code using Clojure's threading macros and the `cond->` macro, but I
also feel that some of my grid manipulation code is not idiomatic and hard to
understand.

I solved [Day 6][Day06] and [Day 14][Day14] using infinite sequences.  Here
Clojure really shines: the core sequence manipulation algorithms work well
together resulting in short and expressive code.

On [Day 16][Day16], [Day 18][Day18], [Day 21][Day21] recognizing trees,
recursion and the need for memoization were the key elements to write a clean
solution.

I spent the most hours on [Day 17][Day17], [Day 19][Day19] and [Day 22][Day22].
After multiple failed attempts to solve these days I looked for hints on
[Reddit](https://www.reddit.com/r/adventofcode/).  Many smart people hang out
in that forum and there's a lot to learn from the conversations there.

My least favorite day was [Day 24][Day24]. I didn't see the point in
deciphering someone else's obfuscated code.  I do this enough at work already.

# Learning Clojure

Using this puzzle series to learn a new programming language is stressful, but
effective.  Just like last year, solving these puzzles left me with some
thoughts about Clojure:

* _REPL_: One big selling point of Clojure is its support for interactive
  development.  I set up my editor with
  [Conjure](https://github.com/Olical/conjure) and in a few hours I got used to
  evaluating pieces of code directly from the editor.

* _Testing_: I struggled to set up Cognitect test runner, but once I learned
  the proper way to structure my project things just worked all right.   When
  I'm using other languages I run the tests from a separate command terminal.
  With Clojure it's easy to run the tests without leaving my editor.

* _Core functions_: Clojure core contains a ton of useful functions which are
  easy to use.  I used only one external library:
  [data.priority-map](https://github.com/clojure/data.priority-map/). The
  built-in documentation is terse and short on examples but
  [ClojueDocs](https://clojuredocs.org) improves this and I used it all the
  time.

* _Regular expressions_: Last year I spent a lot of time of writing parsers for
  the input files.  This year I used regular expressions almost exclusively
  and the parsing code is rarely longer than a few lines.  Clojure's literal
  regular expressions syntax and the function `re-seq`, which returns a
  sequence of successive matches, are great.

Proponents of Clojure claim that programs written in this language are short
and expressive because they are mainly about the problem at hand and not about
classes, accessors, lifetimes and other incidental programming language
constructs.

In the past few weeks coding in Clojure I find this claim justified.  In the
future I'd love to explore how is it to build a large system in the style of
programming Clojure encourages, that is using functions and generic data
transformations.

# Summary

Completing the Advent of Code and learning a new programming language was
challenging, but a rewarding experience.  After solving the puzzles I like to
see how others approached the same problem.  Here are some repositories I
regularly checked:

* [Liz Fong Jones (Go)](https://github.com/lizthegrey/adventofcode/tree/main/2021)
* [Olivier Dormond (Python)](https://github.com/odormond/adventofcode/tree/master/2021)
* [Peter Norvig (Python)](https://github.com/norvig/pytudes/blob/main/ipynb/Advent-2021.ipynb)

The source code of my solutions are also available on [GitHub][Repo].

# Acknowledgment

Thanks [Eric Wastl](https://twitter.com/ericwastl) for creating and running
[Advent of Code](https://adventofcode.com).

Thanks Olivier Dormond for exchanging ideas and congratulations for winning our
private leaderboard!

[Repo]: https://github.com/wagdav/advent-of-code-2021

[Warmup]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/warmup.clj
[Day01]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day01.clj
[Day02]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day02.clj
[Day03]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day03.clj
[Day04]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day04.clj
[Day05]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day05.clj
[Day06]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day06.clj
[Day07]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day07.clj
[Day08]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day08.clj
[Day09]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day09.clj
[Day10]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day10.clj
[Day11]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day11.clj
[Day12]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day12.clj
[Day13]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day13.clj
[Day14]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day14.clj
[Day15]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day15.clj
[Day16]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day16.clj
[Day17]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day17.clj
[Day18]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day18.clj
[Day19]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day19.clj
[Day20]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day20.clj
[Day21]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day21.clj
[Day22]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day22.clj
[Day23]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day23.clj
[Day24]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day24.clj
[Day25]: https://github.com/wagdav/advent-of-code-2021/blob/main/src/aoc2021/day25.clj
