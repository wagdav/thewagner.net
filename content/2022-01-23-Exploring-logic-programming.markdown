---
title: Exploring Logic Programming
---

In this article I revisit the problem _Seven Segment Search_ of Day 8 in the
[Advent of Code 2021]({filename}2021-12-25-Advent-of-Code.markdown) puzzle
series.  I implement a declarative solution in Clojure using the logic
programming library [core.logic][CoreLogic].

# Puzzle

The [problem of Day 8][AocDay8] was about decoding the digits of a broken
[seven-segment][SevenSegmentWiki] display.  We can measure the signals on the
wires powering the display's segments, but we don't know which wire is
connected to which segment.  The puzzle input is a sequence of activation
signals of the display as it renders the digits from 0 to 9 in some random
order:

```text
"be" "cfbegad" "cbdgef" "fgaecd" "cgeb" "fdcge" "agebfd"
"fecdb" "fabcd" "edb"
```

The goal of the puzzle is to decode these signal patterns to understand which
digit the display renders.

For example, the first signal pattern `"be"` must be the digit `1` because this
is the only digit that is rendered using two segments.  But we don't know which
segment the signals `b` and `e` are connected.  By looking at the digit `1`
there are two possibilities:

```text
                    ....       ....
                   .    b     .    e
                   .    b     .    e
                    ....       ....
                   .    e     .    b
                   .    e     .    b
                    ....       ....
```

In fact, the digits `1`, `4`, `7` and `8` each use a unique number of segments:
2, 4, 3 and 7, respectively, so these are easy to identify.  To find the other
digits we need to collect more information.

For example, the digits `2`, `3` and `5` are each contain five active segments.
From this group we can find the digit `3` by exploiting that the rendering of
the digit `3` doesn't change with the digit `1` superimposed.  In other words,
the activation signals of the digit `3` and `1` only differ in one segment.

# Imperative solution

Exploiting the similarities between the digit representations you can come up
with your own algorithm to unambiguously identify all digits.  My
implementation in Clojure looks like this:

```clojure
(defn decode [patterns]
  (let [length  (group-by count patterns)
        ; Unambiguous digits
        [one]   (get length 2)
        [four]  (get length 4)
        [seven] (get length 3)
        [eight] (get length 7)

        ; Candiates for 2,3,5 and 0,6,9
        c235    (get length 5)
        c069    (get length 6)

        ; Find the rest using similar digits
        three   (find-with-mask one c235)
        nine    (find-with-mask three c069)
        zero    (find-with-mask seven (remove #{nine} c069))
        five    (find-with-mask nine nine (remove #{three} c235))

        [six]   (remove #{zero nine} c069)
        [two]   (remove #{three five} c235)]

    {zero 0 one 1 two 2 three 3 four 4
     five 5 six 6 seven 7 eight 8 nine 9}))
```

The function `decode` takes the signal patterns as input and returns a map from
signal pattern to digit value.  The function `find-with-mask` implements the
insight about the similarity of the digits.  You can read the entire code of my
solution [here][CodeDay08].

Clojure may not be your language of choice, but in any other mainstream
language the solution would be similar in spirit: a few function calls, set and
sequence operations. Each operation is trivial but the `decode` function is
hard to understand even for a person familiar with the problem statement.  This
implementation is imperative, each line prescribing what to do and the order of
operations is critical.

In the next section I show a declarative solution where we only state the
problem and let the computer figure out how to solve it.

# Declarative solution

In this section we reimplement the `decode` function using the logic
programming library [core.logic][CoreLogic].  A logic program is an expression
of constraints upon a set of logic variables.  We hand this expression to a
solver, in our case core.logic, which returns all the possible values of the
logic variables that satisfy the constraints.  The [core.logic
Primer][CoreLogicPrimer] explains in detail how the solver works.

Let's see the declarative version of the pattern decoder in Clojure core.logic:

```clojure
(defn decode-logic [patterns]
  (let [length (group-by count patterns)]
    (first (run 1 [q] ; ❶
      (fresh [zero one two three four five six seven eight nine]
        ; ❷
        (== q {zero 0 one 1 two 2 three 3 four 4
               five 5 six 6 seven 7 eight 8 nine 9})
        ; ❸
        (== [one]   (length 2))
        (== [four]  (length 4))
        (== [seven] (length 3))
        (== [eight] (length 7))
        ; ❹
        (permuteo (length 5) [two three five])
        (permuteo (length 6) [zero six nine])
        ; ❺
        (overlay one three three)
        (overlay one nine nine)
        (overlay one zero zero)
        (overlay one five nine)
        ; ❻
        (permuteo patterns [zero one two three four
                            five six seven eight nine]))))))
```

After a standard function definition and a let-binding the body of
`decode-logic` is a set of constraints derived from our original problem
statement:

1. Run the solver and ask for exactly solution.  Our problem has a unique
   solution, but in other applications you may be interested in many solutions
   that satisfy the constraints.  `q`, the second argument of
   [run][core.logic/run], refers to the final solution.

1. Search the solution `q` in the shape of a map from pattern to digit value.
   This is the same structure we used in the previous section.

1. Identify the "easy" digits, those with unambiguous number of active
   segments.

1. The 5 and 6 character long signal patterns are the permutations of the
   sequences `[2, 3, 5]` and `[0, 6, 9]`, respectively.

1. Overlay rules: for example the digit 1 and 3 yields 3 when on top of each
   other.

1. The sequence of activation patterns is a permutation of the digits.

`decode-logic` encodes only the rules of the puzzle without any details of the
program's execution.  In fact, you can rearrange the constraints arbitrarily,
the logic expression evaluates to the same result.

The order of the constraints, however, affects the solver's performance: I
found that stating more specific constraints first makes the solver explore the
possible states faster.

The beauty of the declarative solution comes with a price, at least in my
implementation: `decode-logic` takes approximately six seconds to run where
`decode` completes within a millisecond.  This was my first logic program I've
ever written in Clojure core.logic so I guess this is fine.

The source code of the implementation is available [here][CodeDay08b].

# Summary

I implemented an Advent of Code puzzle as a logic expression in Clojure.  A
logic program is about the _what_ instead of the _how_: stating the problem is
easier, but reasoning about the program's performance is harder than compared
to an imperative implementation.

You can read about my experience of the 2021 Advent of Code
[here]({filename}2021-12-25-Advent-of-Code.markdown) and [this
repository](https://github.com/wagdav/advent-of-code-2021) contains all my
solutions.

[AocDay8]: https://adventofcode.com/2021/day/8
[CodeDay08]: https://github.com/wagdav/advent-of-code-2021/blob/92600462261829f4a7069eb43ad6e5930f053e59/src/aoc2021/day08.clj
[CodeDay08b]: https://github.com/wagdav/advent-of-code-2021/blob/92600462261829f4a7069eb43ad6e5930f053e59/src/aoc2021/day08b.clj
[CoreLogicPrimer]: https://github.com/clojure/core.logic/wiki/A-Core.logic-Primer
[CoreLogic]: https://github.com/clojure/core.logic/
[ExampleBlog]: https://mattsenior.com/2014/02/using-clojures-core-logic-to-solve-simple-number-puzzles
[ExampleLogic]: https://github.com/clojure/core.logic/wiki/Examples
[SevenSegmentWiki]: https://en.wikipedia.org/wiki/Seven-segment_display
[core.logic/run]: https://clojuredocs.org/clojure.core.logic/run
