---
title: Representing scientific units in code.
date: '2011-07-13T15:44:00.000-07:00'
tags:
- Data Acquisition
lastmod: '2011-09-05T19:15:26.934-07:00'
---

I have been working on implementing a stream reader for [IEEE 1451.4
TEDS](http://standards.ieee.org/develop/regauth/tut/teds.pdf) and came
across this interesting
[paper](http://www.hpl.hp.com/techreports/96/HPL-96-61.pdf) regarding
representation of scientific units in code. It provides solutions to
determining unit equivalency (eg. V/(m•kg/s²) = m/(s•A)). Also
discovered some indivisible base units that can represent any unit (amp,
candela, kelvin, gram, meter, mole, radian, second). With a bit to
represent the placement (high for numerator, low for denominator) and a
bit for presence, a unit storage type can be derived that only occupies
2 bytes.
