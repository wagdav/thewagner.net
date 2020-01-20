---
title: Concurrency without magic
---

_Summary_: I argue that using a library is the best design pattern. The Haskell
ecosystem offers powerful tools for writing concurrent programs.

[In a previous post](/blog/2018/02/26/concurrency-patterns/) I demonstrated some
of Haskell's features to write concurrent programs.  I developed a simulated
search engine which looked like this:

``` haskell
search30 :: SearchQuery -> IO ()
search30 query = do
    req <- timeout maxDelay $
        mapConcurrently (fastest query) [Web, Image, Video]
    printResults req
```

I argued that this was a fast, concurrent, replicated and robust version of the
previous iterations.  In the following sections I am going to improve this
example, therefore I suggest reading [the related post to understand how we got
here](/blog/2018/02/26/concurrency-patterns/).


## The faster wins

In the heart of the `search30` function we find this helper function:

``` haskell
fastest :: SearchQuery -> SearchKind ->  IO String
fastest query kind = do
    req <- race (fakeSearch query kind) -- server 1
                (fakeSearch query kind) -- server 2

    return $ case req of
        Left  r -> "Server1: " ++ r
        Right r -> "Server2: " ++ r
```

`fastest` sends the search query to two replicas of the search backend and
keeps the result from the faster responding server.  The `race` function from
the [async][Async] library runs two actions concurrently and returns the result
of the faster.  The slower action is terminated.

In real code you would replace the `fakeSearch` function with an appropriate
search API call but the structure of the function would not change
significantly.

For the sake of this post we explicitly prepend the name of the server from
which the result came.  In a real application this would not be displayed to the
user.  However, we could still store some information about the response's
origin for further analysis.

This implementation of `fastest` works well, but only in the special case of
two servers.  What if we want to use more replicas?  Let's see how we can add
support for any number of back-end servers.


## More general race

