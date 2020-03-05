---
title: Parallel mindset
---

Perhaps everything in our mainstream programming languages is at least 50 years
old.  Loops, iterators, pointers and references to mutable memory locations
appeared in Fortran or ALGOL and now they are part of all mainstream
programming languages.

These constructs were designed for developing sequential programs.  But today
computers have many cores and processors and we want to do more computations in
parallel.  We bolted some parallel features on our sequential programming
languages, but sequentiality remains built into our mindset and our
infrastructure.

We need to change our mindset.


## Automate parallelism

Many programming languages manage allocations of storage automatically.
Instead of the programmer, the compiler or the run-time system claims and frees
memory.  The implementation of this automatism is language specific:

* Scope-limited [automatic variables](https://en.wikipedia.org/wiki/Automatic_variable) (C++)
* Tracing garbage collection (Java, Python, Go, Haskell)
* Ownership tracking (Rust)

Is it be possible to make parallelism, that is allocation of code to processors, automatic?

With automatic memory management we stopped using `malloc` and `free`.  To
automate parallelism we need restrict our programming style and give up
sequential programming language artifacts from the sixties.


## Accidentally complex

Let's take the textbook example of computing $n!$:
``` python
def factorial(n):
    result = 1                  # ①
    for i in range(1, n + 1):   # ②
        result = result * i     # ③
    return result
```

This is code represents the today's most programming style: sequential,
imperative, mutable and allows uncontrolled side effects.  Every line of this
function states what happens during execution:

1. Assign an initial value to `result`.
2. Use the value of `i` drawn from the specified range.
3. Mutate `result` with the current value of `i`.

Many consider this implementation "readable" and "simple" because we are used
to seeing such programs.  But this code contains many _accidental_ aspects: the
`result` accumulator, the intermediate value `i`, and the allusion to
sequential execution.  These are unrelated to the original problem statement.
This is a form of complexity [caused by control][TarPit].


## Keeping the essential

Let's strip off everything but the essential from the previous implementation
of `factorial`:

``` python
from functools import reduce
from operator import mul

def factorial(n):
    return reduce(mul, range(1, n + 1))
```

This implementation reads almost as a pure specification without any view on
the execution.  This form is more unusual but _simpler_ than before because all
accidental complexity were removed.

As programmers, we give up the control of the execution order and we let the
runtime environment choose the most efficient execution strategy.  In case of
Python the execution would be similar, or perhaps identical to that of the
first implementation.  Using this declarative style, however, we could imagine
a programming system where the actual execution strategy would depend on
multiple factors:

* For small `n` execute sequentially.
* For large `n` split the range among multiple processors, then merge the
  results.
* Push some parts of the computation to the GPU.
* Send the computation to a massively parallel super-computer.

In general, operations cannot be parallelized arbitrarily.  To allow for such
flexible runtime behavior we must enrich our programs with hints to the
compiler or to the runtime environment.


## Algebraic properties

If we recognize and communicate our problem's algebraic properties to the
compiler or to the run-time, it can exploit alternate representations and
implementations.

Well-known algebraic properties translate to useful hints:

* _Associative_: grouping doesn't matter
* _Commutative_: order doesn't matter
* _Idempotent_: duplicates don't matter
* _Identity_: the current value doesn't matter
* _Zero_: other values don't matter

In `factorial` the integer multiplication is associative, therefore performing
the multiplication in groups first, then merging the partial results is a
correct parallel implementation.  It is also commutative, so we can do the
merging in any order.


## Automatic parallelism in practice

[Optimizing compilers][OptimizingCompiler] generate efficient, often parallel
code from a sequential, imperative code.  But in general, a program organized
according to linear problem decomposition principles is hard to parallelize.
[Fran Allen](https://en.wikipedia.org/wiki/Frances_E._Allen) won the 2006
Turing-award for her work in program optimization and parallelization.

[Dask](https://dask.org) is a flexible parallel computing library for Python.
[Its user interface](https://docs.dask.org/en/latest/#familiar-user-interface)
mimics the programming experience of popular data processing libraries. For
example, you write regular [NumPy](https://numpy.org) array manipulation code
and the Dask scheduler distributes the computations across multiple threads or
among the nodes of a cluster.

[Facebook's Haxl library](https://github.com/facebook/Haxl) can automatically
execute independent data fetching operations concurrently.  Haxl, with the
compiler's assistance, recognizes algebraic properties such as applicative
functor and monad to generate efficient concurrent code.  [Simon Marlow's
presentation](https://www.youtube.com/watch?v=sT6VJkkhy0o) is a great
introduction of the ideas behind this tool.


## Summary

When we code in the imperative style, accidental complexity of control creeps
into our programs.  The programmer, instead of the expressing problem's
essence, is burdened with managing loops, states and the details of a
sequential-looking runtime behavior.

Code written in declarative, functional style with no ties to a specific
execution model may be automatically parallelized by the underlying system.
Algebraic properties constrain which execution strategies are correct and
efficient.

The inspiration to this article came from the talk "Four Solution to a Trivial
Problem" of [Guy Steele][GuySteele].  I recommend watching [the whole talk on
YouTube][Video].

I also recommend reading Bartosz Milewski's post on [Parallel Programming with
Hints](https://bartoszmilewski.com/2010/05/11/parallel-programming-with-hints/)

[GuySteele]: https://en.wikipedia.org/wiki/Guy_L._Steele_Jr.
[Video]: https://www.youtube.com/watch?v=ftcIcn8AmSY
[OptimizingCompiler]: https://en.wikipedia.org/wiki/Optimizing_compiler
[TarPit]: http://curtclifton.net/papers/MoseleyMarks06a.pdf
