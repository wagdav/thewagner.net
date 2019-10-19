---
title: Load balancer
---

In this post we are going to write a simple load balancer in Haskell.  The design is based on that presented in Rob Pike's [Concurrency Is Not Parallelism][Pike-Concurrency] talk (starting around 22 minutes).  If you are not familiar with this presentation I highly recommend watching it before reading on.  Pike presents an interesting load balancer design and its implementation to show off Go's built-in concurrency primitives.  [Just like last year](/blog/2018/02/26/concurrency-patterns/), I am interested how this example would look in Haskell, a purely functional programming language.

I am presenting some code fragments of the implementation omitting some less-important, plumbing details.  You can find the complete executable code [in this repository][code-github].

## Design

A [load balancer](https://en.wikipedia.org/wiki/Load_balancing_(computing)) distributes workload across multiple computing units.  Load balancing aims to optimize resource use, maximize throughput, minimize response time, and avoid overload of any single resource.  I will call our "computing unit" simply Worker.

I have reproduced here the [outline of the system](https://talks.golang.org/2012/waza.slide#45) we are going to implement:
```
                                   To requester  <──┐
┌───────────┐                                       │
│ Requester │────┐   ┌──────────┐       ┌────────┐  │
└───────────┘    │   │          │─────> │ Worker │──┘
                 │   │          │       └────────┘
┌───────────┐    └─> │          │       ┌────────┐
│ Requester │──────> │ Balancer │─────> │ Worker │────┐
└───────────┘    ┌─> │          │       └────────┘    │
                 │   │          │       ┌────────┐    │
┌───────────┐    │   │          │─────> │ Worker │──┐ │
│ Requester │────┘   └──────────┘       └────────┘  │ │
└───────────┘                                       │ │
                                   To requester  <──┘ │
                                                 <────┘
```

The design comprises three components:

* _Requester_: Sends a unit of work to the system and waits for the result.
* _Balancer_: Receives requests and distributes them among the available workers.
* _Worker_: Executes the requested the work and sends back the result to the Requester.

The components communicate through channels.  I shall use unbounded FIFO channels from the [stm library](https://hackage.haskell.org/package/stm-2.5.0.0/docs/Control-Concurrent-STM-TChan.html)

The interesting part about this design is that the results from the workers do not cross the Balancer.  The worker directly sends back the result to the requester.

## Request

First, let's define the data structure to hold the requests.  This is a type of a request that, when executed, yields a value of type `a`:

``` haskell
data Request a = Request (IO a) (TChan a)
```

The `Request` holds an `IO` action and a result channel:  the action is the executable task at hand, the result channel transmits the result back to the requester.  Both the action and the channel are parametrized over the same type: the result of the task must "fit" in the result channel.

## The task and the Requester

Let's start imagining how the clients would interact with the load balancer.  We generate some work with `randomTask`, a function with the signature:

``` haskell
randomTask :: IO Int
```

Neither the load balancer nor the worker have to know about the internals of this function.  In my implementation `randomTask` draws a number from a uniform distribution, it sleeps that amount of seconds and returns the number as a result.  In other words: the result of `randomTask` is the time it took to complete it.

The `requester` function represent the clients who have some work to perform:

``` haskell
requester :: TChan (Request Int) ^ -- input channel of the load balancer
          -> IO ()
requester balancer = forever $ do
  -- simulating random load
  delayMs <- getStdRandom $ randomR (1, 1000)
  threadDelay (delayMs * 1000)

  -- send the request
  resultChan <- newTChanIO
  atomically $ writeTChan balancer (Request randomTask resultChan)

  -- wait for the result
  async $ atomically $ readTChan resultChan
```

This function is an infinite loop where each iteration sends a request to the load balancer after a random delay.  This is a very primitive way to simulate some load: not realistic, but good enough for now.  The requester creates the result channel, packages it up along with the task, sends the request, and waits for the results asynchronously.  The next iteration will not be blocked.

Note that the interface to the load balancer is a simple _value_.  The `requester` only drops this value in a channel and waits.  It does not care about what happens to the `Request` on the other end of the channel.


## Balancer

As shown in the design, the `Balancer` receives the `Request` from a channel and distributes them among the available workers.

The Balancer holds a pool of workers and a completion channel:

``` haskell
data Balancer a = Balancer (Pool a) (TChan (Worker a))
-- Pool and Worker will be defined later
```

Workers use the completion channel to report to the `Balancer` the completion of a task.  The `Balancer` uses this information to keep track of the load of each worker.

``` haskell
balance
  :: TChan (Request a) -- ^ input channel to receive work from
  -> Balancer a        -- ^ Balancer
  -> IO ()
balance requestChan (Balancer workers doneChannel) = race_                     -- ❶
  runWorkers
  (runBalancer workers)
 where
  runWorkers = mapConcurrently (`work` doneChannel) (map snd $ toList workers) -- ❷
  runBalancer pool = do
    msg <-                                                                     -- ❸
      atomically
      $        (WorkerDone <$> readTChan doneChannel)
      `orElse` (RequestReceived <$> readTChan requestChan)

    newPool <- case msg of                                                     -- ❹
      RequestReceived request -> dispatch pool request
      WorkerDone      worker  -> return $ completed pool worker

    runBalancer newPool                                                        -- ❺
```

As expected, this is the most complex part of the system.  Let's walk through it step by step:

1. The `balance` function runs the workers and the balancer itself asynchronously.  The `race_` combinator is from the [async package](https://hackage.haskell.org/package/async-2.2.1/docs/Control-Concurrent-Async.html#v:race_) and I talked about it in a [previous post](/blog/2018/02/26/concurrency-patterns/).  It runs its two arguments concurrently and it terminates if any of those two terminate.

2. `runWorkers` concurrently executes the workers.  The function `work :: Worker a -> TChan (Worker a) -> IO ()` is part of the Worker API and makes the worker process requests in an infinite loop.  I shall present the details of the `Worker` in the next section.

3. The balancer waits for new messages on the request and completion channels.

4. Depending on the received message `runBalancer` calls either `dispatch` or `completed`.  These two functions implement the load balancing strategy and update the state of the worker pool.

5. `runBalancer` recursively calls itself with the updated worker pool.

The `RequestReceived` and the `WorkerDone` are data constructors of an internal type `ControlMessage`:

``` haskell
data ControlMessage a = RequestReceived (Request a)
                      | WorkerDone (Worker a)
```

This type "tags" the incoming message so we can differentiate from where it was originated.

The communication channels of the `Balancer` are now wired up; we are ready to implement the load balancing strategy.  Following the [the original design][Slide-Design], I shall implement the worker pool using a [heap][Wikipedia-Heap] from the [Data.Heap](https://hackage.haskell.org/package/heap-1.0.4/docs/Data-Heap.html) module.

``` haskell
type Pool a = DH.MinPrioHeap Int (Worker a)
```

This heap stores priority-worker pairs `(Int, Worker a)`.  The priority represents the number of tasks assigned to the worker.  Because we are using `MinPrioHeap` the pair with minimal priority, that corresponding to the least loaded worker, is extracted first.

The two functions `dispatch` and `complete`, introduced in the definition of `balance`, manipulate the heap of the worker pool.  The function `dispatch` selects the least loaded worker and schedules the request on it.

``` haskell
dispatch :: Pool a -> Request a -> IO (Pool a)
dispatch pool request = do
  let ((p, w), pool') = fromJust $ DH.view pool  -- ❶
  schedule w request                             -- ❷
  return $ DH.insert (p + 1, w) pool'            -- ❸
```

The interface of the heap module is unusual, but the code is only three lines:

1. The function [view](https://hackage.haskell.org/package/heap-1.0.4/docs/Data-Heap.html#v:view) extracts the worker with the minimum priority, that is with the lowest number of tasks.
2. The function `schedule :: Worker a -> Request a -> IO ()` is part of the Worker API and it sends the given request to the extracted worker.
3. The function [insert](https://hackage.haskell.org/package/heap-1.0.4/docs/Data-Heap.html#v:insert) puts back the worker into the pool with an increased priority.  The return value is the updated pool.

The `completed` function is very similar to `dispatch`:

``` haskell
completed :: Pool a -> Worker a -> Pool a
completed pool worker =
  let (p', pool') = DH.partition (\item -> snd item == worker) pool
      [(p, w)]    = toList p'
  in  DH.insert (p - 1, w) pool'
```

First, we look up the given worker using [partition](https://hackage.haskell.org/package/heap-1.0.4/docs/Data-Heap.html#v:partition).  Second, we put it back into the heap with a decreased priority value.

## Worker

The last component of the system is the worker itself.  The worker comprises an identifier, an integer in this case, and a channel from which it can receive requests:

``` haskell
data Worker a = Worker Int (TChan (Request a)) deriving Eq
```

This is the worker's main function:

``` haskell
work :: Worker a -> TChan (Worker a) -> IO ()
work (Worker workerId requestChan) doneChannel = forever $ do
  Request task resultChan <- atomically $ readTChan requestChan -- ❶
  result                  <- task                               -- ❷
  atomically $ do
    writeTChan resultChan  result                               -- ❸
    writeTChan doneChannel (Worker workerId requestChan)        -- ❹
```

It is an infinite loop which (1) reads from the request channel, (2) performs the task, (3) sends the result to the requester, and (4) reports the completion to the balancer.  We have already seen the implementations of other ends of these two channels.

For better encapsulation I provide a short helper function to send a request to the worker:
``` haskell
schedule :: Worker a -> Request a -> IO ()
schedule (Worker i c) request = atomically $ writeTChan c request
```

The function `schedule` deconstructs the `Worker` and sends the provided request to its internal channel.  This function allows `Worker` to remain opaque and the request channel is not exposed outside the worker's module.

## Putting it all together

In the previous sections we have seen all the components: the requester, the balancer, and the workers.  We only have to wire everything up:

``` haskell
start :: IO ()
start = do
  chan     <- newTChanIO          -- create a channel
  balancer <- newBalancer chan 3  -- create a `Balancer` with 3 workers

  -- run the balancer and the requester concurrently
  race_ (balance chan balancer) (requester chan)
```

If you run the [complete code][code-github] you will get an output like:
```
Balancer: fromList [(0,Worker 2),(1,Worker 3),(0,Worker 1)]
Balancer: fromList [(0,Worker 1),(1,Worker 2),(1,Worker 3)]
Balancer: fromList [(1,Worker 3),(1,Worker 1),(1,Worker 2)]
```

You can see that the first three requests were scheduled on different workers.  The program continues indefinitely and you should see roughly the same amount of task on each worker.

## Summary

I presented the Haskell implementation of an interesting load balancer design based on the [Go code by Rob Pike][Slide-Design].  The load balancer gives the incoming request to the least-loaded worker.  The components are loosely coupled and they communicate via channels.

Can we deploy this to production?  Certainly not.  The design _seems_ to scale up to multiple workers and high request rates, but how can we prove this?  What kinds of tests could we write for such a concurrent system?  Can we test that the balancing strategy is sound?  I will try to find answers to these questions in a future post.

The full code can be found [in this repository][code-github].

[Pike-Concurrency]: https://www.youtube.com/watch?v=cN_DpYBzKso
[Slide-Design]: https://talks.golang.org/2012/waza.slide#45
[code-github]: https://github.com/wagdav/load-balancer
[Wikipedia-Heap]: https://en.wikipedia.org/wiki/Heap_(data_structure)
