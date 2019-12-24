---
title: The essence of a CI/CD pipeline
---

Practitioners of [continuous integration][Wikipedia-CI] often describe the
process of [automated software delivery][Wikipedia-Build-Automation] as a
_pipeline_: the source code enters the pipe, it is compiled, tested, packaged
and released product comes out on the other end.

This methaphor evokes the notions of delivering, modularity and continuity.
Teams of different backgrounds relate to this image even without understanding
each transformation step.

But what is a software delivery pipeline?  In this post, instead of a metaphor,
I propose a precise mathematical model of it.


## Concept zoo

I reviewed five popular CI/CD systems where users model their software delivery
process by defining a pipeline:

* [Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?view=azure-devops)
* [CircleCI](https://circleci.com/docs/2.0/concepts/#section=getting-started)
* [Concourse](https://concourse-ci.org/docs.html)
* [GitHub Actions](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/core-concepts-for-github-actions)
* [GoCD](https://docs.gocd.org/current/introduction/concepts_in_go.html)

Let's see how the relevant user documentation describe the pipeline and its
related concepts.


### Task, action, step

The reviewed systems call the pipeline's unit of work task, action or step.

Azure Pipelines
> A step is the smallest building block of a pipeline.  A step can either be a
> script or a task.

CircleCI
> A step is an executable command.

Concourse
> A task is the smallest configurable unit.  A task can be thought of as a
> function from inputs to outputs that can either succeed or fail.

GitHub Actions
> Individual tasks that you combine as steps to create a job. Actions are the
> smallest portable building block of a workflow.

GoCD
> A build task is an action that needs to be performed. Usually, it is a single
> command.

The names differ but they all describe a similar concept:  the unit of work is
an executable script or command.

Concourse's task definition proposes a precise semantic model: a task is a
function.  We will build on this model later.


### Job

A job is an ensemble of tasks, actions or steps.

Azure Pipelines
> A job represents an execution boundary of a set of steps.  All of the steps
> run together on the same agent.

CircleCI
> Jobs are collections of steps.

Concourse
> Jobs are sequences steps to execute.

GitHub Actions
> A defined task made up of steps. Each step in a job executes in the same runner.

GoCD
> A job consists of multiple tasks, each of which will be run in order.

At this concept the definitions start to diverge, still there are some common
points:

* actions, tasks or steps build up jobs
* a job's components usually run sequentially
* a job's components usually run on the same build agent, executor or
  runner

The notable exceptions are:

* in Concourse it's possible to run a job's steps
 [in parallel](https://concourse-ci.org/in-parallel-step.html).
* in Concourse and GoCD there are no locality guarantees on where the job's
  tasks are run

These job definitions are [operational][OperationalSemantics] and not
[denotational][DenotationalSemantics]:  instead of defining what a job _means_
they focus on  how a job is _executed_.


### Stage

In some systems jobs can be grouped into a stage.

Azure Pipelines
> A stage is a logical boundary in the pipeline.  Each stage contains one or
> more jobs.

GoCD
> A stage consists of multiple jobs, each of which can run independently of the
> others.

Azure Pipelines runs the stages sequentially by default, but arbitrary ordering
can also be defined between them.  This includes no ordering at all, meaning
that stages can run concurrently.

CircleCI, Concourse and GitHub Actions don't have this concept.


### Pipeline, workflow

We now are ready to define a pipeline, also called workflow.

Azure Pipelines
> A pipeline defines the continuous integration and deployment process for your
> app.  It's made up of one or more stages.

CircleCI
> Workflows define a list of jobs and their run order.

Concourse
> Pipelines are built around jobs and resources.  They represent a dependency
> flow.

GitHub Actions
> Workflows are made up of one or more jobs and can be scheduled or activated
> by an event.

GoCD
> A pipeline consists of multiple stages, each of which will be run in order.

Jobs or stages are grouped into pipelines.  The definitions are again
operational with an emphasis of execution order and dependencies.


## What is a pipeline, really?

Now we've seen _some_ of the concepts of the most popular CI/CD systems.  Some
systems have even more which I didn't cover here.

Do we need all these to model the software deliver process?


### Task as a function

Let's revisit Concourse's task definition: _A task can be thought of as a
function from inputs to outputs that can either succeed or fail._

This is a great definition because it specifies what a task _means_ and not
what it does or _how_ it does it.  Developers can choose to implement a task as
they deem most fitting but the user can think of it as a function no matter
what.

Let's see some task examples:

* a compilation task takes a source code as input and produces a compiled binary as output
* a test task takes the compiled binary as input and produces a test report as output
* a release task takes the compiled binary and a test report.  If the test
  report is acceptable (no tests fail, test coverage is OK) it releases the
  binary and returns a link to repository where the software can be downloaded

I named the unit of work "task".  As we've seen other systems prefer "step" or
"action", which would be totally fine as well.

Let's write down formally Concourse's task definition.

``` haskell
type Task a b = a -> Maybe b
```

A Task is a _function_ with two type parameters `a` and `b` representing its
input and output types, respectively.  To express possible failure, the output
is wrapped in Haskell's `Maybe` type.  In other languages this is called
`Option`, `optional` or `Result`.

I wrote down this definition in Haskell's syntax but this is not important.
What matters is that our model, the Task's meaning, is mathematical function.

These are the type signatures of the tasks described previously in words:
``` haskell
--         input type        output type
build   :: SourceCode     -> Maybe CompiledBinary
test    :: CompiledBinary -> Maybe TestReport
release :: CompiledBinary
        -> TestReport     -> Maybe PackageURL
```
These are _not_ the implementation of these tasks but their definition
expressed as Haskell code.


### Sequential composition

Let's define a task to tests the incoming pull requests of our project.

This task takes the pull request's source code, builds the binary, runs the
tests and returns the test report.  The test report is for the reviewers to
judge the quality of the proposed change.

In short, we want sequence the tasks `build` and `test`.  If we had an operator
with this type signature:

``` haskell
inSequence :: a -> Maybe b -- first task
           -> b -> Maybe c -- second task
           -> a -> Maybe c
```
we could express the pull request validating task as:

``` haskell
validatePullRequests :: SourceCode -> Maybe TestReport
validatePullRequests = inSequence build test
```
where

* `validatePullRequests` is a `Task` because it's a function with the right
  type signature
* the source code is fed to the first task, `build`
* the resulting type of `build` is `Maybe CompiledBinary`
* if build fails the result of the whole task is failure
* otherwise, feed the compiled binary to `test`

I haven't shown you the definition of `inSequence`, but you can verify that in
the expression `validatePullRequests` the types match.  You can also see that
`inSequence` looks almost like regular function composition except the output
types are wrapped in `Maybe`.


### Parallel composition

Let's consider now two independent tasks:

``` haskell
unitTests        :: SourceCode -> Maybe UnitTestReport
integrationTests :: SourceCode -> Maybe IntegrationTestReport
```

These two test suites could be run in parallel, because they both only depend
on the `SourceCode` value.

We don't want to introduce a new concept, but we want the result of parallel
composition to be a `Task` as well.  We're after an operator with the following
type signature:
``` haskell
inParallel :: (a -> Maybe b)
           -> (a -> Maybe c)
           -> (a -> Maybe (b, c))
```

The composite task yields the results of input tasks as a tuple.  If _any_ of
the two task fails, the result of the composite task is failure (represented by
the value `Nothing`).

Using `inParallel` we could write a task to run all tests:
``` haskell
runAllTests :: SourceCode
            -> Maybe (UnitTestReport, IntegrationTestReport)
runAllTests = inParallel unitTests integrationTests
```

The `inParallel` operator represents a "fan-out" structure in the pipeline
where independent transformation steps are applied on the same input.

## Semantic model

In the previous sections we've defined a denotational model for CI/CD build
tasks:
``` haskell
type Task a b = a -> Maybe b
```
which maps the Task concept to its meaning, a mathematical object.  This serves
not only as a mental model, but also it allows us introduce regular and
powerful composition rules.

I've shown you `inSequence` and `inParallel` combinators. For reference,
without explanation, here are their definitions:
``` haskell
inSequence :: Task a b -> Task b c -> Task a c
inSequence t1 t2 x = t1 x >>= t2
-- or equivalently
                   = t1 >=> t2

inParallel :: Task a b -> Task a c -> Task a (b, c)
inParallel t1 t2 x = liftA2 (,) (t1 x) (t2 x)
```
These combinators are expressed using the task's semantic model without
operational terms or unnecessary limiting assumptions.

It turns out that `inSequence` and `inParallel` are not primitive operations.
Tasks and their composition rules can be defined using a more general
vocabulary of [arrows](https://www.haskell.org/arrows/).  This suggests that
the semantic model is powerful enough to model any software delivery process.

Using this model, jobs, stages, workflows and pipelines are just `Task`s.


## Summary

Today's popular CI/CD systems are built around the metaphor and not a rigorous
definition of a pipeline.  I propose `Maybe`-valued functions as a semantic
model for a build task.  Using well-studied and precisely defined rules, tasks
can be composed to model the software delivery process.

In a future post I will present [an experimental
system](https://github.com/wagdav/kevlar) which uses these principles to
express continuous integration and continuous delivery pipelines.


# Acknowledgement

Many thanks to the members of the [Pix4D](https://pix4d.com) CI team for the
inspirational discussions during coffee breaks.

I'm grateful to [Conal Elliott](https://conal.net) for reviewing an early draft
of this article and for providing valuable feedback.


[CircleCI]: https://circleci.com/
[GitHubActions]: https://help.github.com/en/actions
[GoCD]: https://www.gocd.org/
[Travis]: https://travis-ci.org/
[Wikipedia-Build-Automation]: https://en.wikipedia.org/wiki/Build_automation
[Wikipedia-CI]: https://en.wikipedia.org/wiki/Continuous_integration
[DenotationalSemantics]: https://en.wikipedia.org/wiki/Denotational_semantics
[OperationalSemantics]: https://en.wikipedia.org/wiki/Operational_semantics
[TCM]: http://conal.net/papers/type-class-morphisms/
