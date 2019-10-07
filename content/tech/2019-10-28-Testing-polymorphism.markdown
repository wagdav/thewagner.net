---
title: Polymorphism and testing
---

Recently I [contributed a retry functionality][PR] to the cache-s3 Haskell
project.  After I had shared a draft PR with [Alexey
Kuleshevich](https://github.com/lehins), the project's maintainer, he suggested
some improvements.  In this post shall describe a simplified version of the
resulting upstream pull-request and explain how it works.

# Retrying in case of failure

Retrying is a simple error recovery algorithm.  Communicating software
components regularly experience network failures.  If the network outage is
intermittent, retransmitting the data shortly after a failing transfer may
succeed. Thus, reducing the apparent error rate of the subsystem.

[cache-s3] is used by continuous integration (CI) systems for storing a
compilation cache database in an S3 bucket.  Typically, a successful build is
followed by the upload of the cache database, so that it can be reused by the
next build.  If the database upload fails the CI system fails the whole build
task.  This is annoying when you waited a long time for your build, but now you
have no build and nor a saved cache database.  You have to start everything
again...

Instead, if the upload to the bucket is retried a couple of times the
intermittent network problem is completely hidden from the user.


# Give me an integer

In cache-s3 [a complex HTTP request is retried][PR], in this post I'm using a
simpler example.  The action we will retry is a question: we ask the user for an
integer:

``` haskell
question :: IO (Maybe Int)
question = do
  putStr "Give me an integer: "
  readMaybe <$> getLine
```

This function returns `Nothing` if the user enters anything but an integer.

``` shell
GHCI> question
Give me an integer: 5
Just 5

GHCI> question
Give me an integer: FOO
Nothing
```

If this question is a part of a longer quiz we let the user guess again before
we fail the whole program.  We would like to write a function `retry` with the
following type signature:

``` haskell
retry :: Int -> IO (Maybe a) -> IO (Maybe a)
```

This function takes two arguments: the number of times to retry and the action
to run.  It returns a more perseverant action with the retry logic "baked-in".
In other words the `retry` alters the action's runtime behavior, but it doesn't
change its type.

`retry` will operate like this:

``` none
GHCI> retry 3 question
Give me an integer: text
Retrying 1/3
Give me an integer: 5.5
Retrying 2/3
Give me an integer: 5
Just 5
```

In this example, after the second additional attempt the integer's was finally received.


# Implementing retry

Here's an implementation of `retry`:

``` haskell
retry
  :: Int -- ^ number of times to retry
  -> IO (Maybe a) -- ^ action to retry
  -> IO (Maybe a)
retry n action = action >>= go 1                             -- ①
  where
    go i (Just res) = return (Just res)                      -- ②
    go i Nothing                                             -- ③
      if i > n
        then return Nothing                                  -- ④
        else do
          putStrLn $ "Retrying " <> show i <> "/" <> show n  -- ⑤
          res' <- action                                     -- ⑥
          go (i + 1) res'                                    -- ⑦
```

This function uses a recursive inner function, called `go` by convention.

1. The provided action is executed and its result is passed to `go`
2. The action succeeded, just return its result
3. The action failed, try again
4. If limit is reached we return `Nothing`
5. Otherwise inform the user about the retry in progress
6. Re-execute the action
7. Pass the result to the next iteration of `go`

In real code we'd [wait a bit][Backoff] before step ⑥ , but now I'm skipping
this.  You can load this function into an interactive session and try how it
works.  You should see an output similar to that in the previous section.

Notice that `retry` is polymorphic in the action's return type `a`.  In the
function's body we don't manipulate this value at all, therefore `a` can stand
for _any_ type.

Let's develop an automatic test for this function and convince ourselves and
our colleagues that this function really does what it's supposed to do.  The
bad news is that in its current shape this function is hard to test because
it's doing too much IO operations.

Next, we are going to make `retry` more polymorphic and more testable.


# Make it more polymorphic

The problem with the first implementation is the appearance of `IO`.  We need
to get rid of that.  Notice that in the function's body we don't do _abitrary_
IO operation but really just calling `putStrLn` as a logging function.  The
appearance of the bind (`>>=`) operator tells us that we exploit that IO is a
monad.

Inspired by these two observations we replace `IO` with a generic `m` type
constructor with two constraints:

``` haskell
retry :: (Monad m, HasLogFunc m) => Int -> m (Maybe a) -> m (Maybe a)
```

The `Monad` typeclass is part of the Prelude ("built-in"). We define the
`HasLogFunc` class ourselves:

``` haskell
class HasLogFunc m where
  logInfo :: String -> m ()

instance HasLogFunc IO where
  logInfo = putStrLn
```

The first two lines defines the `HasLogFunc` as an interface where `logInfo`
must be implemented.  The last two lines provide `IO` with an instance of this
interface: the implementation of `logInfo` is just `putStrLn`.

With the following modifications we obtain to a more generic form of `retry`:

``` haskell
retry ::
     (Monad m, HasLogFunc m)                                -- ①
  => Int         -- ^ number of times to retry
  -> m (Maybe a) -- ^ action to retry                       -- ②
  -> m (Maybe a)

-- same code as before

          logInfo $ "Retrying " <> show i <> "/" <> show n  -- ③

-- same code as before
```

1. Two constraints restrict what `m` can be: it must be a monad and must have a log function
2. Instead of `IO`-only, the function operates on generic actions of `m`
3. We replace `putStrLn` with `logInfo` which is available in `HasLogFunc` environment

This version works exactly the same as the first attempt because `IO` is a
monad and we took care of its `HasLogFunc` instance.

# More polymorphic, more testable

This new version of `retry` is more testable because in our test code we are
free to use any `m` (given it satisfies the constraints we imposed) to express
our assertions.  To demonstrate this let's test if the right sequence of error
messages are displayed to the user.  For example, if we had an action which
always fails:

``` haskell
alwaysFails :: FakeAction (Maybe String)
alwaysFails = return Nothing
```

We'd expect retries until the specified number of attempts is exhausted.

We want our tests to be pure therefore,  instead of using `IO`, we implement a
`FakeAction` type using the [Writer monad][WriterMonad]:

``` haskell
type FakeAction = Writer [String]
```

This is a _monad_ which aggregates the log messages of type `String`.  We
specify what `logInfo` means in this context:

``` haskell
instance HasLogFunc FakeAction where
  logInfo msg = tell [msg]
```

Now we can express the always failing scenario:

``` haskell
describe "retry" $ do
  it "gives up after the specified time" $
    runWriter (retry 3 alwaysFails) `shouldBe`
    ( Nothing
    , [ "Retrying 1/3"
      , "Retrying 2/3"
      , "Retrying 3/3"
      ])
```

`runWriter` returns the result of the provided action, in this case `Nothing`,
paired up with the log messages which were produced during the evaluation.
`FakeAction` is pure, it doesn't do any IO, but it helps us to test `retry`'s
behavior.

This testing strategy can be further extended to cover other types of effects.
In [the complete code samples on GitHub][GitHub] you'll see how I implemented
exponential back-off: in production `retry` waits some seconds before it
re-executes the action, however the test code is pure, running fast without any
side-effects.


# Summary

In this post I presented a simplified version of [this pull-request][PR] which
adds a simple retry mechanism to [cache-s3].

I showed that we can make a function more testable by making it a more generic.
Polymorphism allows us to inject test points into our function.  This is often
achieved by mocks and fakes in traditional programming languages.  In Haskell
exploiting polymorphism is particularly elegant because we can code against
powerful, abstract interfaces such as the monad.

The code is available on [GitHub][GitHub].


[PR]: https://github.com/fpco/cache-s3/pull/25/files
[cache-s3]: https://www.fpcomplete.com/blog/2018/02/cache-ci-builds-to-an-s3-bucket
[Backoff]: https://en.wikipedia.org/wiki/Exponential_backoff
[WriterMonad]: https://hackage.haskell.org/package/mtl-1.1.0.2/docs/Control-Monad-Writer-Lazy.html
[GitHub]: https://github.com/wagdav/polymorphism-and-testing
