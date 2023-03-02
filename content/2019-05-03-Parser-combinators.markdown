---
title: Exploring parser combinators
summary:
    This is an experience report of playing with Megaparsec, a parser
    combinator library in Haskell.
---

This is an experience report of playing with Megaparsec, a parser combinator
library in Haskell.

# Parser combinators

The first time I saw a code snippet using the [Parsec][Parsec] library I was
truly amazed: [a parser of Comma-Separated Values(CSV)][CSVParser] reads:

``` haskell
csvFile = line `endBy` eol
line = cell `sepBy` (char ',')
cell = quotedCell <|> many (noneOf ",\n\r")

-- quotedCell = ... -- the definition is omitted
```

I had tried writing a CSV parser by hand before: it was about opening a file,
looping over all the lines, splitting the lines on the comma, looping over
those parts and so on.  In the `csvFile` example I didn't find any of those:  I
can _see_ that the code describes the CSV file, but where is all the parsing
happening?

In the previous code-block some notations can be unfamiliar, but this is a
great example of declarative code: you specify _what_, and not the _how_.  In
fact, if you learn a bit the library, the code almost reads as plain English:

* A CSV file is zero or more occurrences of lines, separated and ended by
  end-of-line
* A line is zero or more occurrences of cells, separated by comma
* A cell is either a quoted cell or zero or more characters, excluding comma
  and new-line.

Using this [domain specific language][DSL] results in code that is not only
declarative, but also compositional: complex parsers are built out of simpler
parsers using the provided combinators.  In our example the `line`, `cell` and
the `quotedCell` parsers can be developed, tested and maintained separately.

Developing parsers in this way is called [combinatory
parsing][WikiParserCombinator] and has a [rich literature][MonParsing].

If you ever played with the big guns of parsing such as Lex/Yacc or ANTLR you
can appreciate a whole new level of expressiveness.  The parser combinators are
written as a library of the host language. Here, I am interested in Haskell,
but Parsec-like libraries exist for other languages as well.  Contrary to
traditional parser generators, there's no need for preprocessing or external
tooling. In Haskell you can even try your parsers in an interactive REPL
session.  These features make it cheap to write ad-hoc parsers in your
programs.

# Haskell libraries

Many parser combinator libraries were written in Haskell; I did some research
to decide which one to use.  I narrowed down my options to three:

1. [Parsec]( https://hackage.haskell.org/package/parsec)
1. [Attoparsec](https://hackage.haskell.org/package/attoparsec)
1. [Megaparsec](https://hackage.haskell.org/package/megaparsec) (fork of Parsec)

I read somewhere that the original Parsec library may not give the best error
messages when a parser fails.  attoparsec is designed to be super-fast, aimed
particularly at dealing efficiently with network protocols and complicated
text/binary file formats.  Megaparsec promises a _"nice balance between speed,
flexibility, and quality of parse errors"_.  Sounds good to me.  I decided to
give Megaparsec a try.

Despite their different internals, these libraries expose a similar interface.
Often it is not too difficult to port code from one library to an other.  The
[README of megaparsec][MegaparsecREADME] contains a more detailed comparison
with other solutions.

# Using Megaparsec

In spite of  Megaparsec's detailed documentation and its [great
tutorial](https://markkarpov.com/megaparsec/megaparsec.html), initially I had a
hard time finding the relevant documentation for specific combinators.  The
Megaparsec library organizes its functions in multiple modules/packages:

* [parser-combinators][ParserCombinators]: generic combinators such as
  `some`, `optional` and `sepBy`.

* [Megaparsec][Megaparsec]: running parsers, primitive and derived combinators.
  For example, `parse`, `oneOf`, `noneOf`

* [Megaparsec.Char][MegaparsecChar]: characters and character groups.
  For example, `space`, `eol`, `tab`, `alphaNumChar`, `digitChar`

* [Megaparsec.Lexer][MegaparsecLexer]: high level parsers for handling
  comments, indentation and numbers. For example, `skipBlockComment`,
  `decimal`, `signed`

I think this structure is sensible, but it takes a bit to understand.
Especially for beginners it is hard to grasp what is a _primitive_ and
_derived_ combinator or what is considered as _high-level_ and _low-level_
parser.

Solving a typical parsing problem, such as parsing a CSV-file, requires only a
handful of library functions.  As soon as you have those combinators figured
out the development becomes a breeze.  I felt that Megaparsec lets me almost
directly transcribe data format specifications into code.

# Summary

Combinatory parsing is a great way of developing parsers.  Parser-like
libraries demonstrate many good aspects of library design.  They are
compositional but beginners may have a hard time initially dealing with
abstract combinators.

If you want to learn more about this topic I recommend watching [Scott
Wlaschin's presentations on parser combinators][WlaschinNDC2017].

[Parsec]: https://wiki.haskell.org/Parsec
[CSVParser]: http://book.realworldhaskell.org/read/using-parsec.html
[DSL]: https://www.youtube.com/watch?v=8k_SU1t50M8
[WikiParserCombinator]: https://en.wikipedia.org/wiki/Parser_combinator
[MonParsing]: http://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf
[ParserCombinators]: https://hackage.haskell.org/package/parser-combinators
[MegaparsecREADME]: https://github.com/mrkkrp/megaparsec#comparison-with-other-solutions
[Megaparsec]: https://hackage.haskell.org/package/megaparsec-7.0.4/docs/Text-Megaparsec.html
[MegaparsecChar]: https://hackage.haskell.org/package/megaparsec-7.0.4/docs/Text-Megaparsec-Char.html
[MegaparsecLexer]: https://hackage.haskell.org/package/megaparsec-7.0.4/docs/Text-Megaparsec-Char-Lexer.html
[WlaschinNDC2017]: https://www.youtube.com/watch?v=RDalzi7mhdY
