---
title: 'Understanding type theory (Part one: Lambda Calculus).'
date: '2013-04-14T20:57:00.002-07:00'
author: awalsh128
tags:
- lambda notation
- lambda calculus
- type theory
modified_time: '2013-04-14T20:57:11.382-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-3949893894537893082
blogger_orig_url: https://awalsh128.blogspot.com/2013/04/understanding-type-theory-part-one.html
---

### Series Introduction

I initially was going to put this together as a single post but quickly
realized that it would be a bit much to try and put all of the
information into one post. To make it more digestable, I decided to
break it up into separate parts. This is by no means a comprehensive
study of lambda calculus or type theory, but rather a quick introductory
series so you can can get started. My goal is that, by the end, you will
be able to understand enough to start reading papers on your own and
have some cursory knowledge of type systems. Also, I am targeting
programmers that want to get a better understanding of the theory behind
type systems in compiler design. If you are comfortable programming in
functional languages, then you will start to see many parallels quickly.
Although, I will give examples using an imperative approach to cover
programmers who may not immediately appreciate these parallels.

### Mathematical Formalisms

The mathematical underpinnings for describing computability is mostly
famously attributed to [Kurt
Gödel](http://en.wikipedia.org/wiki/Kurt_G%C3%B6del), [Alan
Turing](http://en.wikipedia.org/wiki/Alan_Turing) and [Alonzo
Church](http://en.wikipedia.org/wiki/Alonzo_Church). Church and Turing
took different routes to [the same ending
conclusion](http://en.wikipedia.org/wiki/Church%E2%80%93Turing_thesis)
(ie. [universal Turing
machine](http://plato.stanford.edu/entries/turing-machine/),
[$\lambda$-calculus](http://plato.stanford.edu/entries/lambda-calculus/)).
What is now known as the [Church-Turing
thesis](http://plato.stanford.edu/entries/church-turing/). In this post
we will focus strictly on Church\'s work, more specifically his
notation. By understanding the lambda calculus syntax, we will start to
grasp an idealized model of a programming language and what it means
later for learning type systems.

### Notation & Basic Structure

Let\'s look at a function that returns the square of its input:

::: {align="center"}
$$ f(x) = x^2 $$
:::

::: {align="center"}
`int f(int x) { return x * x; }`
:::

In lambda calculus, we can represent it as:

::: {align="center"}
$$ \lambda x.*x\;x $$
:::

Let\'s break this down into its parts and start defining those pieces.

-   **Term**: Since x is a variable, it can be considered a term and the
    whole expression itself is also a term (specifically a lambda
    abstraction).
-   **Bound Variable**: Any variable in the term that is a parameter of
    the function. In this case it is x.
-   **Free Variable**: The term above has none since any argument to the
    term would be applied to all variables in it. If the term were to be
    $\lambda x.*x\;y$
    instead, then y would be our free variable. We will give another
    example that demonstrates free variables later.
-   **Abstraction Symbol**: The
    $\lambda$ symbol
    indicates the beginning of the function, followed by the parameter.
-   **Function Body**: Everything following the dot is part of the
    function body (ie.
    $*\;x\;x$).

\

### Binding & Applying Terms

Now the switch from our named function (f) to the lambda term was not
entirely without loss. The
$\lambda$ symbol is not
the function name but rather indicates that the following symbol (x) is
a function parameter, just like the period represents the beginning of
the function body. This is where the term [anonymous
function](http://en.wikipedia.org/wiki/Anonymous_function) comes from.
We took a named function (f) and anonymized it. Now let\'s try defining
the function without loss of information.

::: {align="center"}
$$ f \equiv \lambda x.*x\;x $$
:::

It can sometimes be taken for granted in programming that a function
name is just another type of variable. The above example makes that
pretty clear. Much like a program function name directly references the
code it needs to execute, we bound the function to a variable (f) that
directly references the term. Although the lowercase letter name isn\'t
considered good convention in lambda calculus. Terms are normally bound
to a capitalized letter in these situations; it would be better form to
call it F instead.

::: {align="center"}
$$ F \equiv \lambda x.*x\;x $$
:::

That\'s better. What about function pointers? How would they be
expressed in the lambda calculus? Let\'s define some function pointer
(G), our previous function (F) and bind them in the C language:

``` c
int (*G)(int);
int F(int x) { return x * x; }

int main(void)
{
   G = &F;
   (*G)(2);
}
```

This is generally equivalent to:

::: {align="center"}
$$ G \equiv \lambda g.g\;\land\;F \equiv \lambda x.*x\;x\;:\;GF2 = 4 $$
:::

I could have written our $GF2$
term as $G(F(2))$ but
this is implicit in the lambda calculus. Terms are always [applied from
left to right](http://en.wikipedia.org/wiki/Associativity); first F is
applied to G and then 2 is applied to that. Having these semantics
eliminates the need for excessive parentheses. Now let\'s break down the
application of the terms in steps.

::: {align="center"}
$$ \begin{align*} GF2&\;\;\;\text{Given}\\ \lambda g.g(\lambda x.*x\;x)2&\;\;\;\text{Resolve F and G}\\ (\lambda x.*x\;x)2&\;\;\;\text{Apply F to G}\\ 4&\;\;\;\text{Apply 2 to GF} \end{align*} $$
:::

The first line is like the declares in our C program (line 1 and 2). The
second line is akin to when we assign the address of the function F to G
(line 6) and dereference G below it (line 7). The third line is when we
apply the value 2 to the function (line 7).

### Multiple Parameters

You may have noticed that all of our terms only accept a single
parameter. This is called the [curried
form](http://en.wikipedia.org/wiki/Currying) or
[Schönfinkeled](http://en.wikipedia.org/wiki/Moses_Sch%C3%B6nfinkel)
form if you want to get all crazy about it. You may have heard this
mentioned before when people talk about
[closures](http://en.wikipedia.org/wiki/Closure_(computer_science)).
Since we can\'t demonstrate currying in C (nested functions aren\'t
supported), let\'s do it in Python:

``` python
# uncurried form
def f(x, y):
    return x

# curried form using named functions
def g(x):
    def h(y):
        return x
    return h

# curried form using lambda functions
h = lambda x: lambda y: x

f(2,1)
g(2)(1)
h(2)(1)
```

I took a lot of liberties comparing the lambda terms earlier against the
C program and is why I wrote that they were generally equivalent. You
may have noticed how line 12 looks almost exactly like the actual lambda
calculus notation form of
$\lambda x.\lambda y.x$.
This is why programmers who know functional programming have a much
easier time learning lambda calculus and type systems. In Python, the
[type system is
dynamic](http://pythonconquerstheuniverse.wordpress.com/2009/10/03/static-vs-dynamic-typing-of-programming-languages/)
in the sense that a single variable can be rebound to a different type
during its lifetime. Also, lambda functions are explicitly available,
where they were not in C. These kind of features are what differentiates
different languages in terms of expressibility with respect to the
lambda calculus.

### Beta Reductions

You might not have known it, but by applying different terms, you were
performing what is called a beta-reduction. This is the process of
normalizing to its beta-redex term form. So in the case of FG, the
beta-redex term is
$\lambda x.*x\;x$.
Let\'s try something with more terms and reduce it.

::: {align="center"}
$$ \begin{align*} &(\lambda w.w)((\lambda x.xx)(\lambda y.y))\\ &(\lambda w.w)((\lambda x.xx)[x := \lambda y.y])\\ &(\lambda w.w)((\lambda y.y)(\lambda y.y))\\ &(\lambda w.w)((\lambda y.y)[y := \lambda y.y])\\ &(\lambda w.w)\lambda y.y\\ &(\lambda w.w)[w := \lambda y.y]\\ &\lambda y.y\\ \end{align*} $$
:::

That normalized nicely. Let\'s do another one.

::: {align="center"}
$$ \begin{align*} &(\lambda x.xx)(\lambda y.yy)\\ &(\lambda x.xx)[x := \lambda y.yy]\\ &(\lambda y.yy)(\lambda y.yy)\\ &(\lambda y.yy)[y := \lambda y.yy]\\ &(\lambda y.yy)(\lambda y.yy)\\ &(\lambda y.yy)[y := \lambda y.yy]\\ &(\lambda y.yy)(\lambda y.yy)\\ &\ldots\\ \end{align*} $$
:::

This is a case where we could keep applying the terms ad-nauseum but
that isn\'t needed because the repeating term is
$(\lambda y.yy)(\lambda y.yy)$,
which is also our beta-redex term. So there is no need to go any
further. Now let\'s do another example using free variables.

::: {align="center"}
$$ \begin{align*} &(\lambda x.x)(\lambda z.zz)(\lambda w.t)5\\ &(\lambda x.x)[x := \lambda z.zz](\lambda w.t)5\\ &(\lambda z.zz)(\lambda w.t)5\\ &(\lambda z.zz)[z := \lambda w.t]5\\ &(\lambda w.t)(\lambda w.t)5\\ &(\lambda w.t)[w := \lambda w.t]5\\ &(\lambda w.t)5\\ &(\lambda w.t)[w := 5]\\ &t \end{align*} $$
:::

I mentioned at the beginning I would give an example using free
variables and here it is (ie. t). So what happened to 5? Well it was
bound to w and w is not in the function body of the last lambda term
($\lambda w.t$), so
it didn\'t survive. Although t did and that is because t is not bound to
anything, thus making it a free variable.

Beta reductions are a lot like refactoring some complex code down to its
simpler and functionally equivalent form.

### Untyped Lambda Calculus

So far we haven\'t really considered types. In the examples where
multiplication was required, we went beyond the simple untyped system to
demonstrate the similarities of lambda calculus with other more familiar
systems of computation. In the untyped system, the only type is the
[function type](http://en.wikipedia.org/wiki/Function_type). Our
previous example could still be considered in the untyped system if we
just interpret 5 as a free variable; attaching no meaning to the
variable itself.

As developers, our building blocks are binary logical operations. Let\'s
start by defining some of these essentials in the lambda calculus.

Let T be true and F be false:

::: {align="center"}
$$ \begin{aligned} &T \equiv \lambda x.\lambda y.x\\ &F \equiv \lambda x.\lambda y.y\\ \end{aligned} $$
:::

Now let\'s define some binary operations:

::: {align="center"}
$$ \begin{align*} &AND \equiv \lambda x.\lambda y.xyF\\ &OR \equiv \lambda x.\lambda y.xTy\\ &NOT \equiv \lambda x.xFT\\ \end{align*} $$
:::

To convince ourselves that these will give the desired results, let\'s
start with AND:

::: {align="center"}
$$ \begin{align*} &AND\;T\;F\\ &(\lambda x.\lambda y.xyF)TF\\ &(\lambda x.\lambda y.xyF)[x := T]F\\ &(\lambda y.TyF)F\\ &(\lambda y.TyF)[x := F]\\ &TFF\\ &(\lambda x.\lambda y.x)FF\\ &(\lambda x.\lambda y.x)[x := F]F\\ &(\lambda x.\lambda y.F)F\\ &(\lambda x.\lambda y.F)[x := F]\\ &\lambda y.F\\ &F \end{align*} $$
:::

Then for good measure, let\'s do OR as well:

::: {align="center"}
$$ \begin{align*} &OR\;T\;F\\ &(\lambda x.\lambda y.xTy)TF\\ &(\lambda x.\lambda y.xTy)[x := T]F\\ &(\lambda x.\lambda y.TTy)F\\ &(\lambda x.\lambda y.TTy)[y := F]\\ &TTF\\ &(\lambda x.\lambda y.x)TF\\ &(\lambda x.\lambda y.x)[x := T]F\\ &(\lambda y.T)F\\ &(\lambda y.T)[y := F]\\ &T\\ \end{align*} $$
:::

Learning the untyped variant of lambda calculus is a good starting
place, because we don\'t place any domain restrictions on our functions
and it is fairly simple to get started defining particular behaviors.

### Coming up next

Part two will cover type systems and get you familiar with the syntax.
If you want to learn lambda calculus in more depth or go through some
exercises, check out the links below. Also, please feel free to post
comments with questions, suggestions or corrections.

### More Reading & Resources

-   [Notes on Untyped Lambda
    Calculus](http://www.cse.iitb.ac.in/~rkj/lambda.pdf)
-   [An Introduction to Lambda Calculi and
    Arithmetic](http://www.cs.man.ac.uk/~hsimmons/BOOKS/lcalculus.pdf)
-   [A short introduction to the Lambda
    Calculus](http://www.cs.bham.ac.uk/~axj/pub/papers/lambda-calculus.pdf)
-   [Lectures Notes on the Lambda
    Calculus](http://www.mscs.dal.ca/~selinger/papers/papers/lambdanotes.pdf)
-   [A Tutorial Introduction to the Lambda
    Calculus](http://www.inf.fu-berlin.de/lehre/WS03/alpi/lambda.pdf)
-   [Lambda Calculus
    Tutorial](http://classes.soe.ucsc.edu/cmps112/Spring03/readings/lambdacalculus/project3.html)
-   [An Introduction to Type
    Theory](http://www.cs.ru.nl/~herman/PUBS/IntroTT-improved.pdf)
-   [A Short Introduction to Type
    Theory](http://events.math.unipd.it/3wftop/pdf/coquandintro.pdf)
