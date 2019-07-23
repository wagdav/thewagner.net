title: Consistent vocabulary in control flow

Mainstream programming languages provide various constructs for [control
flow](https://en.wikipedia.org/wiki/Control_flow): conditionals, loops,
exceptions, etc.  Many of these can be modeled using the general
[functor](https://en.wikipedia.org/wiki/Map_(higher-order_function)#Generalization)
concept.  In this post I'm going to show you how.

In most programming languages defining a function (or a method, subroutine,
procedure, etc.) is simple.  _Using_ this function in a real program is more
complex: the function's arguments may be missing (None, NULL, nil, etc.), the
computation in the function may fail because of an unexpected condition, the
function's input argument may be the result of an asynchronous call.

In a real program a function call appears in a specific context with a
particular control flow.  In a given context specific edge cases appear which
we must handle as well.

In the next sections I show you how a simple function is typically used in
different contexts.  I'm using examples written in Python and Haskell.


## Modeling a camera

As a working example, let's model a camera with a projection from a
three-dimensional world point coordinates to two-dimensional image point
coordinates.

In Haskell the type signature of such a function is:
``` haskell
project :: WorldPoint -> ImagePoint
```
where I assume that some reasonable definitions of `WorldPoint` and
`ImagePoint` exist.  That is, given a world point `project` returns a point on
the camera's image plane.

In Python the outline of this function would read:
``` python
def project(world_point):
   ...
   return image_point
```

The concrete implementation of `project` is not important.  For the sake of
this article we can assume that all relevant camera parameters are available in
the function's body.

Let's see how we could use the `project` function in various contexts.


## Simplest case

We designed our function to be pure, free of side-effects.  Projecting a single
world point is just a matter of calling `project`.  It's easy both in Python

``` python
project(world_point)
```
and Haskell:

``` haskell
project worldPoint
```

In a real world program, however, the situation is rarely that simple.


## Missing value

Imagine that a preceding computation provides an empty world point to our
program.  We would like to use `project` in this context where the world point
may not be present.

In Python, the missing value could be represented as a `None` value.  Let's use
a conditional to check for it:

``` python
if world_point:
    image_point = project(world_point)
    # use image_point
else:
    # handle the missing value
```

This is a common pattern, you find such conditionals in every code base.

In Haskell we could accept the world point wrapped in a `Maybe` type and use
`fmap` to compute a projection in case the world point value is present:

``` haskell
let maybeImagePoint = fmap project maybeWorldPoint
```
where the type of the input and output values are `Maybe WorldPoint` and `Maybe
ImagePoint`, respectively.

This works, because `Maybe` is a functor.  This means we can use the function
`fmap` to lift our pure `project` function to operate on potentially missing
values.

## Handling a scene

We rarely work with a single world point, but with a collection of world points
which I call here a _scene_.

If we wanted to project an entire scene on a camera, in Python we could use a
list comprehension and write:
``` python
image_points = [project(world_point) for world_point in scene]
```
or more succinctly, using the built-in `map` function:
``` python
image_points = list(map(project, scene))
```
In [Python 3](https://pythonclock.org/), `map` returns an iterator which we
explicitly convert to a list.

In Haskell, choosing a simple list representation for Scene, we write:
``` haskell
-- type Scene = [WorldPoint]
let imagePoints = fmap project scene
```
where the type of `imagePoints` is a list of image points.

This is almost identical to the Python code using `map`.  List is a functor,
`fmap` on list applies the provided function on each element.  This is exactly
`map` as we know it from Python.


## Input from a data file

Let's imagine that the world point is stored on disk in a data file.  Before we
can apply `project` we need to read and decode the data file.

In Python, we wrap the file operation in a `try-except` block:
``` python
try:
   world_point = read_data_file(...)
   image_point = project(world_point)
except (DecodeError e):
   # handle the error
   ...
```
This is also fairly common pattern:  the exception handler, if we don't forget
to write it, allows us to handle the potential errors.

In Haskell, it's again just `fmap`:
``` haskell
-- worldPointOrError :: Either WorldPoint DecodeError
-- imagePointOrError :: Either ImagePoint DecodeError
let imagePointOrError = fmap project worldPointOrError
```

Here `Either WorldPoint` is the functor and `fmap` acts as follows: if the
decoding is successful `project` is applied on the returned value.  In case of
error the `project` function is not used at all and `imagePointOfError` will
contain the returned error value.

Because the potential failure is encoded in the data type we cannot forget
about error handling: that code would just not compile.

## Asynchronous request

Finally let's assume that we read the world point from the network.  Network
communication requires a lot of input/output so let's do it concurrently with
other tasks of our application.

In Python, using the [asyncio
library](https://docs.python.org/3/library/asyncio.html) we can write
concurrent code using the async/await syntax:

``` python
async def read_from_network():                  # ①
    await asyncio.sleep(1)
    return (0, 1, 2)  # dummy value

async def async_image_point():                  # ②
    return project(await read_from_network())

image_point = asyncio.run(async_image_point())  # ③
```

1. `read_from_network` is a coroutine simulating an asynchronous action
   obtaining the world point.  In a real application this operation would run
   concurrently with other coroutines.

2. `async_image_point` applies the projection on the value returned by
   `read_from_network`.  This is also a coroutine and it completes after the
    network communication has finished.

3. `asyncio.run` blocks until the provided coroutine delivers its return value.
   `image_point` is now a regular image point value.

Now let's see how something similar works in Haskell:
``` haskell
readFromNetwork :: IO WorldPoint            -- ①
readFromNetwork = do
  threadDelay 1000000 -- µs
  return (0, 1, 2)    -- dummy value

imagePoint :: IO ImagePoint
imagePoint = do
  worldPoint <- async readFromNetwork      -- ②
  wait (fmap project worldPoint)           -- ③
```

1. `readFromNetwork` simulates the network IO: the body of this function can be
   replaced with calls to a real networking library which do not know anything
   about asynchronous operations.

2. Spawn the network operation asynchronously in a separate (lightweight)
   thread.  Note that `async` is just a [library
   function](https://hackage.haskell.org/package/async-2.2.2/docs/Control-Concurrent-Async.html#v:async),
   not a special keyword.

3. We use `fmap` to lift the transformation into the asynchronous computation,
   then `wait` blocks until the asynchronous action completes.

By looking at the type signature of `fmap` specialized to this example:
```
fmap :: (WorldPoint -> ImagePoint) -> Async WorldPoint -> Async ImagePoint
```
We can see that `fmap` constructs a new asynchronous action where the provided
function is applied to the result of the provided asynchronous action.  It
reaches under the `Async` constructor and transforms the underlying values.


# Summary

We looked at how a pure function is used in four different computational
contexts: missing values, collections, potentially failing and asynchronous
actions.

In Python we used different, specialized language constructs to apply our `project` function:

* _conditional_: to handle the case when the input point may be missing
* _list comprehension (or loop)_: when the function is applied on a collection of points
* _try-except block_: when the data file decoding may fail
* _special keywords async/await_: when the function operates on results of asynchronous computations.

In Haskell we always used `fmap`, because these seemingly different
computations can all be modeled as a functor.  Instead of using special
language keywords we used one [organizing principle borrowed from
Mathematics][FPIn40Minutes] where the control flow and the edge cases are
precisely defined.

You can read more about functors on the [Haskell
wiki](https://wiki.haskell.org/Functor) or elsewhere on the Internet.

For the topic I took inspiration from the talk [The Human Side of Haskell by
Josh Godsiff][HumanSideOfHaskell].

[HumanSideOfHaskell]: https://www.youtube.com/watch?v=Z0vkQLLUVGw
[FPIn40Minutes]: https://www.youtube.com/watch?v=0if71HOyVjY
