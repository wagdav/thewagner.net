---
title: Software Quality
---

I was always part of software teams that wanted to write high quality software.
Most team members _felt_ what was good or bad quality software.  Some goodness
criteria were accepted by everybody in the team, perhaps some remained
controversial.

I'm sure every team had heated discussions about software quality.  Yet, it's
surprisingly hard to find a working definition of it.  In this post I review
the definition of _software quality_ found in the book _Facts and Fallacies of
Software Engineering_ by Robert L. Glass from 2002.

# Definition

Fact 46 of _Facts and Fallacies of Software Engineering_ defines software
quality as a collection of the following seven attributes:

* _Reliability_ is about a software product that does what it's supposed to do,
  and does it dependably.

* _Usability_ is about the ease and comfort of use.

* _Understandability_ is about a software product that is easy for a maintainer
  to comprehend.

* _Modifiability_ is about software that is easy for a maintainer to add new
  capabilities without breaking existing ones.

* _Efficiency_ is about the economy in running time and space consumption.

* _Testability_ is about a software product that is easy to test.

* _Portability_ is about a software product that is easy to move to another
  platform.

There is no general, correct order of these attributes.  The priorities of each
software project are different.

# Discussion

According to Glass, this definition of quality took the test of time, yet it
remains controversial.  Glass warns against attaching unrelated attributes --
development cost, user satisfaction or delivering on time -- to software
quality.  Of course it's desirable if a user receives the software on time and
they are satisfied with it.  This may be due to good customer support and
excellent project management.  User satisfaction is certainly influenced by
software quality, but not defined by it.

The definition of quality is industry specific.  Just like the priority of the
quality attributes is project specific.

Reliability and efficiency can be measured or estimated, for example, by
monitoring tools.  The other attributes are fuzzy and subjective which makes it
impossible to express quality using "hard" metrics.  This is not a problem
because measurement is not invaluable for managing quality.  Humans can manage
research, design and many intellectual and creative things without numbers
guiding them.  Accepting that some attributes remain qualitative is better than
pretending that a chart with made-up data is anyhow relevant.

# Responsibility

Managers are [responsible for the success of a software
project]({filename}2023-02-28-Review-Royce1970.markdown).  But quality is not a
management job.  Each of the quality "-abilities" have deeply technical
aspects, therefore it is the responsibility of technical team to work towards
the desired quality level.

Managers do, however, have an important role to establish a culture where
achieving quality is given high priority.  They can hire good engineers and let
them build great software.

# Summary

Software quality is a collection of seven attributes: reliability, usability,
modifiability, efficiency, testability and portability.  Not all attributes
make sense in all situations so teams should make their own priority list of
these attributes for each project.  Ensuring quality is a technical job.  It's
impossible to measure software quality, but this doesn't mean it cannot be
managed.
