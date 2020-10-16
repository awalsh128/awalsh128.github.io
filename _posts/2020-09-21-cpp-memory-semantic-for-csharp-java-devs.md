---
title: C++ Memory Semantics for C# and Java Devs
date: '2020-10-15T00:00:00.000-07:00'
tags:
- C++
modified_time: '2020-10-15T00:00:00.000-07:00'
excerpt: "Understanding how memory semantics works in C++ from the perspective of a C# or Java dev."
toc: true
toc_icon: "columns"
---

When I first started using C++, I was really confused as to how to pass things around and reason about best practices for memory. In C#, primitives were passed by value and all else by memory reference (ignoring nuance). C++ was a whole new world of aliases, pointers, smart pointers, [r/l]value references, forwarding, moves, etc.

This post is a simplified approach to helping C# and Java devs get an introductory understanding of C++ memory semantics so they can confidently create signatures correctly and use it as a stepping stone for more advances techniques. In the following post we will compare C++ against C# for simplicity so we don't have to constantly bring up both C# and Java.

The layout of this post will follow:
* An example of a non-idiomatic approach to C++ and show why it is inefficient. 
* Define the storage durations so that we can understand how C++ handles objects in memory.
* Define the types used to communicate the memory semantics involved.
* Walk through examples, styles and use of the different types described.

{% include warning.html content="We will tend to generalize ideas and lack preciseness in some areas. This is intentional to keep the reader on track. For example, I will not point out memory nuance, or undefined behavior treatments from different compilers. Also, it is assumed that you already understand what pointers, const and references are." %}

## The Literal Approach (AKA Wrong Approach)

Let's start with a common misconception. Memory semantics and how the language approaches it are important. We can't just take our understanding from C# and literally apply it to C++.

For example:
```cs
class Object {
  public int x;
}
void Foo(Object o);

var o = new Object();
Foo(o);
```

Could literally be transformed into:
```cpp
class Object {
 public:
  int x;
};

void Foo(Object* o);

void Bar() {
  auto* o = new Object();
  Foo(o);
}
```

