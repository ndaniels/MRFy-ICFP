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

      - How does making the code "more functional" affect performance?





XXXX: Experience trying to make Haskell competitive with C++
============================================================
We asked, according to our relatively naive understanding of what
factors affect performance, how Haskell code might differ from C++
code.  We came up with these ideas:

 1. In C and C++, record structures compose with no additional cost in
    allocations or indirections.  That is, a record of records is
    allocated in a single block of memory, and a member of a member
    can be addressed with only one address-arithmetic
    operation---there is no "pointer-chasing".

    In Haskell, because the language is polymorphic, we believe that a
    typical value must be represented in a single machine word.  If
    the value is too big to fit in a machine word, it must be
    allocated on the heap and represented by a pointer.  Such a
    representation is called "boxed".

    Because Haskell is lazy, even individual members of a record may
    be either evaluated or unevaluated, and may therefore be boxed.

    We set out to make the *machine-level* representation of our
    Haskell data structures more like the machine-level representation
    that a C programmer would use.  We were able to discover two
    mechanism:

      - A *strictness annotation* can force the evaluation of a part
        of a record and therefore prevent it from being boxed in a
        thunk.

      - The `UNPACK` pragma: where do we learn about it (aside from
        Johan Tibell), what do we cite, how is it known how to use it?

      - Does GHC provide an option that enables us to look at some
        kind of GHC IR and know if we have succeeded?

 2. C and C++ use pointer arithmetic and unsafe array access.

      - What happens if we change the record of transition
        probabilities to an array indexed by pair of states?

        What should the index type be?

        Can we look at GHC output (maybe `-ddump-simpl`) and figure
        out whether we are getting a flat two-dimensional array vs an
        array of arrays?

        Is there a one-dimensional array that works?

        Since we are indexing using every element of an enumeration
        type, what is a way we can introduce unsafe indexing that we
        believe is safe according to the type system?  Can we convince
        the compiler?

YYYY: Experience making things "more functional"
================================================
After the experience of presenting our work at ICFP and meeting other
functional programmers there, we became aware that our central data
structure is not what a functional programmer might expect to see.
We were curious to see what effect it might have to change this data
structure.  [questions from above]?

Diagramatically, a Hidden Markov Model looks like a Begin node
followed by zero (one?) or more ordinary nodes followed by an End
node.  But in our original code, all nodes are represented in the same
way, and the distinct properties of Begin and End nodes are present
only in the code, not in the types.  (As new Haskell programmers, we
tended to choose representations similar to the C representations we
had used before, and because C does not provide discriminated-union
type, the responsibility for knowing which node we're looking at
*always* resides in the code.  Our groups C code does not even use C
unions (**check this**); there would be little benefit.)

  - Because every node has to be capable of representing a Begin node,
    every node stores two probabilities used only for transitions out
    of Begin nodes, even though in all but one of the nodes, these
    probabilities go unused.

  - (Mumbo jumbo about chopping the node sequence into pieces, so that
    any node might become a Begin node after beta strands are placed.
    Again, the different interpretations of the "same" node are not
    explicit in the type system.)

Experiments to be carried out:

 1. Refactor the basic representation to eliminate the unused
    transition probabilities.

 2. Introduce an explicit Begin node with its own custom
    representation.

 3. Create a `Model` type with the form `Begin {Middle} End`.
    Inspired by REPA-style indexing tricks (also seen elsewhere),
    represent the middle sequence as a function of type `Int ->
    Middle`.  Implement a slicing function `Array Node -> Interval ->
    Model`.

 4. Rewrite Viterbi with the new representation.    

N.B. The elimination of unused transition probabilities is
*incompatible* with the change in representation to use a
two-dimensional array.  These experiments will have to be handled
carefully; we may need to build all four variants from

    { one node type, three node types } * { probability record, probability array }


A more radical change in the representation is to use the functional
programmer's mainstay: a list instead of an array.  This means lists
of nodes as well as lists of residues.  This change was motivated by
two observations:

  - Our Viterbi code was doing an awful lot of array indexing and
    index arithmetic.  This felt more like FORTRAN than like Haskell.

  - There were a *lot* of special cases around indices like 0 and -1.
    [Some of these cases arose because we didn't have a distinct Begin
    node, so we'll have to see what the code looks like when a Begin
    node is introduced.]

Changing to lists had several effects:

  - The algorithm suddenly came into focus as something familiar to
    functional programmers.  Instead of being something blindly
    translated from equations in a textbook, it became (probabilistic)
    minimum edit distance.  We thought this was pretty cool.

  - It's no longer so obvious how our code relates to Viterbi's
    algorithm as explained in textbooks.  Instead, we are relying on a
    deeper understanding of the underlying problem.  Perhaps good for
    us, but maybe not so good for communicating with, e.g., new
    graduate students in the group.  The jury is still out here.

  - Memoization is *much* hairier.  The junior members of the team
    might not have been able to pull this off on their own.  Lots of
    QuickCheck action, and significant uncertainty.

  - We've knowingly introduced new pointer indirections, with who
    knows what effect on locality or on memory traffic.  How did this
    affect performance?  [This problem militates toward testing on
    multiple hardware platforms, including NR's ancient AMD chip
    before it goes away.]



Benchmarking
============
We created several benchmarks without beta strands so that MRFy *only* executes 
a single pass of Viterbi without executing a stochastic search. For every 
benchmark, we tested a change in either the implementation of `viterbi` or a 
change in the representation. We report figures relative to a baseline, which 
was established to account for IO and parsing.


Naming the parts of the design space, Take One
==============================================
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



Naming the parts of the design space, Take Two
==============================================
The design space is combinatorial.  I suggest we name the individual
elements: 

  - Records of records: nested, flat

      - relates to special directives and indirection removal?

  - Transition tables: named fields, single array, array of arrays

  - Transition array indexing: safe, unsafe

  - Viterbi decreases: lists, array indices

  - Node array indexing: safe, unsafe, not used in inner loop

  - Residue array indexing: safe, unsafe, not used in inner loop

Some of these are independent and some are connected.   For example,
if Viterbi decreases array indices, then that indexing must be safe or
unsafe.  If Viterbi decreases lists, then array indexing is not used
in the inner loop.




