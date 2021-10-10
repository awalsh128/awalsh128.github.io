---
layout: posts
title: Fluent C++ v0.1 Release
last_modified_at: 2021-10-10 00:00:01 -0700
tags:
- Fluent C++
- C++
- fluent programming
---

## Motivation

I had been wanting to make a library to express data transformation in a fluent way. The STL already has some functions for this. For example, if I wanted to transform a sequence and then filter based on a conditional I would do this.

```cpp
std::vector<int> xs;
// Add int to xs.
std::transform(
  xs.begin(), xs.end(),
  [](auto x) { return ++x; });

std::vector<int> filtered;
filtered.reserve(xs.size());
std::copy_if(
  xs.begin(), xs.end(),
  std::back_inserter(filtered),
  [](auto x) { return x % 2 == 0; });
```

This is indeed a functional approach to expressing data transformations. It applies functions to data sets and without side effects (as long as you don't cause any in the lambda). Although, there can also be a lot of boilerplate if you just wants the entire range of the container. Also, it is not always obvious from first glance what the inputs and outputs are to the function because it doesn't follow the typical ``f(a,b) = c`` mathematical format. This doesn't make it less functional but perhaps less readable.

The library that I put together uses a different approach that addresses some of these concerns.

```cpp
#include <fluentcpp/query.h>

std::vector<int> xs;
// Add int to xs.
std::vector<int> filtered =
  fcpp::query(std::move(xs))
    .select([](auto x) { return ++x; })
    .where([](auto x) { return x % 2 == 0; });
```

This style is patterned after the [.NET LINQ framework](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/linq/) something I had become very accustomed to before programming in C++ full time.

## Initial Release

[Version 0.1 is now available on GitHub](https://github.com/awalsh128/fluentcpp/releases/tag/v0.1). As mentioned in the repository [README.md](https://github.com/awalsh128/fluentcpp#installing), you can easily install the library with the instructions below.

- Go to [the release](https://github.com/awalsh128/fluentcpp/releases) you want to install.
- Download the `fluentcpp-<tag>.tar.gz` file.
- Decompress the file in the directory `tar -xvzf fluentcpp-<tag>.tar.gz`.
- Run the install command `sudo ./install.sh`.
- The library files are now installed on your system and can be used as in the examples.

## Caveats

Since this is an initial release, there are some drawbacks to using this over the STL functional library or just older C++ constructs (e.g. for-loops).

- Memory semantics are strictly by reference and move. This is intentional to accomodate the strictest object constructor and assignment declarations (i.e. no copy and move).
- Strict memory semantics has implications for fundamental types where copy is more efficient.
- Performance has not been benchmarked yet so it is unknown how it performs against the alternatives.
- Static analysis hints can still seem obscure. While they depend on the STL [concepts](https://en.cppreference.com/w/cpp/concepts) enforced, the wording can be confusing across the interface.

## Feedback

I hope this proves useful to people and can become a wider community effort. It is primarily a proof of concept work and needs more to demonstrate it can be used in production code with similar performance to the status quo.
