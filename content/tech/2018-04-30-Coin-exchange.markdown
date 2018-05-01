title: Minimum Coin Exchange

In this post I solve the Minimum Coin Exchange problem programmatically using
Haskell.  I will compare the performance of the naive implementation to that
using dynamic programming.

## The problem

The minimum coin exchange problem is [generally asked][1]: if we want to make
change for $N$ cents, and we have infinite supply of each of
$S=\{S_{0},S_{2},\ldots ,S_{m-1}\}$
valued coins, what is the least amount of coins we need to make the change?

The solution can be found in a recursive manner where at each step of the
recursion we have two options:

1. we use the $S_m$ valued coin in the change and we try to find the change
   for $N - S_m$ cents with the same set of coins.

2. we decide not to use the $S_m$ valued coin in the change: we keep on looking
   for a change of $N$ cents with $m-1$ coins

At each step we need to choose the option that uses less coins.  It is expected
that this process will end after finite number of steps because either the
number of coins or the money to change decreases at each step.

On the [algorithmist.com][1] we find a succinct recursive formula to describe
this process

$$
C(N,m)=\min {(C(N - S_{m}, m) + 1, C(N, m-1))}
$$

the arguments of the $\min$ function correspond to the two options described
above.  The $+1$ in the first argument shows that choosing that option will
increase the number of coins in the change.  The recursive formula is completed
with the base cases:

$$
\begin{align}
C(N,m) &= 0,      & N=0              \\
C(N,m) &= \infty, & N<0              \\
C(N,m) &= \infty, & N\geq 1, m\leq 0 \\
\end{align}
$$

If the result of $C(N,m)$ is either $0$ or $\infty$ then it is impossible make
change for $N$ with the given coins.  The case (1) applies when we successfully
changed $N$ with the given coins. Case (2) means that our smallest valued coin
is larger than the amount for which the change is requested.  Finally (3)
represents the situation where we cannot pick any more coin to complete the
change.

For simplicity, we will use a fixed set of coins: $[25, 20, 10, 5, 1]$.  For
example, the minimum number of coins needed for 40 cents using the formulation
above is given by $C(40, 4)$.  Also note that we only compute the number of
coins, we don't give the exact denominators to be used in the change.

## Foundations

As we use a fixed set of coins we hard-code the available coin denominators:
``` haskell
-- Available coin denominators.
coins :: [Int]
coins = [25, 20, 10, 5, 1]
```

We will write a function with the following signature:

``` haskell
change :: Int     -- amount
       -> Int     -- index of the last available coin
       -> Change  -- the number of coins
```

`change` takes to arguments: the amount to change, the index of the last
available coin and it returns the number of coins in the change.

Taking a list index as the second argument is, of course, very error prone: our
program will crash if we try to address an element that is not present in the
`coins` list.  We ignore this deficency in order to stay as close as possible
to the theoretical formulation of the problem.

Since there are cases where the change is impossible, we choose the result type
`Change` as

``` haskell
type Change = Maybe Int
```

This is more expressive than using infinity as a sentinel value when the change
is not possible.

With this preparation we are ready to implement the first version of `change`.

## Naive implementation

``` haskell
-- Naive implementation using the recursive formula from:
-- http://www.algorithmist.com/index.php/Min-Coin_Change
change :: Int -> Int -> Change
change n m
  | n == 0            = Just 0
  | n < 0             = Nothing
  | n >= 1 && m <= 0  = Nothing
  | otherwise         = minOf left right

  where
    left = (+1) `fmap` change (n - sm) m
    right = change n (m - 1)
    sm = coins !! m
```

This implementation is _almost_ maps one-to-one to the recursive formula above.
The first three guard expression handle the three base cases.  In the last
clause the function calls itself to solve the two sub-problems which I
called `left` and `right`.

Choosing `Maybe` to represent the result `Change` forces us to deviate from the
clean mathematical formulation at two places:

1. we use `fmap` to add `1` to the result of the `left` subproblem

2. we use our own `minOf` function instead of the built-in `min` function

The first point is easy: we cannot add an `Int` to a `Maybe Int` because their
types don't match.  Since `Maybe Int` is a functor so we can use `fmap` to lift
the addition into the context of `Maybe`.

As for the second point, let's see the implementation of `minOf`:

``` haskell
import Control.Applicative ((<|>))

minOf :: Change -> Change -> Change
minOf (Just i) (Just j) = Just (min i j)
minOf c1 c2             = c1 <|> c2
```

The function takes two `Change` values:  if both `Maybe` contain `Int` values
we choose the smaller one.  Otherwise we try to keep the one that has a value
in it using `<|>`.  This behaves similarly to logical OR.  We can easily test
this in `ghci`:

``` bash
Prelude> import Control.Applicative
Prelude Control.Applicative> Just 1 <|> Nothing  -- keeps the first
Just 1
Prelude Control.Applicative> Nothing <|> Just 2  -- keeps the second
Just 2
Prelude Control.Applicative> Nothing <|> Nothing -- returns Nothing
Nothing
Prelude Control.Applicative> Just 1 <|> Just 2   -- prefers the first
Just 1
```

