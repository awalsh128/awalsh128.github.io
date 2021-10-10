---
title: C++ validate and throw with a dynamic message in a single line.
excerpt: "Assert a condition and throw with a dynamic message in a single line in C++."
last_modified_at: 2021-10-10 00:00:01 -0700
tags:
- C++
---

I was looking to validate and throw on invalid arguments in my code. This meant I had to write something like.

```cpp
void foo(size_t size) {
  if (size > this.current_size) {
    throw std::invalid_argument("Size cannot be greater than current size.");
  }
  ...
}
```

Not so bad really but I also wanted to create a dynamically created message.

```cpp
void foo(size_t size)
  if (size > this.current_size) {
    std::stringstream text;
    text << "Size " << size << " cannot be greater than current size of " << this.current_size << ".";
    throw std::invalid_argument(text.str());
  }
  ...
}
```

We could shorten it...

```cpp
void validate(bool condition) {
  if (condition) return;
  std::stringstream text;
  text << "Size " << size << " cannot be greater than current size of " << this.current_size << ".";
  throw std::invalid_argument(text.str());
}
void foo(size_t size)
  validate(size > this.current_size);
  ...
}
```

... but it isn't very re-usable since the message is hardcoded.

C++20 offers the ability to use [std::format](https://en.cppreference.com/w/cpp/utility/format/format).

```cpp
void foo(size_t size)
  if (size > this.current_size) {
    throw std::invalid_argument(std::format("Size {} cannot be greater than current size of {}.", size, this.current_size));
  }
  ...
}
```

Pretty nice, although for people not on that standard they are left with the previous validation approach. There is a different way to do it however.

```cpp
void foo(size_t size)
  invariant::eval(size > this.current_size) << 
    "Size " << size << " cannot be greater than current size of " << this.current_size << "."; 
  ...
}
```

Here is how it is implemented.

```cpp
class invariant
{
 private:
  const bool condition_;
  std::stringstream message_;

  invariant(bool condition) : condition_(condition), message_() {}  
  invariant() = delete;
  invariant(const invariant &) = default;

 public:
  ~invariant() noexcept(false)
  {
    if (!condition_)
    {
      // Living dangerously, guaranteed not to live on the stack though.
      throw std::invalid_argument(message_.str());
    }
  }

  template <typename Text>
  friend invariant &&operator<<(invariant &&item, const Text &text)
  {
    item.message_ << text;
    return std::move(item);
  }

  static invariant eval(bool condition)
  {
    return invariant(condition, "");
  }
};
```

Not so bad maybe for pre C++20 but why have a throw in the destructor? This [can be dangerous](https://wiki.c2.com/?BewareOfExceptionsInTheDestructor) since it is called when the stack unwinds.

```cpp
  ~invariant() noexcept(false)
  {
    if (!condition_)
    {
      // Living dangerously, guaranteed not to live on the stack though.
      throw std::invalid_argument(message_.str());
    }
  }
```

The key is to make sure it never gets on the stack in the first place. This means making it never becomes an lvalue. [Herb Sutter discusses this](https://herbsutter.com/2014/05/03/reader-qa-how-can-i-prevent-a-type-from-being-instantiated-on-the-stack/) strategy by ensuring that the object only ever can be an rvalue reference than cannot be copied or constructed. Here are the pieces that make this possible.

```cpp
  invariant(bool condition) : condition_(condition), message_() {}  
  invariant() = delete;
  invariant(const invariant &) = default;
```

Lastly is getting the dynamic message input.

```cpp
  template <typename Text>
  friend invariant &&operator<<(invariant &&item, const Text &text)
  {
    item.message_ << text;
    return std::move(item);
  }
```

Note how an rvalue reference is passed in and out. This ensures that it is never copied while also modifying the object's ``message`` state.

This exercise was fun and informative for myself but can be quite dangerous if not understood well and modified without such knowledge. There is also a safer alternative (well why didn't you say so?!) using a variadic template via [parameter pack](https://en.cppreference.com/w/cpp/language/parameter_pack). You can find the answers to string concatenation on [this StackOverflow post](https://stackoverflow.com/questions/21806561/concatenating-strings-and-numbers-in-variadic-template-function). An adaptation from the top answer would look like.

```cpp
template< typename ...Args>
void invariant(bool condition, const Args&... args)
{
  if (condition) return;
  std::stringstream message;
  using List= int[];
  (void)List{0, ((void)(message << args), 0 ) ...};
  throw std::invalid_argument(message.str());   
}
```