This is a terrible idea, don't do this. The main mistake is confusing C# class memory semantics with C++'s. 
* You just can't change the C# reference to a C++ pointer and be done. This go against the C++ philosophy to prefer the stack. Especially since this is an option not available in C# due to the division between value and reference types
* `Object` is very small (about 8 bytes) and is best allocated on the stack since it is faster (see [gotw/009](http://www.gotw.ca/gotw/009.htm)).
* The scope of the `Object` instance isn't well defined but if we assume it is short lived there is no need for [dynamic allocation](https://en.cppreference.com/w/cpp/language/storage_duration).

Here is a better way to do it:
```cpp
Object o;
FooReadOnly(o); // Simple and fast copy.
FooWrite(&o);   // Simple and fast copy of stack address pointer.
```

## Storage Duration

As noted, there is a strong preference to allocate on the stack since it is much faster for small objects. In C# it is generally assumed that fundamental types are allocated on the stack and reference types on the heap. This is optional in the C++ language as the developer can decide to allocate classes on the stack or on the heap. Therefore it is helpful for the new developer to understand how [storage duration / lifetime](https://en.cppreference.com/w/cpp/language/storage_duration) works in C++.

Going forward we will refer to allocation in terms of the storage duration. Concepts like stack and heap are implementation concerns. While useful when first learning these durations it is better to speak in terms of the traits of these durations than the lower level understanding. For example stack storage is fast but we might as well just say automatic storage is fast instead.

### Automatic

The object lifetime is tied to the code block it is allocated in and is deallocated at the end of the block. We should aim to use this storage duration whenever possible. As noted previously, it is faster (see [gotw/009](http://www.gotw.ca/gotw/009.htm))

```cpp
void Foo() {
  int x = 1;  // Object is allocated.
  // ...
}             // Object is deallocated.
```

### Dynamic

The object lifetime is tied to the declaration of an instance and the explicit deallocation of the instance ([see examples](http://www.cplusplus.com/doc/tutorial/dynamic/)).

{% include warning.html content="Missed deallocation can results in Out of Memory (OOM) errors. This is one of the most dangerous durations since the [de]allocation is controlled by the dev." %}

```cpp
void Foo(Object* o) {
  // ...
}

void Bar() {
  auto* o = new Object();
  Foo(o.get());
  delete o;
}
```

### Thread

The object lifetime is tied to the thread allocation and deallocation. In the example below we will not consider race conditions.

```cpp
#include <threads>

// Object is statically allocated. See Static section below for more information.
thread_local int x = 1;

void Foo(int y) {
  // x is allocated on the thread with original declared value for every new thread and 
  // incremented.
  x += y;
}

void Bar() {
  std::thread t1(Foo, 2);   // Thread instance of x becomes 3 inside Foo.
  std::thread t2(Foo, 3);   // Thread instance of x becomes 4 inside Foo.

  t1.join();  // Thread instance of x is deallocated once thread joins and deallocates.
  t2.join();
}
```

### Static

The object lifetime is tied to that of the program. Note the ``thread_local`` declaration in the section above has static storage duration. Try to be sparing with the size and use of these objects since they have the largest lifetime.

```cpp
static int x = 1; // x is allocated at program start and deallocated at program end.

void Foo() {
  ++x;
}

Foo();  // x is incremented; x = 2.
Foo();  // x is incremented; x = 3.
```

An example of static local variables.

```cpp
void Foo() {
  static int y = 1;
  ++y;
}

Foo();  // y is initialized; y = 1. From now on, the declaration is skipped.
Foo();  // y declaration is skipped and incremented; y = 2;
Foo();  // y declaration is skipped and incremented; y = 3;
```

## Types

C# has a single type taxonomy where everything is derived / inherited from [Object](https://docs.microsoft.com/en-us/dotnet/api/system.object?view=netcore-3.1#remarks) (example [``Int64``](https://docs.microsoft.com/en-us/dotnet/api/system.int64)). This taxonomy allows a common interface of methods available to all child objects like ``Equals`` and ``ToString``. This is not the case for C++. It uses [duck typing](https://en.wikipedia.org/wiki/Duck_typing) to resolve an operations validity at compile time. If the operands have the needed operation (e.g. equals) then it is considered valid.

### Fundamental Types

[C++ fundamental types](https://en.cppreference.com/w/cpp/language/types) are the same types as found in [C# value types](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/value-types).

### Objects

[Objects](https://en.cppreference.com/w/cpp/language/object) also encompass fundamental types as well as classes and structs. Without any additional modifiers, objects are automatically allocated.

```cpp
// Make a automatic copy and use inside Foo.
void Foo(int x);

// In terms of memory it is the same as Foo(int x) since x will be passed as a copy.
// The only reason to keep as const would be to avoid modification inside the code block. 
// IMO, this is indicative of a leaky interface since it is implementation specific.
void Foo(const int x) {
  x = 2;            // ERROR: Cannot change a constant value.
  int y = x;        // Make a copy of x and assign to y; x = 1, y = 1.
  const int z = x;  // Make a copy of x and assign to z upon its initialization.
}
```

### References &amp; Pointers

{% include warning.html content="Don't confuse C# reference types with C++ references. In computer science it is defined as a [value that indirectly accesses a particular datum](https://en.wikipedia.org/wiki/Reference_(computer_science)). C++ narrows this definition to a [specific datatype implementation](https://en.wikipedia.org/wiki/Reference_(C%2B%2B)) using the ``&`` operator, whereas the general definition could refer to pointers as well." %}

```cpp
void Foo() {
  int x = 1;
  int y = x;  // Make a copy of x and assign to y; x = 1, y = 1

  int* z = &x;
  *z = 2;     // Reference x from z; x = 2

  const int a = 1;
  int* b = &a;  // ERROR: Cannot get a reference from a const value.
}

void Foo(int& x) {
  x = 2;
}
int x = 1;
Foo(x);   // x = 2
```

```cpp
// Equivalent function but using a pointer.
void Quux(int* x) {
  *x = 2;
}
int x = 1;
Quux(&x); // x is now 2;
```

Sharing a read only reference.

```cpp
class LargeObject {
 public:
  explicit LargeObject(/*...*/) : /*...*/{};

  int x;
  // Lots of members of large size.
};

void Foo(const LargeObject& o) {
  // Read only and use data from o.
}

void Bar() {
  LargeObject o(...);
  Foo(o);
}
```

Note that ``LargeObject`` is specified for the sake of needing dynamic allocation. This can be due to: having a container with an unspecified size, lifetime is managed in threads, or is in a larger scope than the immediate function and dependent functions.

### Smart Pointers

Resource Acquisition Is Initialization ([RAII](https://en.wikipedia.org/wiki/Resource_acquisition_is_initialization)) is a language idiom that essentially says that object creation is undone by destruction. In C++ this means that any object construction on the stack is also destructed when the object falls out of scope. Smart pointers are simply a wrapper around a pointer. It is allocated when the smart pointer is allocated and deallocated when the smart pointer is deallocated (see [Resource Acquisition Is Initialization (RAII)](https://en.cppreference.com/w/cpp/language/raii). This gets rid of the need to explicitely call a delete and ties the resource lifetime to that of the object wrapping it.

Smart pointers have most of the common operations you would expect like ``*x`` and ``x->y``.

A crude way to represent this, ignoring operations, would be:

```cpp
template <class T>
struct simple_smart_pointer {
 public:
  simple_smart_pointer() = delete;
  // Don't allow copies or multiple assignments.
  // There should only ever be a single instance.
  simple_smart_pointer(const simple_smart_pointer&) = delete;
  simple_smart_pointer& operator=(const simple_smart_pointer&) = delete;

  template <class... TArgs>
  explicit simple_smart_pointer(...args)  // Pass variadic args.
  {
    value_ = new T(args...);
  }

  ~simple_smart_pointer()
  {
    delete value_;
  }

 private:
  T* value_;
};
```

#### Unique Pointer

An example of using a type of non-shared smart pointer called [``std::unique_ptr``](https://en.cppreference.com/w/cpp/memory/unique_ptr).

```cpp
#include <memory>

class LargeObject {
 public:
  explicit LargeObject(/*...*/) : /* initialize members */ {};

  int x;
  // Lots of members of large size.
};

void Foo(std::unique_ptr<LargeObect> o) {
  // Take ownership and process o.
}

void Bar() {
  // Automatically allocate std::unique_ptr and dynamically allocate the wrapped value.
  auto o = std::make_unique<LargeObject>(/*...*/);
  // ...
  Foo(std::move(o));
}
```

The [std::move](https://en.cppreference.com/w/cpp/utility/move) function is used to transfer the resource from ``Bar`` scope to ``Foo``. This means that ownership can be passed to other scopes and objects. Although once moved, it can no longer be used in that same scope.

```cpp
#include <memory>

void Foo() {
  std::unique_ptr<LargeObject> o(/*...*/);
  Foo(std::move(o));  
  int y = o->x;   // ERROR: Undefined behavior.
}
```

```cpp
#include <memory>

void Foo() {
  std::unique_ptr<LargeObject> o(/*...*/);
  LongLivedProcessing(std::move(o));
}
```

So that in context of ``Foo`` it now owns the ``std::unique_ptr`` and its underlying destructions of the dynamically allocated ``LargeObject``. Once it falls out of scope, the object is dynamically deallocated. This data type is important when applying to the concept of ``std::unique_ptr`` because it helps transfer ownership down stack.

```cpp
void Foo(std::unique_ptr<LargeObject> o) {
  // Acts on o->x;
} // o falls out of scope and it is dynamically destructed.
```

#### Shared Pointer

Think of shared pointer as the ``simple_smart_pointer`` but with the copy operation allowed and holding an internal [reference count](https://en.wikipedia.org/wiki/Reference_counting).

A crude way to represent this, ignoring operations, would be:

```cpp
template <class T>
struct simple_shared_pointer {
 public:
  simple_shared_pointer() = delete;
  simple_shared_pointer(const simple_smart_pointer& p) {    
    // Increase reference count now that we have another automatically allocated instance.
    *counter_ = ++(*p.counter_);
    value_ = p.value_;
  }
  simple_shared_pointer& operator=(const simple_smart_pointer& p) {
    // Increase reference count now that we have another automatically allocated instance.
    *counter_ = ++(*p.counter_);
    value_ = p.value_;
  }

  template <class... TArgs>
  explicit simple_shared_pointer(...args) // Pass variadic args.
  {
    value_ = new T(args...);
  }

  ~simple_shared_pointer()
  {
    // Decrease reference count now that instance is automatically deallocated.
    int new_counter = --(*counter_);
    // If this is the last instance, dynamically deallocate the value.
    if (new_counter == 0) delete value_;
  }

 private:
  int* counter_;  // Reference counter.
  T* value_;      // Shared dynamically allocated value.
};
```

An example of using a type of shared smart pointer called [``std::shared_ptr``](https://en.cppreference.com/w/cpp/memory/shared_ptr).

```cpp
void Bar(std::shared_ptr<LargeObject> o) {
  // Do stuff with o all in scope. No passing to objects that outlive Bar.  
} // Decrement reference count as std::shared_ptr is destructed.

void Baz() { 
  auto o = std::make_shared<LargeObject>(/*...*/); // Reference count starts at 1.
  Bar(o); // Increment reference count to 2 as std::shared_ptr is copied.
  Bar(o); // Increment reference count to 3 as std::shared_ptr is copied.
} // o falls out of scope
```

#### Weak Pointer

There is a similar concept in C# (i.e. [WeakReference](https://docs.microsoft.com/en-us/dotnet/api/system.weakreference)) that corresponds to ([``std::weak_ptr``](https://en.cppreference.com/w/cpp/memory/weak_ptr) in C++. It is constructed from a ``std::shared_ptr`` and [de]allocated dynamically using reference count. If the ``std::shared_ptr`` is deallocated then the ``std::weak_ptr`` will return null.

```cpp
void Foo() {
  std::shared_ptr<int> shared = std::make_shared<int>(1);
  std::weak_ptr<int> weak = shared;

  // Creates a std::shared_ptr pointing to std::weak_ptr with reference count 1
  std::shared_ptr<int> shared1 = weak.lock();
  std::shared_ptr<int> shared2 = weak.lock(); // std::shared_ptr reference count 2
  std::shared_ptr<int> shared3 = weak.lock(); // std::shared_ptr reference count 3

  shared3.reset();  // std::shared_ptr reference count 2
  shared2.reset();  // std::shared_ptr reference count 1

  weak.expired();   // Check that there are still std::shared_ptr's in memory.
  shared.reset();   // Only allowed if is the last std:shared_ptr
  // weak is expired and shared is null
}  
```

## Examples

Below are some different ways to think about how to provide your signatures and what they convey. 

{% include warning.html content="Note in each section how pointer can be ambiguous and possibly result in multiple ownership. Most of the time you never really want two objects holding on to the same pointer unless they are well coordinated. If one deletes the pointer you will get a segmentation fault upon further access." %}

### Inputs

```cpp
void Foo(int x);  // Preferred for fundamental types as noted earlier.

void Foo(const LargeObject& o); // Read-only reference to o.

void Foo(LargeObject& o); // Read and write reference to o.

void Foo(std::unique_ptr<LargeObject> o); // Transfer ownership to Foo block.

// Copy pointer and allow read and write operations.
// Could be owned by caller or being passed to caller.
void Foo(LargeObject* o);
```

### Outputs

#### Outputs as Return Value

```cpp
class Foo;

int Bar();  // Return a copy of the function scoped return.

const int Bar(); // Return a read-only copy of the function scoped return.

// Return a reference to LargeObject held by Foo.
// Foo must outlive caller.
LargeObject& Foo::Bar();

// Return a read-only reference to LargeObject held by Foo.
// Foo must outlive caller.
const LargeObject& Foo::Bar();

std::unique_ptr<LargeObject> Bar(); // Transfer ownership to calling block.

// Return a copy of a pointer.
// Could be owned by Foo or being passed to caller.
LargeObject* Foo::Bar();
```

#### Outputs as Arguments

```cpp
void Foo(int& x); // Read and write reference to x.

void Foo(int* x); // Read and write of x from pointer.
```

{% include note.html content="There is nothing inherently bad with having outputs as arguments but whenever possible it is better to communicate it on the return. See the Readability section below for more information and cases." %}

#### Readability

In [functional programming](https://en.wikipedia.org/wiki/Functional_programming) there is a concept of [referential transparency](https://en.wikipedia.org/wiki/Referential_transparency) or [pure functions](https://en.wikipedia.org/wiki/Functional_programming#Pure_functions), which forbids side effects. This makes programs easier to reason about because you don't need to look at the implementation to see what they do. For example consider the signature:

```cpp
void DoStuff(int x, int* y);
```

We can see that ``x`` is an input but ``y`` may or may not be an input or an output or both. As far as we know ``y`` could point to an unpopulated object that needs to be filled, or it could just be an input that is a pointer, or it could be an input transferring control of the pointer to something else (e.g. another thread or static member). Let's narrow this and try to eliminate the ambiguity assuming that the input is a read and write value.

```cpp
void DoStuff(int x, int& y);
```

Okay now we narrowed down the definition to allow for a variable that can be read from and written to. If we wanted to make it just a read only reference, we could ``const`` qualify it. Although lets assume it is read and write.

```cpp
void DoStuff(int x, int y);
```

While it accomplishes the same thing as the signature before, it is now very clear that the value is both read and written / computed. The signature now communicates this very cleanly and in a transparent way.  The same idea can be applied to multiple outputs too using ``std::tuple``.

```cpp
std::tuple<int, int> DoStuff(int x, int y);
```

Although what do we do about ``LargeObject`` if we wanted to make a minor mutation, then return a copy of ``LargeObject`` along with the mutation?

```cpp
LargeObject DoStuff(const LargeObject& o);
```

While this works from a functional point of view, it has horrible performance implications. How about:

```cpp
LargeObject& DoStuff(const LargeObject& o) { return o; }   // Illegal
```

This doesn't work because you can't make a ``const`` qualified input and be able to return a read/write reference to it. Although this will work:

```cpp
LargeObject& DoStuff(LargeObject& o);
```

Isn't this the same thing as just returning a ``void``? Yes, and maybe it is best just to do so since ``&`` without ``const`` communicates that it is possibly read and definitely written. In these cases, it is hard to express the semantics cleanly due to performance.

### Dependency Injection (DI) Container

```cpp
class Component1 {
 public:
  explicit Component1(bool production) : production_(production) {}
  // ...
 private:
  // ...
  bool production_;
};

class Component2 {
 public:
  explicit Component2(bool production) : production_(production) {}
  // ...
 private:
  // ...
  bool production_;
};

class Container {
 public:
  // Consume only unique pointers since no other object should hold the dependencies
  explicit Container(
    std::unique_ptr<Component1> component1, 
    std::unique_ptr<Component2> component2)
    // Release ownership to the new Container.
    : component1_(std::move(component1)), 
      component2_(std::move(component2)) {}

  static Container CreateNonProd() {    
    return Container(
      std::make_unique<Component1>(/*production=*/false),
      std::make_unique<Component2>(/*production=*/false));
  }
  static Container CreateProd() {    
    return Container(
      std::make_unique<Component1>(/*production=*/true),
      std::make_unique<Component2>(/*production=*/true));
  }

  // Never expose the pointer, just the value pointed to.
  Component1& component1() { return component1_; }
  Component2& component2() { return component2_; }

 private:
  std::unique_ptr<Component1> component1_;
  std::unique_ptr<Component2> component2_;
};

void DoStuff(Component1& component) { /*...*/ }

void Foo() {
  auto prod_container = Container::CreateProd();
  DoStuff(prod_container.component1());
}
```

## Rules of Thumb

* Copies can be a faster operation for small objects.
* Only use smart pointers when the object is very large or needs to be shared outside the scope it was created in. 
* Avoid raw pointers whenever possible.
* Prefer references over raw or smart pointers where available.

## Conclusion

Hopefully this gives you a sense now how storage works and how to communicate memory semantics in the best and most performant way possible. Please feel free to leave comments on errata or your own thoughts.