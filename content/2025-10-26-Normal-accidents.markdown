---
title: Normal accidents
---

This summer I read _Normal Accidents_ by Charles Perrow, which analyzes
failures in the nuclear industry, petrochemical plants, planes and airways,
marine transport, and other earthbound systems like dams and mining. In the
book's title the word "normal" means _systemic_, accidents that involve the
unanticipated interaction of many failures.  Perrow argues that complex and
tightly coupled systems with catastrophic potential have an _inherent_
susceptibility to normal accidents.

# No easy explanations

Perrow found that most accident analysis reports simplistically conclude that a
unit failure, an operator error, or poor management caused an accident.

For instance, in Chapter 6 _Marine Accidents_, Perrow analyzes ship collisions,
a large majority of which occur in inland waters in clear weather with a pilot
on board.  Furthermore, the two ships often do not initially follow a collision
course; instead, one or both change course after becoming aware of the other in
a manner that effects a collision.  The crews had years of experience, the
ships had all systems operational and neither ship intended to crash into the
other.

Marine transport, including the ships, their crew and all the built-in safety
devices form a complex system where interactions may occur in an unexpected
sequence.

![Figure1]({static}/images/normal-accidents-perception.svg)

We reason about the behavior of a complex system via our own mental model.  We
use this model to draw conclusions about interactions which we cannot directly
see.  This helps us tremendously in finding problems when things go wrong.  On
the contrary, we may also reject signals from the system that contradict our
own model of the world.

Instead of blaming a single component or a person, Perrow develops his DEPOSE
framework which considers the Design, Equipment, Procedures, Operators,
Supplies and materials, and the Environment of a system.  The interactions
among these aspects determine how a system behaves and how it fails.

# System, subsystem, units and parts

Perrow uses a four-level hierarchical system model composed of parts, units,
subsystems, and the full system.  For example, a nuclear power plant as the
system comprises a cooling subsystem which contains a steam generator unit with
many parts like pumps, motors and piping.

![Figure2]({static}/images/system-levels.svg
           "Hierarchical system of subsystems, units and parts")

I highlighted a unit that belongs to two subsystems, often called a
"common-mode unit".  For example, if two subsystems use a single electricity
source, a power outage may immediately disrupt both.  Most systems contain such
units, often for economic or efficiency reasons.

Most systems include safety features, often implemented as extra parts and
units. Paradoxically, the addition of more safety mechanisms often increases
the possibility of unanticipated interactions with existing components.

# Interaction and Coupling

I reproduced Figure 3.1 (and later repeated as Figure 9.1) from the book, which
organizes human and technological systems by the nature of interaction and
coupling.

![Figure3]({static}/images/interaction-coupling.svg
           "Reproduction of the interaction/coupling chart (Figures 3.1 and
           9.1)")

A system does useful work because its components interact with each other.
Valves open and close to control the coolant's flow.  Public officials exchange
ideas and documents in a government agency.  A conveyor belt moves the car to
the next assembly phase.  By the nature of interaction Perrow arranges systems
from _linear_ to _complex_.

Perrow defines linear interactions as those that occur in some expected
sequence.  People can see and understand the cause and effect relationships in
such interactions, even when they fail.  As shown in the figure above, linear
interactions dominate assembly-line production.  In a car factory, when a
workstation on a line malfunctions, parts pile up _before_ failure point, but
stations _after_ keep working until they don't receive new pieces anymore.
Furthermore, a failure on one assembly line typically doesn't affect
neighbouring lines, at least not immediately.

On the right-hand side of the diagram we find complex systems with many hidden,
hard-to-understand interaction patterns.  Perrow spends an entire chapter on
describing the [Three Mile Island][WikiTMI] accident.  He argues that operators
couldn't have possibly made better decisions during the accident because of the
inherent complexity of a nuclear plant.

The vertical axis of the figure represents coupling.  Tightly coupled systems
have more time-dependent processes: they cannot wait or stand by until attended
to.  We cannot change resource quantities and qualities, we cannot easily
substitute supplies, equipment or personnel.  We cannot switch the order
operations because often we only have one way to reach the production goal.

Perrow also applies his analysis to sociological systems like schools and R&D
firms. For example, a junior college highly regulates the sequences of classes
while at a university, students have more liberty to complete their required
credits.  By the book's definition, this makes a junior college more tightly
coupled than a university.  A university doesn't just teach, but also organizes
research, collaboration with industry often involving politics.  This makes a
university, as a system, more complex than a junior college.

# Fixing complex, tightly coupled systems

According to Perrow's thesis, normal accidents occur in tightly coupled systems
with complex interactions.  Reducing either complexity or coupling would make
such systems safer, but often the laws of nature prevent such changes.  Most
physical and chemical reactions only occur under specific conditions, requiring
us to build control and safety systems around them.

If we cannot change a complex, tightly coupled technology — and we don't want
to abandon it —, perhaps we could prepare ourselves better to face unforeseen
events.

In linear systems, where the unforeseen rarely occurs, designers rely on
standards and regulations, operators complete training sessions to handle not
only everyday operation but also failures.  In other words, linear systems
favor centralization.

Centralization also has beneficial effects on tightly coupled systems.  With
little buffer time, when a failure occurs the operator has no time to analyze
the situation.  Following a standard recovery procedure stops the failure from
propagating to other parts of the system, and helps recovering normal
operations.

Tightly coupled, complex systems pose incompatible demands during incidents.
While tight coupling imposes unquestioned obedience and fast response from
operators, the complex and incomprehensible nature of interactions requires a
slow search from subsystem to subsystem to even recognize an ongoing incident.

# Summary

Perrow wrote this book in 1984, inspired by the Three Mile Island accident five
years earlier.  The 1999 edition's afterword contains a few extra references to
books and papers that further developed Perrow's ideas, now forming what we
call Normal Accident Theory.  He also added a few speculative sections about
the risks associated with growing number of interconnected computer systems.
Now we know that [Y2K][WikiY2K] problem didn't induce an apocalypse, but we
definitely saw defective software causing catastrophes.

Though _Normal Accidents_ contains many stories where technology went horribly
wrong, Perrow puts humans at the center because we ultimately make the choices
that help or harm others and the environment.

# Acknowledgement

Thanks Rafał for suggesting and lending me this book.

[WikiBook]: https://en.wikipedia.org/wiki/Normal_Accidents
[WikiPerrow]: https://en.wikipedia.org/wiki/Charles_Perrow
[WikiTMI]: https://en.wikipedia.org/wiki/Three_Mile_Island_accident
[WikiY2K]: https://en.wikipedia.org/wiki/Year_2000_problem
