Performance of our implementation of the Viterbi algorithm
==========================================================

As new Haskell programmers, we tended write parts of MRFy as we would in a 
C program. For example, our representation of an `HMM` is an array of records 
where some fields are not always used. We therefore endeavored to rewrite some 
of our fundamental types to make better use of Haskell's type system while also 
benchmarking each change to see how it affects the performance of our 
implementation of Viterbi. {Perhaps this is a lie.}

We created several benchmarks without beta strands so that MRFy *only* executes 
a single pass of Viterbi without executing a stochastic search. For every 
benchmark, we tested a change in either the implementation of `viterbi` or a 
change in the representation. We report figures relative to a baseline, which 
was established to account for IO and parsing.

We now detail each of the changes.

{Since there are many changes, my idea here is to give names to each of the 
changes. Ideally, they'd correspond to a branch name. I have not thought this 
through.}

* `special-directives` - {I don't know what this is.
                          These were suggested by John Tibell and apparently
                          already added?}
* `indirection-removal` - {I don't know what this is. See #11.}
* `state-arrays` - In `viterbi`, instead of using case analysis on HMM 
  states, we use arrays indexed by HMM states.
* `unsafe-arrays` - Use unsafe array ranges for memoization.
* `separate-begin` - The "begin" HMM node requires special case analysis, so 
  we therefore explicitly separate it from all other HMM nodes.
* `static-trans` - Static encoding of HMM transition probabilities.
                   {??? See issue #2.}
* `HMM-list` - Represent an HMM as a *list* of nodes and memoize on
  its prefix.

The number of all possible tests given these changes is quite large, so we 
tested each change individually and tested some interesting combinations of 
changes: {I don't think we know yet.}

{We talked about a commutative diagram in issue #8. But it seems like we don't 
need that for all tests---maybe only the `static-trans` and `HMM-list` tests?
What about `separate-begin`? With `separate-begin`, what if we constructed the 
special node within `viterbi`?}

