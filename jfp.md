Introduction
============
A preliminary version of this paper was presented as an *Experience
Report* at ICFP 2012.  In this revised paper, we add to our original
work the results of two different attempts to improve and deepen the
application of functional programming to the detection of remote
homologies in proteins:

  - To detect the likelihood that a protein is drawn from a family
    represented by a given Hidden Markov Model, we implemented
    Viterbi's algorithm in Haskell.  The algorithm uses dynamic
    programming, which we implemented by memoizing a recursive
    function.

    Our original Haskell code ran 7 to 8 times slower than C++ code
    built in the same research group for the same purpose.  Because
    MRFy exploits parallelism well, we could afford to give up this
    factor of 7 or 8, but we felt this number was awfully high.  In
    Section XXXX we report our efforts to speed up a native Haskell
    implementation. 

  - Our code for Viterbi's algorithm is carefully crafted to reflect
    the equations usually used in textbooks to describe the
    algorithm.  But an experienced functional programmer might find
    our original code distasteful:

      - The central data structure is an array, and it is used in a
        way that is more typical of FORTRAN than of any functional
        language.  (Lots of index arithmetic, no wholemeal
        programming.)

      - There is a good deal of fiddling with indices at the
        boundaries.

      - The elegant structure of the Plan 7 Hidden Markov Model is
        *not* reflected in the static types used in the Haskell code.

      - There are an alarming number of cases.

    In Section YYYY, we report on our efforts to make the data
    structures and algorithms "more functional."  We refactor our
    original code and assess it on three dimensions:

      - How much is it still manifestly an implementation of Viterbi's
        equations? 

      - How well do the static types model the structure of the
        problem?

      - How do we feel about the code?

      - How does making the code "more functional" affect performance}





XXXX: Experience trying to make Haskell competitive with C++
============================================================

[to be continued]


YYYY: Experience making things "more functional"
================================================

[to be continued]


Andrew's Notes
==============


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

