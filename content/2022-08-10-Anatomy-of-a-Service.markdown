---
title: Deconstructing a simple service
---

Large software systems are usually built as a network of communicating
programs, often called _services_.  In a well-designed system each service has
one specific role or is about one concept or buisness capability.  [Rich
Hickey][HickeySimpleMadeEasy] calls this attribute _simple_, in the sense of
unentangled, not twisted together with anything else.

In this interpretation simple doesn't mean that the service is made of one
component.  Nor it implies any restrictions about the size of the service's
code base.

In this article I explore the internal components of a simple service.

# Inherent concurrency

A service to fullfill its buisness goal, it may perform some of the following
tasks:

* Read input from data sources
* Write output to data stores, to message queues or to other services
* Store internal state on disk or in memory
* Emit telemetry data such as logs, metrics and traces
* Listen and react to external events such as operating system signals, and
  configuration updates

In other words, a service, independently of the number of its business
capabilities is inherently [concurrent][PikeConcurrency].

Some components in the previous list may be trivial. For example, a few lines
of code we can implement a method that reads input from a file.  On the other
hand, a service communicating with a message broker may require a sophisticated
subsystem that implements connection management and data serialization.

Some components represent the bare minimum: a service must have a way to
communicate with the external world otherwise it would be useless.  Others are
neccessary operations: while it's certainly possible to fullfill a buisness
requirement without logging, the resuling service would be close to impossible
to debug in production.

# Design and development

Thus we should consider languages and frameworks with good support for
concurrency.

In the next sections we examine these extra tasks in detail.

# Managed services

Building a mental model about the internal component of a service is also
useful when we operate a service written by other teams and even when we are
just users of a fully managed service.

* Self-developed
* Self-managed
* Fully managed

These problems are also worth treating when we just operate a service.

When you're responsible for a service in production.

# Summary

A simple service, that accomplishes one buisness objective, is inherently
concurrent and comprises many components.  Before we build such a service we
should design how its subsystems will interact with each other.

[PikeConcurrency]: https://blog.golang.org/waza-talk
[HickeySimpleMadeEasy]: https://www.youtube.com/watch?v=LKtk3HCgTa8
