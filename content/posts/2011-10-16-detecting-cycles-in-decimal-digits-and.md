---
title: Detecting cycles in decimal digits and lists.
date: '2011-10-16T02:25:00.000-07:00'
tags:
- Python
- Algorithms
---

I was recently working on solving [problem 64 for project
Euler](http://projecteuler.net/problem=64) and one of the needed
algorithms was a detection of cycles in a list. This routine works for
detecting cycles in lists of cardinality greater than 2.\
\

``` python
def get_cycle_len(N):
  i = k = 0
  for j in range(2, len(N)):
    if N[i] == N[j]:
      if k == 0:
        k = j
        i = 1
      else:
        if i == k:
          return k
        i += 1
    else:
      i = 0
      k = 0
  return -1
```
