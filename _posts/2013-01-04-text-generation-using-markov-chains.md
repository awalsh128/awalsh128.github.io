---
layout: posts
title: Text generation using Markov chains.
date: '2013-01-04T19:11:00.002-08:00'
author: awalsh128
tags:
- Markov chains
- Python
- natural language processing
modified_time: '2013-01-04T19:11:30.599-08:00'
thumbnail: http://2.bp.blogspot.com/-_8ivI0g-2pY/UJsLfG04cRI/AAAAAAAADRU/HOFVAJKwYqc/s72-c/simple-automata.png
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-4038923617750448040
blogger_orig_url: https://awalsh128.blogspot.com/2013/01/text-generation-using-markov-chains.html
---

### Introduction

If you are already familiar with [finite
automata](http://en.wikipedia.org/wiki/Finite-state_machine), then
understanding a [Markov
chain](http://en.wikipedia.org/wiki/Markov_chain) will not be as hard.
If you are not familiar with one, you can think of finite automata as a
[flowchart](http://en.wikipedia.org/wiki/Flowchart), with states and
paths leading from one state to another [based on some decision being
made](http://xkcd.com/627/). An example could be a room with a light
switch; there are the two states of having the light on or off. Using
the light switch will transition you between the two states.

::: {.separator style="clear: both; text-align: center;"}
[![](http://2.bp.blogspot.com/-_8ivI0g-2pY/UJsLfG04cRI/AAAAAAAADRU/HOFVAJKwYqc/s400/simple-automata.png){width="400"
height="183"}](http://2.bp.blogspot.com/-_8ivI0g-2pY/UJsLfG04cRI/AAAAAAAADRU/HOFVAJKwYqc/s1600/simple-automata.png)
:::

The difference between standard finite automata and Markov chains is
that instead of having some definite outcome determining each path (eg.
yes or no), they are probabilities. Take for example a coin flip, there
is a 50% (0.5) chance that it could either be heads or tails.

::: {.separator style="clear: both; text-align: center;"}
[![](http://4.bp.blogspot.com/-At-x9TP5t44/UJsLwCzq81I/AAAAAAAADRg/IFNPH1QKU8U/s400/simple-markov.png){width="400"
height="259"}](http://4.bp.blogspot.com/-At-x9TP5t44/UJsLwCzq81I/AAAAAAAADRg/IFNPH1QKU8U/s1600/simple-markov.png)
:::

### An Example

Let\'s explore Markov chains a little deeper with respect to natural
languages and take a look at some sample text that will form the
[corpus](http://en.wikipedia.org/wiki/Text_corpus) of our analysis.

"I like turtles. I like rabbits. I don\'t like snails."

This would render a Markov chain as follows:

::: {.separator style="clear: both; text-align: center;"}
[![](http://2.bp.blogspot.com/-U2fyhOJ7bN8/UJsL23oh3zI/AAAAAAAADRs/wZNWvVR-Jco/s400/text-markov.png){width="400"
height="345"}](http://2.bp.blogspot.com/-U2fyhOJ7bN8/UJsL23oh3zI/AAAAAAAADRs/wZNWvVR-Jco/s1600/text-markov.png)
:::

The above chain means that, among the sentences:

-   100% (1.0) will start with *I*.
-   This will be followed by *like* for 66% (0.66) of the time and
    *don\'t* for 33% (0.33) of the time.
-   The word *don\'t* will always (100% / 1.0) be followed by *like*.
-   Then lastly, *turtles*, *rabbits* and *snails* will all follow
    *like* 33% (0.33) of the time.

The nice thing about Markov chains, with respect to natural language
modelling, is that they form [word
dependencies](http://en.wikipedia.org/wiki/Dependency_grammar) without
any knowledge of the language\'s syntax or semantics. The chain gets
created purely based on statistical knowledge extracted from the corpus.

### Text Generation

Random Selection
----------------

Using the Markov chain example from before and taking the weight of
probabilities into account, we can randomly traverse the chain to
generate new sentences like:

"I don\'t like turtles. I like snails."

Although, our small corpus does not make for very interesting or new
text. We could make it more interesting by adding to it or switching to
a much larger corpus altogether. In my case, I decided to take all of
[Shakespear\'s
sonnets](https://raw.github.com/awalsh128/nlp/master/sonnets.txt) and
generate the text from that. You can see some example code that uses it
as the corpus below.

The Code
--------

The Markov chains will be built up for each new sentence it comes
across. The critical parts to the `MarkovChain` object are its:

-   **Cardinalities**: The cardinality of the sample space for a given
    state. In our original example, the cardinality of *like* is 3 since
    snails, rabbits and turtles follow out of the *like* state. The
    cardinality of *I* would be 2 since *don\'t* and *like* follow.
-   **Occurrences**: The edge valued occurrences between the different
    states. For example, a transition from the *I* to *like* state
    occurred twice. The probability can then be easily calculated by
    taking the number of occurrences on a transition and divide it by
    the cardinality of the state\'s sample space. Note, there is also a
    special start state transition that can be used at the beginning of
    each new sentence generation.

Using these two parts, a random walk can be made across a chain path,
starting from the special start state. Each walk will generate a new
sentence based on probabilities of the transitions along the path.

\

\

### Additional Resources

-   [Wikipedia: Stochastic
    Grammar](https://en.wikipedia.org/wiki/Stochastic_grammar)
-   [Wikipedia: Natural language
    generation](http://en.wikipedia.org/wiki/Natural_language_generation)
-   [Princeton CS206: Markov Model of Natural
    Language](http://www.cs.princeton.edu/courses/archive/spr05/cos126/assignments/markov.html)
-   [Markov-chain Text
    Generator](http://www.owlnet.rice.edu/~cz1/prog/markov/markov.html)
-   [ACL Special Interest Group on Natural Language Generation
    (SIGGEN)](http://www.siggen.org/)
