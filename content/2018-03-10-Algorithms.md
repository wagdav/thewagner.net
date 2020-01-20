---
title: Knowing Algorithms
---

The other day I got a question from a colleague:  _Do you know an algorithm for
this problem of ... details...details?_  The exact the problem description is
not important.  It was a well defined problem which totally made sense.  I felt
that there must be an algorithm for it, but I couldn't help.  I just simply
didn't _know_ any.

I didn't have a formal training on algorithms and complexity.  Yes, I can
easily write an O(n^2) sorting algorithm.  Probably I can even make it O(n log
n), but I wouldn't enjoy it.  Of course, I quickly learned that I shouldn't
write my own sorting algorithm.  Countless hours of thinking went into
inventing, refining all sorts of algorithms so I better reach for libraries
written by smart people and use those instead.

Most programming languages provide basic algorithms such as finding the minimum
or maximum element in a sequence, sorting and so on.  Sometimes we can get away
with these "built-in" algorithms, but often we need to provide a more complex
solution.  In real world problems data are noisy, things can fail and just
nothing is as simple as in textbook examples.

We may try to combine the provided basic algorithms as building blocks to solve
our particular problem.  Sounds reasonable, right?  _Tackle complexity by
composition_ the mantra says.  But if you're given `erase` and `remove_if` to
eliminate elements that fulfill a certain criterion from a C++ container, would
you come up with the [Erase-remove idiom][1]?  I wouldn't.  For example, in the
talk [STL Algorithms in Action from CppCon 2015][2] Michael VanLoon solves
interesting sorting problems using components from the `<algorithm>` library.
None of those solutions are trivial.

Building algorithms is hard, even if you have the basic components available.
It takes special expertise and a lot of time.  I don't have this expertise, but
I still want to help my colleagues to solve their domain specific problem.

The point Nicolas Ormrod makes in his great talk [Fantastic Algorithms and
Where To Find Them][3], is that algorithms are _tools_: you need to know they
exist and you need to be able to use them.  It doesn't matter if you built the
tool yourself (which is still very impressive), but how many different problems
you can solve with it.  The more tools you have in your toolbox, the more
algorithms you know, the more problems you can solve.

One of piece of advice the book [The Pragmatic Programmer][4] gives (section
_Your Knowledge Portfolio_ in Chapter 1) is that you should learn at least one
new programming language every year.  I'd say you should also learn a new
algorithm every month.  So next time when you're asked if you know an algorithm
that solves a certain problem you can reach into your toolbox and answer:
_yeah, this algorithm can solve a problem which looks very similar to yours,
maybe it would be a good fit..._


[1]: https://en.wikipedia.org/wiki/Erase%E2%80%93remove_idiom
[2]: https://www.youtube.com/watch?v=eidEEmGLQcU
[3]: https://www.youtube.com/watch?v=YA-nB2wjVcI
[4]: https://en.wikipedia.org/wiki/The_Pragmatic_Programmer
