---
title: Pseudo random proportional scheduling in games.
date: '2011-09-02T14:10:00.000-07:00'
author: awalsh128
tags:
- algorithms
modified_time: '2012-08-01T16:27:26.667-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-3561117436840978535
blogger_orig_url: https://awalsh128.blogspot.com/2011/09/pseudo-random-proportional-scheduling.html
---

I have been working on a game where enemy characters must select a
target seemingly at random but such that the distribution of selected
targets is balanced. Initially I had come up with a randomization
algorithm with weighted values for each target but this became
cumbersome and much too complex.\
\
Then I remembered the scheduling algorithms from my Operating Systems
class. In particular, the [lottery scheduling
algorithm](http://en.wikipedia.org/wiki/Lottery_scheduling).\
\

``` java
// assume a queue of targets
int total = 0;

for (Target t : targets) {
   t.tickets = 5;
   total += t.tickets;
}

// generate a random number from 0 to total
for (Target t : targets) {
   randNum -= t.tickets;
   if (randNum <= 0) {
      targets.reenqueue(t);
      return t;
   }
}
```

The queue structure is critical to ensuring proportionality in target
selection. Also, targets can be given a higher amount of tickets if bias
is needed.
