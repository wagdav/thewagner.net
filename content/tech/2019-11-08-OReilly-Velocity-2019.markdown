---
title: O'Reilly Velocity Conference 2019
tags: review, conference
---

Between November 5-7 I spent three days on the [O'Reilly Velocity] conference.
This post documents the sessions I like the most.

The conference organizers collected the speaker slides
[here](https://conferences.oreilly.com/velocity/vl-eu/public/schedule/proceedings)

## Tuesday

I travelled to Berlin on Monday and started the conference with two, half-day
tutorials.

### Open Telemetry workshop

In this workshop, tutored by Liz Fong-Jones, I learned about OpenTelemetry: a project aiming to standardize metrics and trace collections from applications.

Our task was to instrument the provided Go code.  This was an HTTP service
computing the Fibonacci sequence using its recursive definition.  To compute
the preceding two numbers in the sequence the server code repeatedly issues
HTTP client calls to itself.  This implementation is terrible for production,
but it is an excellent classroom example.

For the practical exercises we wrote the code on [Glitch](https://glitch.com).
I think this was a great choice, I could immediately start working on the
execrcises without installing anything on my computer.

* [OpenTelemetry documentation](https://opentelemetry.io/docs/)
* [Go documentation](https://godoc.org/go.opentelemetry.io/otel)


### SRE classroom (PubSub)

In this workshop Google engineers lead us to design a strongly consistent,
multi-datacenter queue.  The instructors described how the system should
behave, what latencies are tolerated, what failures modes are allowed.  We
formed groups of five-six people to come-up with an implementation plan.  Then,
we created a bill of materials to estimate the cost of building the system.

## Wednesday

Keynotes:

* _The power of good abstractions in systems design_ Lorenzo Saino (Fastly)
    - [slides](https://lorenzosaino.github.io/talks/keynote-velocityeu19.pdf)
    - [speaker's homepage](https://lorenzosaino.github.io)
    - 90% of the problems are solved with just 40 basic principles
    - [TRIZ - theory of inventive problem solving](https://en.wikipedia.org/wiki/TRIZ)

Afternoon sessions:

* _Kubernetes the very hard way_ Laurent Bemaille (Datadog)
    - [slides](https://www.slideshare.net/lbernail/kubernetes-the-very-hard-way-velocity-berlin-2019)
    - [GitHub](https://github.com/lbernail)
* _Privilege escalation in build pipelines_ Andreas Sieferlinger (Scout24)
    - [slides](https://speakerdeck.com/andreassieferlinger/the-deputy-shot-the-sheriff-privilege-escalation-in-build-pipelines)
* _Grafana and metrics without the hype and anti-patterns_ (wasn't that good finally) Björn Rabenstein (Grafana Labs)
    - [slides](https://cdn.oreillystatic.com/en/assets/1/event/302/What%20remains%20of%20dashboards%20and%20metrics%20without%20the%20hype%20and%20anti-patterns%20Presentation.pdf)
* _Configuration is riskier than code_ Jamie Wilkinson (Google)
    - [event page](https://conferences.oreilly.com/velocity/vl-eu/public/schedule/detail/78800)
* _M3 and Prometheus_  Rob Skillington (Chronosphere), Łukasz Szczęsny (M3)
    - [slides](https://cdn.oreillystatic.com/en/assets/1/event/302/M3%20and%20Prometheus_%20Monitoring%20at%20planet%20scale%20for%20everyone%20Presentation.pdf)
    - [M3 project](https://www.m3db.io/)

## Thursday

Keynotes:

* _Building high-performing engineering teams_ Lena Reinhard (CircleCI)
    - [slides](https://cdn.oreillystatic.com/en/assets/1/event/302/Building%20high-performing%20engineering%20teams%2C%201%20pixel%20at%20a%20time%20Presentation.pdf)
    - [recording](https://www.oreilly.com/radar/building-high-performing-engineering-teams-one-pixel-at-a-time/)
    - [speaker's homepage](http://lenareinhard.com/)
* _Controlled chaos: devops and security_ Kelly Shortridge (Capsule8)
    - [slides](https://cdn.oreillystatic.com/en/assets/1/event/302/Controlled%20chaos_%20The%20inevitable%20marriage%20of%20DevOps%20and%20security%20Presentation.pdf)
    - [recording](https://www.oreilly.com/radar/controlled-chaos-the-inevitable-marriage-of-devops-and-security)
    - The "DIE" triad: distributed, immutable, and ephemeral infrastructure

Afternoon sessions:

* _Cultivating production excellence_ Liz Fong-Jones (Honeycomb)
* _Keptn: Don't let your deliver pipelines become your next legacy code_
    - [Keptn](https://keptn.sh/)
* _Stateful systems in the time of orchestrators_ Danielle Lancashire (Hashicorp)
    - [Stateful workloads in Nomad](https://www.nomadproject.io/guides/stateful-workloads/stateful-workloads.html)
* _Consensus is for everyone_ Tess Rinearson (Tendermint Core)
    - [event page](https://conferences.oreilly.com/velocity/vl-eu/public/schedule/detail/78516)
    - [Original Paxos paper](https://lamport.azurewebsites.net/pubs/pubs.html#lamport-paxos)
    - [Consensus on Wikipedia](https://en.wikipedia.org/wiki/Consensus_(computer_science))
    - [Tendermint](https://tendermint.com)

[O'Reilly Velocity]: https://conferences.oreilly.com/velocity/vl-eu
