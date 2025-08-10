---
title: C++ Concepts
date: '2021-09-01T21:46:00.000-07:00'
tags:
- C++
modified_time: '2021-09-01T00:00:00.000-07:00'
excerpt: "C++ notes on concepts."
toc: true
---

https://www.youtube.com/watch?v=wkWtRDrjEH4&ab_channel=CopperSpice

Website:  http://www.copperspice.com
Downloads:  http://download.copperspice.com

* Data Type: Values and operations on those values.
* Expression
  * Sequence of operators and operands.
  * Involves same or different data types.
  * Semantics include value categories.

* Value Categories
  * It is either an lvalue or an rvalue
  * lvalue
    * Can be taken by address.
  * rvalue
    * Cannot be taken by address.
    * Usually temporary, lifetime in block scope, and/or a literal (12, nullptr, 'a')

    int x = 12    x is an lvalue and 12 is an rvalue
    12 = x        is illegal because rvalue cannot be used as an assignment

    caller see changes, callee can change data

    f(T&)     takes an lvalue reference
    f(t)      legal because t is an lvalue
    f(T())    illegal because T() is an rvalue and is temporary

    callee cannot change data

    f(const T&) takes an lvalue or rvalue reference
    f(t)        legal because t is an lvalue
    f(T())      legal because the param is immutable and guarantees that the arg won't change

    caller cannot see changes, callee can change data

    f(T&&)      takes an rvalue reference
    f(t)        illegal because t is an lvalue
    f(T())      legal because T() is an rvalue

## Traits

Whether in a template or elsewhere, ::* is a C++ token, only usable in a type expression, in the context class_name::*. It declares a pointer to member.
