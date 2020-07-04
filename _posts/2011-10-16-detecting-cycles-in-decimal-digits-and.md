---
layout: posts
title: Detecting cycles in decimal digits and lists.
date: '2011-10-16T02:25:00.000-07:00'
author: awalsh128
tags:
- algorithms
- Python
modified_time: '2012-08-01T16:22:25.939-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-3192609359815779517
blogger_orig_url: https://awalsh128.blogspot.com/2011/10/detecting-cycles-in-decimal-digits-and.html
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
