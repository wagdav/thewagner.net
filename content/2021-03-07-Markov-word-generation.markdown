---
title: Markov-chain word generation
---

Recently I reread some chapters of the book [The Practice of Programming by
Brian Kernighan and Rob Pike][tpop].  In Chapter 3 on _Design and
Implementation_ the authors present several implementations of a random text
generator to compare how various languages' idioms express the same idea.

I wrote my version in Rust which I present in this article with some example
text I generated using various sources.

# Random text

The goal is to write a program that generates random English text that reads
well.  The program takes a large body of text as input to construct a
statistical model of the language as used in that text.  Then the program
generates random text that has similar statistics to the original.

Here's an example generated sentence, given the words of all articles of this
blog:

> In this article resonate with you I recommend to watch the original talk on
> YouTube with meticulously prepared slides, what we see similar configuration
> blocks everywhere.

This is obviously nonsense, but the program may generate some funny phrases,
especially if the input is long and varied.

The program uses a [Markov-chain][WikiMarkov] algorithm to generate text.  The
words of the input text are arranged in a data structure that records which
two-word combinations are followed by which words.

For example, let's assume that in the input text the words _In this_ are
followed by one of the following words: _example, post, workshop, specific,
representation_.  Starting from _In this_, we generate the next word by
choosing randomly from these candidates.  Let's say we pick _specific_.  Then,
in the next iteration we repeat the same procedure for the words _this
specific_.  We can continue generating new words until we have candidate words
to pick from.

# Rust implementation

I wrote my version of the word generator program in Rust.  This code snippet
shows its basic usage:

```rust
let mut builder = ChainBuilder::new(2);         // ①
for word in words {
    builder.add(&word);                         // ②
}
let chain = builder.build();                    // ③
println!("{}", chain.generate(100).join(" "));  // ④
```

1. Create a [ChainBuilder][RustBuilder].  The chain will use two-word prefixes
   to detemine the next word.
1. Add words from the input text and store them in a hash-map internally.
1. Finish building and create the actual `Chain`.
1. Use the `Chain` to generate 100 words and print them as a sentence.

The whole implementation is 129 lines long and it's available on
[GitHub][MarkovCode].  It's a complete command-line application with help texts
and proper argument parsing.  The used algorithm and data structures are
identical to those described in [the book][tpop].  You can also find the C,
C++, Java, Perl and AWK versions written by Kernighan and Pike
[here][tpopCode].

# Examples

Let's see some generated texts based on different data sets.  The prefix length
is always two.  The code gives a random text at each execution and I ran the
program a few times until I obtained a variant which I found funny or
interesting.  Often I stripped the unfinished, partial sentences from the end
of the text.

## Book of Psalms

Kernighan and Pike use the [Book of Psalms from the King James Bible][Psalms]
as a test dataset because it  has many repeated phrases (_Blessed is the..._)
which provides chains with large suffix sets.  I started to test my program
with this data set.  Here's one example:

> Blessed is the lord. Praise the lord, at the blast of the enemy: thou hast
> maintained my right hand is full of water: thou preparest them corn, when
> thou hast known my soul had almost dwelt in silence.

Indeed, the characteristics of the input dataset are recognizable in each
random output,  the text reads like prayer using archaic English words.

## Technobabble

[Richard Feynman's observations on the reliability of the Shuttle][Feynmann] is
a fantastic read on it own.  The 5000 word long eloquent, technical text is an
excellent source for technobabble generation.

> It appears that there are three engines, but some accidents would possibly be
> contained, and only three in the second 125,000 seconds. Naturally, one can
> never be sure that all is safe by inspecting all blades for cracks. If they
> are found, replace them, and if none are found in the list above). These we
> discuss below. (Engineers at Rocketdyne, were made.

In this example we can see that the implementation has no notion of
punctuation: unmatched parentheses appear at random places because they are
considered to be part of the word.

Here's another one:

> It appears that there are enormous differences of opinion as to the Space
> Shuttle Main Engine. Cracks were found after 4,200 seconds, although usually
> these longer runs showed cracks. To follow this story further we shall have to
> realize that the rule seems to have been solved.

## Blog corpus

Finally I tried to generate a random blog post using the articles I've written
here.

I used [Pandoc](https://pandoc.org) to convert the markdown files I've written
to plain text:

```shell
pandoc  *.markdown --from markdown --to plain
```

This yields about 20 thousand words of text, some of which appear in equations,
enumerations and code blocks.  I wrote a function to ignore almost everything
but the actual text.   Here are two examples which show that the program is not
quite ready to replace me in writing new articles:

> In this representation we can assume that we exploit that IO is a simple
> function. Its imaginary type signature is: This reads: the configuration blocks
> we implicitly created a simple function. Its imaginary type signature is: This
> reads: the configuration code on GitHub.
>
> In this niche domain the utility of functions is well studied and understood.
> Ideas from purely functional programming language using YAML’s syntax. In
> programming we use fmap to lift our pure project function to be Python, but it
> was served from. We now are ready to define components, component configuration
> and component relationships.

In these outputs I can recognize full sentences of my previous articles which
shows that the blog corpus is not large enough for automatic blogging.

# Summary

Using a Markov-chain to generate random text in a given "style" is a fun
programming exercise.  The problem can be solved in a few dozen lines of code,
but it teaches a lot about algorithms and design in general.

[Feynmann]: https://science.ksc.nasa.gov/shuttle/missions/51-l/docs/rogers-commission/Appendix-F.txt
[Psalms]: https://www.gutenberg.org/ebooks/8019
[tpop]: https://www.cs.princeton.edu/~bwk/tpop.webpage/
[tpopCode]: https://www.cs.princeton.edu/~bwk/tpop.webpage/code.html
[WikiMarkov]: https://en.wikipedia.org/wiki/Markov_chain
[MarkovCode]: https://github.com/wagdav/markov
[RustBuilder]: https://rust-unofficial.github.io/patterns/patterns/creational/builder.html
