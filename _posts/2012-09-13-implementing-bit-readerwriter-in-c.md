---
title: Implementing a bit reader/writer in C.
date: '2012-09-13T16:30:00.000-07:00'
author: awalsh128
tags:
- entropy encoding
- C
- compression
- raw text
- bit twiddling
modified_time: '2012-10-03T13:42:52.301-07:00'
thumbnail: http://4.bp.blogspot.com/--oQWBFnoeZs/UFIbvaS6dvI/AAAAAAAAA94/0sDK-D0rhWw/s72-c/bits1.png
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-5900668252323938038
blogger_orig_url: https://awalsh128.blogspot.com/2012/09/implementing-bit-readerwriter-in-c.html
---

### Introduction

I was working on implementing a simple compression tool based on naive
[Huffman coding](http://en.wikipedia.org/wiki/Huffman_coding) and
initially assumed all of my [prefix
codes](http://en.wikipedia.org/wiki/Prefix_code) would be at or under a
byte long. Although I failed to account for the [worst case of Huffman
coding](http://www.arturocampos.com/ac_fib_huffman.html#Fibbonaci%20and%20Huffman),
which can yield codes up to 255 bits in length.

This required a bit reading and writing function that would allow for
variable length codes. I could have used other methods to balance worst
case Huffman trees, but this issue presented a unique challenge. How to
write a bit reader/writer in C.

### Bit Reader/Writer Specifications

-   Read and write using reader and writer
    [ADT\'s](http://en.wikipedia.org/wiki/Abstract_data_type).
-   Handle any possible bit length given.
-   Remember bits read from file but are outside the requested bit
    length (eg. 2 bytes read in but only 12 bits requested, leaving 4
    bits in the buffer).
-   Flush a partially written block to disk on a free of the bit writer
    ADT.
-   Return number of bits read and written on the read and write
    functions.

### Design

The underlying structure to the ADT will contain fields for the: file
pointer, the byte long buffer and the buffer bit length. The examples
given for every case are in steps; what is originally in the buffer,
what bits are requested, what bits are read from or written to the file,
and finally what bits are left over and buffered.

Reader
------

There are two main cases to consider when designing the read function.

**Empty Buffer**: The is simple since the file read bits will already be
byte aligned to your output bits. You just need to simply mask out the
unneeded bits and buffer them for the next read (eg. no bits buffered,
12 bits requested, 16 bits read in, 4 bits buffered).

::: {.separator style="clear: both; text-align: center;"}
[![](http://4.bp.blogspot.com/--oQWBFnoeZs/UFIbvaS6dvI/AAAAAAAAA94/0sDK-D0rhWw/s400/bits1.png){width="400"
height="42"}](http://4.bp.blogspot.com/--oQWBFnoeZs/UFIbvaS6dvI/AAAAAAAAA94/0sDK-D0rhWw/s1600/bits1.png)
:::

**Populated Buffer**: The can get a little trickier, especially in the
last two cases of this.

1.  **Requested bits already buffered.** This is very easy since it
    doesn\'t require any file read and the buffer just needs to shift
    out the read bits (eg. 7 bits in the buffer and 3 are requested;
    buffer serves out 3 and truncates to 4).
2.  **Not all requested bits buffered; end of read bits not in same byte
    block as end of output bits.** The last output byte block must mask
    out the unneeded bits, put them in the buffer and then append the
    additional unneeded read bits from the next byte block (eg. 4 bits
    buffered, 13 bits requested, 16 bits read in, 8 bits buffered).
    ::: {.separator style="clear: both; text-align: center;"}
    [![](http://2.bp.blogspot.com/-wCITShIYyBg/UFIcK77GIzI/AAAAAAAAA-E/IbYkzeHHiQw/s400/bits2-2.png)](http://2.bp.blogspot.com/-wCITShIYyBg/UFIcK77GIzI/AAAAAAAAA-E/IbYkzeHHiQw/s400/bits2-2.png)
    :::

3.  **Not all requested bits buffered; end of read bits in same byte
    block as end of output bits.** The last output byte block must mask
    out the unneeded bits and put them in the buffer (eg. 4 bits
    buffered, 10 bits requested, 8 bits read in, 2 bits buffered).
    ::: {.separator style="clear: both; text-align: center;"}
    [![](http://1.bp.blogspot.com/-yZcVwLBuEts/UFIcRFPoL3I/AAAAAAAAA-Q/xJAcG1Zv73M/s400/bits2-3.png){width="400"
    height="42"}](http://1.bp.blogspot.com/-yZcVwLBuEts/UFIcRFPoL3I/AAAAAAAAA-Q/xJAcG1Zv73M/s1600/bits2-3.png)
    :::

Writer
------

There are only two cases to consider when designing the write function.

1.  **Full Buffer**: Shift in write bits, commit to disk and repeat
    until all bits are processed. If the last bit to write is not on the
    buffer byte boundary, it will wait until the next write (eg. 6 bits
    buffered, 12 bits to write, 16 bits written out, 2 bits buffered).
2.  **Partial Buffer**: Shift in write bits (eg. 2 bits buffered, 4 bits
    to write, no bits written out, 6 bits buffered).

### Caveats

The code below is purely a demonstration of how a bit reader/writer
works in a generic sense. There is room for plenty of optimization if
you know what type of architecture your targeting and the domain of your
reader/write arguments.

### The Code

Header File
-----------

Source File
-----------
