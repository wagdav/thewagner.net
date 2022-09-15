---
title: Deconstructing a simple service
---

Engineers often build large software systems as a network of communicating
programs, called _services_.  In a well-designed system each service has one
specific role or is about one concept or business capability.  [Rich
Hickey][HickeySimpleMadeEasy] calls this attribute _simple_, in the sense of
unentangled, or not twisted together with anything else.

This definition of simple doesn't imply that the service consists of a single
component.

In this article I explore the components of a simple service.

# Inherent concurrency

A service to fulfill its business goal, it may perform some of the following
tasks:

* Read and decode input from data sources
* Encode and write data to disk, to queues and to data stores
* Store internal state in memory or on disk
* Emit telemetry data such as logs, metrics and traces
* Listen and react to external events such as operating system signals and
  configuration updates

In other words, a service, independently of the number of its business
capabilities is inherently [concurrent][PikeConcurrency].

Some components in the previous list may be trivial.  For example, a few lines
of code we can implement a method that reads input from a file.  On the other
hand, a service communicating with a message broker may require a sophisticated
subsystem that implements connection management and data serialization.

Some components are essential: a service that cannot exchange its inputs and
outputs with the world is useless.  Others are necessary for operations: while
a service that fulfills a business requirement without any logging is close to
impossible to debug in production.

# Design and development

Thus we should consider languages and frameworks with good support for
concurrency.

In the next sections we examine these extra tasks in detail.

# Managed services

Building a mental model the components of a service is also useful when we
operate a service written by other teams and even when we are just users of a
fully managed service.

* Self-developed
* Self-managed
* Fully managed

These problems are also worth treating when we just operate a service.

When you're responsible for a service in production.

# Summary

A simple service, that accomplishes one business objective, is inherently
concurrent and comprises many components.  Before we build such a service we
should design how its subsystems will interact with each other.

[PikeConcurrency]: https://blog.golang.org/waza-talk
[HickeySimpleMadeEasy]: https://www.youtube.com/watch?v=LKtk3HCgTa8
