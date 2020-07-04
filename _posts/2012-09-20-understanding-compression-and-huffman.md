---
layout: posts
title: Understanding compression and Huffman Coding.
date: '2012-09-20T00:29:00.000-07:00'
author: awalsh128
tags:
- algorithms
- entropy encoding
- C
- compression
modified_time: '2012-10-03T13:45:24.158-07:00'
thumbnail: http://1.bp.blogspot.com/-tNufJh6DCtU/UFpln-nBHlI/AAAAAAAAA-s/DvbFZSnJj8Q/s72-c/step1.png
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-6581860548501859795
blogger_orig_url: https://awalsh128.blogspot.com/2012/09/understanding-compression-and-huffman.html
---

### Definitions

In a lot of texts regarding compression you will run across various
conventions of syntax to describe the coding of data. Much of them are
used in fields like [automata
theory](http://en.wikipedia.org/wiki/Automata_theory), group theory and
statistics. Although, the field of [coding
theory](http://en.wikipedia.org/wiki/Coding_theory) itself has [a long
and rich
history](http://en.wikipedia.org/wiki/Timeline_of_information_theory) in
the 20st century; much of the terminology is borrowed from fields that
gave rise to it.

I find the best way to demonstrate the following definitions is by
example. Let us take the text \"abbcc\" as a sample.

-   **Alphabet**: The set of symbols that we will be encoding.
    -   Form:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20\sum%20=%20\%7B%20a_1,%20a_2,%20...,%20a_n\%7D "Sigma")
    -   Example:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20\sum%20=%20\%7Ba_1,%20a_2,%20a_3\%7D "Alphabet Example")
        where
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20a_1%20=%20\mathrm%7Ba%7D,%20a_2%20=%20\mathrm%7Bb%7D,%20a_3%20=%20\mathrm%7Bc%7D "Alphabet Example")
-   **String**: A permutation of symbols from our alphabet. From our
    example alphabet, strings like \"a\", \"aba\", \"abc\" or \"cccb\"
    could all be possible. Using regular expression syntax, we can
    describe this in our example.
    -   Form:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20w "String")
    -   Example:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20w%20=%20\%7Ba,%20b,%20c\%7D%5E* "String Example")
-   **Probabilities**: The set of probabilities for the alphabet. This
    is also known as their weights and can sometimes be denoted as w
    instead of p.
    -   Form:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20P%20=%20\%7B%20p_1,%20p_2,%20...,%20p_n\%7D "Probability")
    -   Example:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20P%20=%20\%7Bp_1,%20p_2,%20p_3\%7D "Weights Example")
        where
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20p_1%20=%20\frac%7B1%7D%7B5%7D,%20p_2%20=%20\frac%7B2%7D%7B5%7D,%20p_3%20=%20\frac%7B2%7D%7B5%7D "Probabilities Example")
        since \'a\' occurs once, \'b\' occurs twice and \'c\' occurs
        twice out of 5 symbols all together.
