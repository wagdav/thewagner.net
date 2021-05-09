---
title: Concurrency Patterns
---

In this post I'm replicating in Haskell some of the examples from the talk [Go
Concurrency Patterns][1] by Rob Pike.  In the talk Pike explains how Go's
built-in concurrency primitives can help writing concurrent code.  I was
curious to see how the presented examples would look in Haskell, a language
that I'm interested in learning.

## Simulating a search engine

The example we are going to play with (again, taken from Pike's presentation)
is a simulated search engine.  The search engine receives a search query and
returns web, image and video results.

We start with a simple implementation where the different kinds of search are
performed sequentially, then we gradually add concurrency to build a better
performing search engine.

First we're going to need some imports and some data types to represent our problem.

``` haskell
import Control.Concurrent.Async  (mapConcurrently, race)
import Control.Concurrent        (threadDelay)
import System.Random             (getStdRandom, randomR)
import System.Timeout            (timeout)
import Text.Printf               (printf)

type SearchQuery = String

data SearchKind
    = Image
    | Web
    | Video
    deriving (Show)
```
We represent the search query with a simple string and the kinds of search we
can perform with product-type.  The role of the imported functions will be
clear as we go along.

This is already enough to get us started.  We can write a fake search function
which takes a `SearchQuery`, a `SearchKind` and returns an IO action which, when
run, yields the search result as a string:

``` haskell
-- https://talks.golang.org/2012/concurrency.slide#43
fakeSearch :: SearchQuery -> SearchKind -> IO String
fakeSearch query kind = do
    delayMs <- getStdRandom $ randomR (1, 100)
    threadDelay $ microseconds delayMs -- simulating random work
    return $ printf "%s results for '%s' in %d ms" (show kind) query delayMs

    where
        microseconds = (* 1000)
```
Our search back-end won't get any more sophisticated than this:

* we make the current thread sleep for a random number amount of milliseconds, then
* we return the simulated search results.

The resulting string contains the input parameters and the time it took to
serve this request.  We want to print these results so we write a small helper
function:

``` haskell
-- Helper function to print the results
printResults :: Maybe [String] -> IO ()
printResults req = case req of
    Just res -> print res
    Nothing  -> putStrLn "timed out"
```

This function takes an optional list of strings and prints them on the console.
If the argument is `Nothing` it means that the search request timed out (we
will see this later).  At this stage this function looks more generic than it
needs to be.  Probably you would start with a simpler signature, something
like:

``` haskell
printResults :: String -> IO ()
```

and make it more complex [when needed][2].  This would make more sense and I
also started with this initially.  However, for the sake of this post, we will
use the more generic version above so we can re-use it in the subsequent
examples.

## Search 1.0

The first version of our search engine will perform the image, web and video
searches sequentially:

``` haskell
-- Run the Web, Image, and Video searches sequentally
-- https://talks.golang.org/2012/concurrency.slide#45
search10 :: SearchQuery -> IO ()
search10 query = do
    req <- mapM (fakeSearch query) [Web, Image, Video]
    printResults (Just req)
```
We use `mapM` to sequentially perform the three kinds of searches.  The result
of a typical search using `haskell` as a query would look like:

``` console
["Web results for 'haskell' in 27 ms",
 "Image results for 'haskell' in 61 ms",
 "Video results for 'haskell' in 17 ms"]
```
Since the searches are performed sequentially it takes 27 + 61 + 17 = 105 ms to
serve the results to the user.  This post won't be about concurrency if we were
to stop here.

## Search 2.0

We can speed things up if we can send the three kinds of queries to our
back-end servers independently and wait for the results to come back.  We need
to change one (!) function in our code to arrive to the next version of our
search engine:

``` haskell
-- Run the Web, Image, and Video searches concurrently, and wait for all
-- results.
-- https://talks.golang.org/2012/concurrency.slide#47
search20 :: SearchQuery -> IO ()
search20 query = do
    req <- mapConcurrently (fakeSearch query) [Web, Image, Video]
    printResults (Just req)
```

The `mapConcurrently` combinator from the [async][3] library will launch three
light-weight threads and perform the three search actions concurrently.  The
output of the program is similar (clearly the random timings will change), but
it runs faster.  The running time will be limited by the _slowest_ search
query.

We get a completely different behavior, but our code has the same structure as
the sequential version.  We don't have to use locks, mutexes, callbacks, etc.
the code clearly expresses our intent.  It feels like we got concurrency _for
free_.


## Search 2.1

The concurrent version performs really well, but there might be cases where the
slowest request would be very slow for some reason.  Users get angry if things
are slow, so we'd better display an error message if we cannot display a
results within a given amount of time.

We introduce a maximum delay (80 ms in this example): if the slowest request
takes longer then this, instead of the search results, we display a "timed out"
message and we send our sincerest apologies to our user.

``` haskell
-- Don't wait for slow servers
-- https://talks.golang.org/2012/concurrency.slide#47
maxDelay :: Int
maxDelay = 80 * 1000 -- us

search21 :: SearchQuery -> IO ()
search21 query = do
    req <- timeout maxDelay $
        mapConcurrently (fakeSearch query) [Web, Image, Video]
    printResults req
```
Again, we only have to do a small modification to get the desired behavior.  The search actions are wrapped in a `timeout` call.  The signature of this function is:

``` haskell
timeout :: Int           -- maximum delay in microseconds
        -> IO a          -- the action to perform
        -> IO (Maybe a)  -- (Just a) if the action takes less than the delay else Nothing
```

We can run this version a couple of times and we will see two kinds of outputs.  If all requests take less than 80ms `printResults` will behave as before:

```
["Web results for 'haskell' in 70 ms",
 "Web results for 'haskell' in 67 ms",
 "Video results for 'haskell' in 63 ms"]
```
otherwise, and this is why `printResults` takes a `Maybe [String]` as input,
```
timed out
```
is printed.

## Search 3.0

We can still do better.  The occasional timeout messages are still annoying.
We won't be too popular if our search website times out too often.  It's also a
waste to discard all the results from slow servers.  Maybe only the video
search is slow, but we still throw away the web and image results.

We can use replication to reduce the chance of a timeout.  We will send the
request to two sets of back-end servers, two replicas.  If one replica has some
problem and responds slowly we can still get back a response from the other.

We write a function `fastest` that does exactly this:

``` haskell
-- https://talks.golang.org/2012/concurrency.slide#48
fastest :: SearchQuery -> SearchKind ->  IO String
fastest query kind = do
    req <- race (fakeSearch query kind) -- server 1
                (fakeSearch query kind) -- server 2

    return $ case req of
        Left  r -> "Server1: " ++ r
        Right r -> "Server2: " ++ r
```
This function have the same interface as `fakesearch` but internally it sends
the same query two times to two different servers and keeps the result from the
fastest.  The `race` combinator from the [async][4] library:

``` haskell
race :: IO a -> IO b -> IO (Either a b)
```
helps us to achieve this.  It launches the two IO actions in parallel and keeps
the result from the fastest.  The other action will be terminated.  There is no
second price in this race.  The return value will indicate which action won.
We prepend the server name to our search result to be able to see where it was
served from.

We now replace the `fakeSearch` call with `fastest` and we get:

``` haskell
-- Send requests to multiple replicas and use the first response
-- https://talks.golang.org/2012/concurrency.slide#50
search30 :: SearchQuery -> IO ()
search30 query = do
    req <- timeout maxDelay $
        mapConcurrently (fastest query) [Web, Image, Video]
    printResults req
```

Let's see some typical results:

``` console
$ search30
["Server1: Web results for 'haskell' in 29 ms",
 "Server1: Image results for 'haskell' in 36 ms",
 "Server2: Video results for 'haskell' in 49 ms"]

$ search30
["Server2: Web results for 'haskell' in 19 ms",
 "Server2: Image results for 'haskell' in 50 ms",
 "Server1: Video results for 'haskell' in 39 ms"]
```

We can see that in the first run the web and image results were served by the
first replica, while the video result comes from the second.  In the second
example the first replica served the video results and the second replica the
other two.  Any combination is possible, these are just results from two runs.

With the version 3.0 we can serve the results of all three searches with very
high probability within 80 ms.

## Summary

As [Rob Pike puts it][5], with a few transformations we converted a

* slow
* sequential
* failure-sensitive

program into one that is

* fast
* concurrent
* replicated
* robust

I was surprised to see how little the code structure changed in the Haskell
versions.  We significantly changed the behavior of the program without
compromising the readability.  We didn't have to use locks and mutexes, but we
could focus on the intent, _what_ the program should do, thanks to the powerful
libraries and the run-time system.

I recommend to watch [the original talk on YouTube][6] and to further compare
the Haskell and the Go implementations.  You can find the code
[here](https://github.com/wagdav/haskell-concurrency-patterns).


[1]: https://talks.golang.org/2012/concurrency.slide
[2]: https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it
[3]: http://hackage.haskell.org/package/async-2.2.1/docs/Control-Concurrent-Async.html#v:mapConcurrently
[4]: http://hackage.haskell.org/package/async-2.2.1/docs/Control-Concurrent-Async.html#v:race
[5]: https://talks.golang.org/2012/concurrency.slide#52
[6]: http://www.youtube.com/watch?v=f6kdp27TYZs
