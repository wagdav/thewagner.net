title: Build systems à la carte
tags: review

Today I went to the talk "Build systems à la carte" of Andrey Mokhov.  He presented the results of the identically named paper from last year authored by himself and his co-authors.  The following links point to the paper and its related resources:

* [paper submitted to ICFP 2018](http://doi.org/10.1145/3236774)
* [presentation from ICFP 2018](https://www.youtube.com/watch?v=BQVT6wiwCxM) by Simon Peyton-Jones (co-author)
* [extended version of the original paper](https://github.com/snowleopard/build/releases/download/jfp-submission/jpf-submission.pdf)
* [slides from today's presentation](https://github.com/snowleopard/build/releases/download/slides-lausanne/slides-lausanne.pdf) (the talk was not recorded)
* [code examples on GitHub](https://github.com/snowleopard/build)

I had known about this paper from last year and I was excited to learn that Andrey was going to present this work at EPFL, Lausanne.  In the next sections I summarize what I learned from the paper and the presentation.

## Build systems

The study explores the design space of build systems such as Make, Ninja, Bazel.  Interestingly, through the lens of this paper, systems like Excel and Docker can also be seen as build systems.

Typically we specify our builds as a set of rules: we tell how a given target is built out of its dependencies.  The build system's job is to bring a specified target up-to-date.  Depending on the application domain a build system may have some of the following properties:

* _Minimality_: don't repeat work unnecessarily
* _Early cutoff_: stop when nothing changes
* _Cloud builds_: save repeating work by sharing build results among all developers
* _Dynamic dependencies_: some dependencies are not known in advance, but they are discovered as we run the build.


## Classification space

Two key design choices are typically deeply wired in any build system:

1. _Scheduling_: the order in which tasks are built
2. _Rebuilding_: whether or not a task is rebuilt

Today's most commonly used build systems can be classified along these two axes.  Let's see these two aspects in detail.


### Scheduling strategies

Build systems use different strategies to execute the build tasks:

* _Topological_: all the dependencies are known in advance. The tasks are
  executed in topological order. Examples: Make, Ninja, Buck

* _Restarting_: if a task has an non-built dependency its build is aborted and
  restarted later when the dependency is available. Examples: Bazel, Exel

* _Suspending_: a task is suspended when its build encounters a missing dependency. Examples: Shake, Nix

The chosen scheduling strategy has an effect on the properties of the resulting build system:

* A topological scheduler cannot support dynamic dependencies.  A topological order can only be established if all the dependencies are known at the beginning of a build.

* Build system using restarting schedulers are not minimal because some work is repeated when restarted.  Note that the cost of duplicate work may often be just a fraction of the overall build cost.

* A suspending scheduler is theoretically optimal, but it is only better in practice than a restarting scheduler if the cost of avoided duplicate work outweighs the cost of suspending tasks.


### Rebuilding strategies

We find the following techniques to decide whether or not a task is rebuilt:

* _Dirty bit_: anything that changed since the last build is marked dirty (Excel, Make)

* _Verifying traces_: rebuild a target if the values/hashes of the its
  dependencies changed since the last build (Ninja, Shake)

* _Constructive traces_: like verifying traces, but also store the resulting target value. The stored value can be shared with other users. (Bazel)

* _Deep constructive traces_: like constructive traces, but only store terminal input keys ignoring any intermediate dependencies (Buck, Nix)

Again, picking a given rebuilding strategy has interesting consequences:

* We can achieve minimality using dirty bits.
* It's possible but hard to support early cutoff with dirty bits.  Make approximates early cut-off.
* All traces support dynamic dependencies and minimality
* All traces except for deep traces support the early cutoff optimization
* Constructive traces enable cloud builds
* Deep constructive traces cannot support early cutoff
* Deep constructive traces may generate frankenbuilds if the tasks are not deterministic


## Executable build system models

After a detailed classification of build system the authors present executable Haskell code to model real-world build systems. The concrete implementations are broken down into two components: _Scheduler_ and _Rebuilder_,  Here are some models in their final form:

``` haskell
make = topological modTimeRebuilder
excel = restarting dirtyBitRebuilder
shake = suspending vtRebuilder
bazel = restartingQ ctRebuilder
```

It's remarkable that the concepts presented in this work lead such succint implementations.  The actual executable code can be found [in this repository](https://github.com/snowleopard/build/blob/03e891238864f30bc5ac1182a1ba37b8b81dcffb/src/Build/System.hs).


## Summary

The work "Build systems à la carte" from Andrey Mokhov and his co-workers taught me a lot about how build systems work.  It demonstrates the power of Haskell as a modeling language.  I recommend you to read the paper and study the related resources shown at the beginning of this article.