This implementation of `minOf` gives us the right behavior when we select the
smaller between the results of the `left` and `right` subproblems.

The built-in `min` can actually operate on `Maybe Int` values.  We just cannot
use it here because it returns `Nothing` if _any_ of its argument is `Nothing`.
This would terminate our recursive function without exploring the whole
solution space.

We could almost directly implement the terse mathematical solution as a
recursive function.  Overall our function is short and readable, but before we
open the champagne and celebrate let's see how our solution performs.

## Performance of the naive solution

We can use the microbenchmarking library [criterion][2] to measure the running
time of the naive `change` implementation.  Let's see how the running time
depends on the amount to change.  The following graph shows the approximate
time of computing the change for 40, 100, 150 and 200 cents.

{%
    pygal {
        "type": "bar",
        "config": {
            "x_title": "amount [cents]",
            "y_title": "approximate running time [ms]"
        },
        "x-labels" : [40, 100, 150, 200],
        "title": "Performance of the 'change' function",
        "data" : [
         {"title": "naive",
          "values": [0.026, 0.344, 1.420, 4.025]}
        ]
    }
%}

The running time of the naive solution scales polynomially with the number of
cents.  Let's try to improve this!

## Implementation using dynamic programming

The recursive method of the minimum coin exchange problem combines the
solutions of subproblems with smaller amounts to change.  We could optimize our
naive solution using [dynamic programming][3].  The idea is that every time we
solve a subproblem we memorize its solution.  The next time the same subproblem
occurs, instead of recomputing its solution we look up the previously solved
solution.

We write a new function `changeD` which represents a stateful computation.  The
state is a map from problem parameters to its solution.  In our case, a map
from pair of integers (the denominator index and the amount) to a `Change`
value.  We call this computation `Dyn`:

``` haskell
import qualified Data.Map.Strict as M
import Control.Monad.Trans.State

type Dyn = State (M.Map (Int, Int) Change)
```

Using this, we can write `changeD` which, returns a `Dyn` computation resulting
in a `Change`:
``` haskell
changeD :: Int -> Int -> Dyn Change
changeD n m
  | n == 0            = return $ Just 0
  | n < 0             = return Nothing
  | n >= 1 && m <= 0  = return Nothing
  | otherwise         = do

    left  <- memorize n (m - 1)
    right <- memorize (n - sm) m
    return $ minOf left (fmap (+1) right)

    where
      sm = coins !! m
```

The code looks very much like the naive solution but, since we're operating in
the `Dyn` context, we are using the `do` notation.  The `memorize` computation
implements the storing and recalling the subproblems' solution:


``` haskell
memorize :: Int -> Int -> Dyn Change
memorize n m = do
    val <- do
        elem <- gets $ M.lookup (n, m)  -- try to recall the solution
        case elem of
            Just x  -> return x         -- return previously stored solution
            Nothing -> changeD n m      -- compute the solution

    modify $ M.insert (n, m) val        -- store the solution
    return val
```

This function is a literal implementation of the dynamic programming method.
We try to look up the solution in the state: if the subproblem has already been
solved we return the solution, otherwise we solve the subproblem and store its
solution in the state.

The final step is to provide `change` in a form identical to the naive
solution:

``` haskell
change :: Int -> Int -> Change
change m n = evalState (changeD m n) M.empty
```

We execute the `Dyn` computation using `evalState` by providing an initial
empty state.  This function provides exactly the same interface as the naive
version above.  The two implementations can be used interchangeably.  Let's
which of the two implementations is worth using.


## Naive vs dynamic

The graph below compares the running times of the two implementations as a
function of the amount to change.

{%
    pygal {
        "type": "bar",
        "config": {
            "show_y_labels": true,
            "x_title": "amount [cents]",
            "y_title": "approximate running time [ms]"
        },
        "x-labels" : [40, 100, 150, 200],
        "title": "Performance of the 'change' function",
        "data" : [
         {"title": "naive",
          "values": [0.026, 0.344, 1.420, 4.025]},
         {"title": "dynamic",
          "values": [0.117, 0.354, 0.556, 0.814]}
        ]
    }
%}

The dynamic programming version scales linearly with the amount to change.  The
difference in running time becomes significant for amounts larger than 100
cents.  As always, this speedup didn't come for free: we traded running speed
for storage space.


## Summary

The minimum coin exchange problem is a classic example demonstrating dynamic
programming.  We implemented a solution by naively transcribing the proposed
recursive formula almost literally to Haskell.  We then used dynamic
programming to improve time complexity of the naive solution.  The dynamic
programming method was encapsulated in a `Dyn` computation where the solutions
to already solved subproblems are stored in a map.

The code for both implementations can be found [here][4].


[1]: http://www.algorithmist.com/index.php/Min-Coin_Change
[2]: http://www.serpentine.com/criterion/
[3]: https://en.wikipedia.org/wiki/Dynamic_programming
[4]: https://github.com/wagdav/dynamic-programming/tree/master/src/Coin