Instead of racing two processes, we start `N` instances of the `fakeSearch`
action concurrently and receive the result of the fastest.  This is a recurring
pattern in concurrent programming: start many computations and signal if _any
of them_ completed execution.  In many programming languages, for example
[Python][WaitPython] and [C#][WaitC#], you find library functions to solve
this problem.  The naming and the implementation slightly changes from one
language to another, but the underlying concept is the same.

The `race` function served us well, so let's keep digging in the [async][Async]
library for something that can help us out again.  It doesn't take too long to
locate these two functions:

``` haskell
waitAny :: [Async a] -> IO (Async a, a)
-- Wait for any of the supplied Asyncs to complete.

waitAnyCancel :: [Async a] -> IO (Async a, a)
-- Like waitAny, but also cancels the other asynchronous operations as soon as one has completed.
```

This looks promising: we can use `waitAnyCancel` to achieve the same behavior
as `race` but for a list of asynchronous operations.

We cannot just replace `race` with `waitAnyCancel` because the type signatures
of the two functions are different.  For reference, this is `race`:

``` haskell
race :: IO a -> IO b -> IO (Either a b)
```

We need to think a bit more how to fit `waitAnyCancel` into `fastest`.

## Building blocks

The central type of the async library, `Async a`, represents an asynchronous
operation that yields a value of type `a`.  Asynchronous operations can be
spawned using the `async` function:

``` haskell
async :: IO a -> IO (Async a)
```

The type of the expression `fakesearch query kind` is `IO String`.  Feeding
this to `async`, `async (fakesearch query kind)`, we get an `IO (Async String)`
which launches the search asynchronously in a separate thread.  We could
replicate this `N` times and use `waitAnyCancel` to select the fastest query.
However, if we went down this path we would be unable to identify which server
replica gave us the fastest answer.  We would only get back the search
result, but not the winner replica's identity.

When we used `race` it was easy to identify the faster replica because we used
pattern matching on the returned `Either` value.  `waitAnyCancel` does not give
us any hint on _which_ action in the provided list was the fastest.

Now, because `IO a` is a functor, we can use `fmap` (usually abbreviated as
`<$>`) to apply a function on the result of the search operation.  Let's write
a function which prepends the server's identity to the search result:

``` haskell
-- prepend the server's identity to the search result
servedBy i result = "Server " ++ (show i) ++ ": " ++ result
```

For example, in case of the second server replica the transformed search action
would read: `servedBy 2 <$> fakeSearch query kind`.  The type of this
expression is still `IO String` but it yields the search result with the server
name prepended.

Let's go over the series of transformation steps and see how the expressions
and their types were modified:
``` haskell
-- the search API
fakesearch :: SearchQuery -> SearyKind -> IO String

-- fill in the arguments to get IO action that yields a string
fakesearch query kind :: IO String

-- prepend second replica's identity to the search result
servedBy 2 <$> fakesearch query kind :: IO String

-- a function which prepends the provided replica number to the search result
\i -> servedBy i <$> fakesearch query kind :: Int -> IO String

-- same as before but as an asyncronous action
\i -> async (servedBy i <$> fakesearch query kind) :: Int -> IO (Async String)
```

In the last two lambda-expressions I kept the replica number as a free
parameter, a form we can reuse in the final step.

## Final implementation

Let's assemble the new `fastest` implementation from the pieces we have:

``` haskell
fastest :: SearchQuery -> SearchKind ->  IO String
fastest query kind = do
    requests <- forM [1..numReplicas] $ \i ->                           -- ①
        async (servedBy i <$> fakeSearch query kind)  -- <$> is `fmap`  -- ②
    (_, result) <- waitAnyCancel requests                               -- ③
    return result                                                       -- ④

  where numReplicas = 3
        servedBy i result = "Server " ++ show i ++ ": " ++ result
```

① Use `forM` to transform a list of integers, the replica identifiers, by
  applying the provided function. `requests` has a type `[Async String]`,
  exactly what `waitAnyCancel` needs.

② The second argument of `forM` is the transformation function which creates
  an asynchronous operation yielding the search result with the replica's
  identity prepended

③ Call `waitAnyCancel` and extract the result from the fastest search
  operation (we don't use first element of the returned tuple)

④ Provide result of the current IO operation

This implementation, only six lines of code,  works with any number of
replicas.  For `numReplicas=2` its behavior is identical to that of the old
one.

## Summary

We replaced the original implementation of the `fastest` function, only capable
of supporting two server replicas, into a more general one which works with any
number of replicas.

The implementation relies on a single library function `waitAnyCancel` but we
needed to arrange the asynchronous search operations in a way that is
compatible with `waitAnyCancel`'s type signature.  We used generic combinators
such as `fmap` and `forM` to achieve this.  The `search30` requires no
modifications, as the type signature of `fastest` didn't change.

We wrote concurrent code with no locks, no mutexes and no [concurrent design
patterns][ConcurrencyPatterns] to remember.  We manipulate asynchronous
computations as values and call library functions.  This is possible because
the [async library][Async] exposes generic and composable primitives and hides
the complexity of thread management.  Also the language provides powerful
combinators such as `fmap` for implementing our programs.

You can find the examples given here as [executable code on GitHub][GithubConcurrency].

The inspiration of this and [the previous post][PostConcurrency] came from the
Go examples presented in [Rob Pike's Concurrency is Not Parallelism
talk][GoConcurrency].

[PostConcurrency]: /blog/2018/02/26/concurrency-patterns/
[Async]: http://hackage.haskell.org/package/async-2.2.1/docs/Control-Concurrent-Async.html
[GithubConcurrency]: https://github.com/wagdav/haskell-concurrency-patterns

[WaitC#]: https://docs.microsoft.com/en-us/dotnet/api/system.threading.tasks.task.waitany?view=netframework-4.8
[WaitPython]: https://docs.python.org/3/library/asyncio-task.html#asyncio.wait
[GoConcurrency]: https://talks.golang.org/2012/concurrency.slide
[ConcurrencyPatterns]: https://talks.golang.org/2012/concurrency.slide#24
