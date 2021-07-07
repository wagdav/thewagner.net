---
title: Concurrency in Go, Clojure, Haskell and Rust
---

In the past I wrote [two][HaskellVersion1] [articles][HaskellVersion2] where I
explored concurrency in Haskell using some examples from the talk [Go
Concurrency Patterns][GoVersion] by Rob Pike.

The examples are different implementations of a simulated search engine which
receives a search query and returns web, image and video results.  The first
version sends the search queries sequentially.  Then, the program is gradually
improved to become concurrent and better performing.

Earlier I presented [each step][HaskellVersion1] in detail.  Here I will only
show the final form of the fake search function in four different programming
languages: Go, Clojure, Haskell and Rust.

# Go

[Rob Pike's version][GoVersion] of the search function executes the three kinds
of search queries concurrently and sends the search requests to replicated
back-end servers to reduce tail latency.

``` go
// https://talks.golang.org/2012/concurrency.slide#50
func search(query string) (results []Result) {
    c := make(chan Result)
    go func() { c <- First(query, Web1, Web2) } ()
    go func() { c <- First(query, Image1, Image2) } ()
    go func() { c <- First(query, Video1, Video2) } ()
    timeout := time.After(80 * time.Millisecond)
    for i := 0; i < 3; i++ {
        select {
        case result := <-c:
            results = append(results, result)
        case <-timeout:
            fmt.Println("timed out")
            return
        }
    }
    return
}
```

The implementation shows Go's concurrency primitives: goroutines, channels, and
the select statement.  The Go runtime manages the goroutines which are
lightweight threads of execution.  Goroutines communicate via channels.  The
`switch` statement allows merging values originating from multiple channels.
These constructs are all built into the language, no external library is
required.

# Clojure

I was surprised when Rich Hickey mentioned the fake search example in his
presentation on [Clojure core async][ClojureVersion].  I copied here the code
from the slides for reference:

```clojure
;; https://www.youtube.com/watch?v=drmNlZVkUeE?t=2458
(defn search [query]
  (let [c (chan)
        t (timeout 80)]
    (go (>! c (<! (fastest query web1 web2))))
    (go (>! c (<! (fastest query image1 image2))))
    (go (>! c (<! (fastest query video1 video2))))
    (go (loop [i 0
               ret []]
          (if (= i 3)
            ret
            (recur (inc i)
                   (conj ret (alt, [c t] ([v] v)))))))))
```

Clojure's async library uses the same primitives as Go: the syntax is LISP, but
the structure of the program is identical to that of the Go version.  Watch
[Rich Hickey's presentation][ClojureVersion] if you're interested how this
works on the JVM and in a web browser using ClojureScript.

# Haskell

My first implementation of the simulated search engine was in
[Haskell][HaskellVersion1]:

```haskell
search30 :: SearchQuery -> IO ()
search30 query = do
    req <- timeout maxDelay $
        mapConcurrently (fastest query) [Web, Image, Video]
    printResults req
```

This is my favorite version of this exercise because it's succint and
expressive.  We don't see the primitives we saw in the Go and Clojure version,
but an expression stating that some operations are expected to run
concurrently.  Writing this high-level code is possible because the threads are
managed by the Haskell run-time system and I'm using the [async][HaskellAsync]
library which exposes a powerful, composable API.

# Rust

My latest addition to this collection is [written in Rust][RustVersion], a
language I've been learning for the last couple of weeks:

```rust
pub async fn search30(query: &SearchQuery) -> SearchResult {
    timeout(Duration::from_millis(80), async {
        tokio::join!(
            fastest(query, &SearchKind::Web),
            fastest(query, &SearchKind::Image),
            fastest(query, &SearchKind::Video),
        )
    })
    .await
    .map(|(web, image, video)| SearchResult::new(web, image, video))
    .unwrap_or_else(|_| SearchResult::timeout())
}
```

This code looks similar to the Haskell version because we don't see channels
and explicit thread management here either.  The Rust language defines the
`async/await` syntax and the related interfaces but it delegates the concrete
execution strategy to external libraries.  In this example I chose the
[Tokio][RustTokio] library which is a mature asynchronous run-time library, but
in the future I'd like to explore other libraries too and learn more about how
they work.

Asyncronous programming in Rust is a [recent addition][Rust1.39] to the
language.  If you're interested how this feature was designed I recommend
watching [Steve Klabnik's talk][RustAsyncAwait].

# Summary

Modern languages provide ways of expressing concurrent operations using
built-in language primitives or external libraries.  Writing a simulated search
engine is a great exercise to learn about concurrency because it requires to
think about thread creation, thread cancellation and merging results from
multiple threads.

[HaskellVersion1]: {filename}2018-02-26-Concurrency.markdown
[HaskellVersion2]: /blog/2019/07/15/concurrency-without-magic/
[GoVersion]: https://talks.golang.org/2012/concurrency.slide
[ClojureVersion]: https://www.youtube.com/watch?v=f6kdp27TYZs
[RustVersion]: https://github.com/wagdav/rust-concurrency-patterns
[HaskellAsync]: https://hackage.haskell.org/package/async-2.1.0/docs/Control-Concurrent-Async.html
[RustTokio]: https://tokio.rs/
[Rust1.39]: https://blog.rust-lang.org/2019/11/07/Async-await-stable.html
[RustAsyncAwait]: https://www.youtube.com/watch?v=lJ3NC-R3gSI