-   **Codewords**: The set of codewords that we will create for every
    symbol in our alphabet.\
    -   Form:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20C%20=%20\%7B%20c_1,%20c_2,%20...,%20c_n\%7D "Codeword")
    -   Example:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20C%20=%20\%7B%20c_1,%20c_2,%20c_3\%7D "Codeword Example")
        where
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20c_1%20=%2000,%20c_2%20=%2001,%20c_3%20=%201 "Codeword Example")
        for symbols
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20a_1,%20a_2%20a_3 "Codeword Example")
        respectively. Another way to look at it is that we are providing
        a [bijective](http://en.wikipedia.org/wiki/Bijection) function:
        ![](http://latex.codecogs.com/gif.latex?\small%20\inline%20f:%20\Sigma%20\rightarrow%20C "Symbol to Codeword Mapping").

### Code Width

Standard coding of information for most computers today is byte aligned.
For example, in character codes there is
[ASCII](http://en.wikipedia.org/wiki/ASCII), which codes the entire
English alpha-numeric system in a single byte. While UTF-8 has proven to
be a much better standard due to better localization support and
variable width codes, ASCII serves our purposes for this discussion.
ASCII is considered a fixed width coding scheme:

::: {align="center"}
![](http://latex.codecogs.com/gif.latex?\inline%20\large%20\Sigma%20=%20\%7Ba-z,A-Z,0-9,...\%7D,\;\;%20C%20=%200\%7B0,1\%7D%5E7,\;\;%7CC%7C%20=%202%5E7%20=%20128 "ASCII Codeword")
:::

When performance is at stake, it is best to code information atomically
aligned to the computer architecture that it is being used for. This
means allocating and defining information in terms of bytes (defined as
8-bits) for the majority of systems today. Although, if space is the
priority, performance can take a hit [to shift around
bits](http://awalsh128.blogspot.com/2012/09/implementing-bit-readerwriter-in-c.html)
along the byte boundaries and create variable width codes that do not
byte align.

::: {align="center"}
![](http://latex.codecogs.com/gif.latex?\inline%20\large%20\Sigma%20=%20\%7Ba-z,A-Z,0-9,...\%7D,\;\;%20C%20=%20\%7B0,1\%7D%5E+,\;\;%7CC%7C%20\leq%20n "Variable Width Codewords")
:::

*Note*: The ellipses in the alphabet denote the control characters (eg.
CR, LB) and grammatical structure symbols (eg. \#, \$, %) contained in
the ASCII code page. The alphabets will reflect this in the ellipses.

### Data Compression

Variable Width Savings
----------------------

Coming back to the example of ASCII, if we wish to encode a string, w,
like \"aaabb\", it will take up 5 bytes. Although we only really need
one bit to encode our information if we assign 0 to \'a\' and 1 to
\'b\'.

::: {align="center"}
![](http://latex.codecogs.com/gif.latex?\inline%20\large%20\Sigma%20=%20\%7Ba,b\%7D%20\rightarrow%20C%20=%20\%7B0,1\%7D,\;\;%20w%20=%20aaabb,\;\;%20f(C,w)%20=%2000011 "String Example 1")
:::

We just took a 5 byte ASCII encoded string and compressed it down to
under a byte. Now let us take another string, w, and give it
\"aaabbcc\". Three alphabet symbols need to be coded; it will take at
least 2 bits. At first glance, this assignment would make sense:

::: {align="center"}
![](http://latex.codecogs.com/gif.latex?\inline%20\large%20\Sigma%20=%20\%7Ba,b,c\%7D%20\rightarrow%20C%20=%20\%7B0,1,01\%7D,\;\;%20w%20=%20aaabbcc,\;\;%20w(C)%20=%20000110101 "String Example 2")
:::

Although this gives us an ambiguous string since it could either be
\"aaabbcc\", \"aaabbabab\", \"aacbcc\" or any other permutation of our
codeword set when we attempt to decompress it. The reason for this
ambiguity is due to the fact that the codeword for \'a\' (0), is used to
start the codeword for \'c\' (01).

Prefix Codes
------------

The way to get around this ambiguity is to ensure that all of your codes
are [prefix type](http://en.wikipedia.org/wiki/Prefix_code). Something
like this would work:

::: {align="center"}
![](http://latex.codecogs.com/gif.latex?\inline%20\large%20\Sigma%20=%20\%7Ba,b,c\%7D%20\rightarrow%20C%20=%20\%7B0,10,11\%7D,\;\;%20w%20=%20aaabbcc,\;\;%20w(C)%20=%2000010101111 "String Example 2")
:::

This ensures that we maintain the one-to-one mapping between our
alphabet and codewords; we can translate alphabet symbols to codewords
and codewords back to alphabet symbols without confusion.

### Codeword Assignment

So how do you decide which symbols, get which codewords? Also, since the
size of the codeword is critical to the compression ratio (average
codeword length to average symbol length), designing an algorithm to
weigh the more frequently used symbols is important. In our previous
example, it would be poor design to give \'a\' the longest codeword
because it is the most used symbol in the string. This is where the
Huffman Coding algorithm comes into play.

Huffman Coding Algorithm
------------------------

Count the number of times each symbol occurs in the data source.

Put \[symbol:count\] pairing as nodes in a minimum priority queue based
on the symbol\'s count.

Evaluate number of queue nodes.

-   If queue has at least two nodes:
    -   Dequeue the two nodes.
    -   Create a new node with a null symbol and set the count equal to
        the sum of the two dequeued node\'s counts.
    -   Attach the two nodes as children to the new node.
    -   Put the newly created node into the queue.
    -   Go to step 3.
-   If queue has only one node, dequeue and set as the root of the tree.

Assign each left branch a 0 and each right branch a 1, or vice versa if
you choose.

The symbol nodes will be the children of the tree and their codeword
will be the bits that are traversed to get there.

Algorithm Example
-----------------

Given our previous example string of \"aaaabbcc\", let us perform the
algorithm on it:

1.  Initial queue state with only symbol nodes in it.\
    \
    [![](http://1.bp.blogspot.com/-tNufJh6DCtU/UFpln-nBHlI/AAAAAAAAA-s/DvbFZSnJj8Q/s400/step1.png){width="267"
    height="53"}](http://1.bp.blogspot.com/-tNufJh6DCtU/UFpln-nBHlI/AAAAAAAAA-s/DvbFZSnJj8Q/s1600/step1.png)\
    \
2.  New node created from first two symbol nodes and requeued.\
    \
    [![](http://3.bp.blogspot.com/-LvjqXh94MWs/UFpl46DDISI/AAAAAAAAA-0/RClE4osgnT8/s400/step2.png){width="237"
    height="127"}](http://3.bp.blogspot.com/-LvjqXh94MWs/UFpl46DDISI/AAAAAAAAA-0/RClE4osgnT8/s1600/step2.png)\
    \
3.  New node created from non-symbol and symbol node, becoming the
    tree\'s root node.\
    \
    [![](http://3.bp.blogspot.com/-kEZIkB0I3j4/UFppgkVAZ5I/AAAAAAAAA_U/sUkTAoWd0gk/s400/step3.png){width="280"
    height="204"}](http://3.bp.blogspot.com/-kEZIkB0I3j4/UFppgkVAZ5I/AAAAAAAAA_U/sUkTAoWd0gk/s1600/step3.png)\
    \
4.  The final alphabet to codeword mapping is:\
    \
    ![](http://latex.codecogs.com/gif.latex?\inline%20\large%20\Sigma%20=%20\%7Ba,b,c\%7D%20\rightarrow%20C%20=%20\%7B1,00,01\%7D "Algorithm Results")

If you need further examples, you can look
[here](http://en.wikipedia.org/wiki/File:Huffman_huff_demo.gif),
[here](http://www.binaryessence.com/dct/en000080.htm) and
[here](http://en.nerdaholyc.com/huffman-coding-on-a-string/). Once the
you get a grasp of the algorithm, you will see the simplicity and beauty
of it.

### Working Code Example

If you want to see a naive implementation of the Huffman Coding
algorithm, I posted some source code on [my GitHub
account](https://github.com/awalsh128/huffmancoding). Below is the
central code to the algorithm execution.

### More Reading & Resources

If you are interested in coding algorithms, these links might be of
interest to you.

-   [Wikipedia: Arithmetic
    Coding](http://en.wikipedia.org/wiki/Arithmetic_coding)
-   [Code Project: Arithmetic Compression With
    C\#](http://www.codeproject.com/Articles/45320/Arithmetic-Compression-With-C)
-   [LZW
    Compression](http://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch)
-   [Mohamed F. Mansour: Efficient Huffman Decoding With Table
    Lookup](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.93.9447&rep=rep1&type=pdf)
-   [Wikipedia: Golomb-Rice
    Coding](http://en.wikipedia.org/wiki/Golomb_coding)
-   [Zlib Homepage](http://www.zlib.net)
