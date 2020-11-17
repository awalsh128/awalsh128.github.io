---
title: C++ Examples
date: '2020-09-07T21:46:00.000-07:00'
tags:
- C++
modified_time: '2020-10-06T00:00:00.000-07:00'
excerpt: "C++ notes giving short examples on commonly used data structures and patterns."
toc: true
---

## Asserts (Static)

For type support and asserts see the
[CPP Reference](https://en.cppreference.com/w/cpp/types) entry which has an
exhaustive list.

```cpp
template <typename T>
T DoSomething(T value) {
  static_assert(std::is_same<decltype(value), bool>::value, "value must be bool");
  // ...
}
```

```cpp
template <typename T>
T DoSomething(T value) {
  static_assert(std::is_floating_point<T>::value,
                "value must be an floating type.");
  // ...
}
```

```cpp
template <typename T>
T DoSomething(T value) {
   static_assert(std::numeric_limits<T>::is_integer,
                "value must be an integer type.");
  // ...
}
```

```cpp
int DoSomething(int even, int odd) {
  static_assert(even % 2 == 0 "even value must be an even number.");
  static_assert(odd % 2 != 0 "odd value must be an odd number.");
  // ...
}
```

```cpp
template <typename T>
std::vector<std::byte> ToBytes(const T& object) {
  static_assert(
      std::is_fundamental<T>::value || std::is_same<T, std::string>::value,
      "object must be a fundamental or string type.");
  // ...
}
```

## Fibers

*   [Boost.Fiber](https://www.boost.org/doc/libs/1_73_0/libs/fiber/doc/html/index.html)

Trivial usage.

```cpp
#include "boost/fiber/fiber.hpp"

// Lambda to Fiber is always std::function<void()>.
auto fiber = std::make_unique<boost::fibers::fiber>([]() { DoSomething(); });
DoSomethingElse();
fiber->join();
```

Using a channel to communicate data.

```cpp
#include "thread/fiber/fiber.h"
#include "boost/fiber/buffered_channel.hpp"

std::string CreateText() { /* ... */ }
boost::fibers::buffered_channel<std::string> channel(0);

// Capture channel by reference in the lambda below.
auto fiber = std::make_unique<boost::fibers::fiber>([&channel]() {
  channel.push(CreateText());  
});

// Don't join until channel is read or it will hang.
std::string created_text;
channel->pop(&created_text);
channel->close();

fiber->join();
```

## File

### Write

```cpp
#include <fstream>
#include <iostream>
#include <string_view>

std::string_view file_path = "/dir/file_path.txt";
std::string_view contents = "stuff blah blah";

std::ofstream my_file;
my_file.open(file_path, ios::out | ios::in);
my_file << contents << std::endl;
my_file.close();
```

### Read

```cpp
#include <fstream>
#include <iostream>
#include <string_view>

std::string_view file_path = "/dir/file.txt";
std::string contents;

std::ifstream my_file;
my_file.open(file_path);
my_file >> contents;
```

### Join Paths

```cpp
#include <iostream>
#include <filesystem>

std::filesystem::path file_path = "/dir";
file_path /= "*.stuff";  // Inserts separator.
```

### List Directory

```cpp
#include <string>
#include <iostream>
#include <filesystem>
#include <string_view>

namespace fs = std::filesystem;

std::string_view path = "/dir";
for (const fs::directory_entry& entry : fs::directory_iterator(path)) {
  // ...
}
// or recursively 
for (const fs::directory_entry& entry : fs::recursive_directory_iterator(path)) {
  // ...
}
```

### Create &amp; Remove Directory

```cpp
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <filesystem>

namespace fs = std::filesystem;
 
const bool created = fs::create_directories("/dir1/dir2/dir3");      // Create recursively.
const bool created = fs::create_directory("/dir1/dir2", "/dir/qux"); // Create multiple non-recursively.
const bool removed = fs::remove_all("/dir");                         // Remove all directories and sub directories.
```

### Copy

```cpp
#include <filesystem>

std::filesystem::copy("/file1.txt", "/file2.txt");
std::filesystem::copy("/dir1", "/dir2");
std::filesystem::copy("/dir1", "/dir2", std::filesystem::copy_options::recursive);
```

### Permissions

See C++ reference of [std::filesystem::perms](https://en.cppreference.com/w/cpp/filesystem/perms) for an exhaustive list of constants.

```cpp
#include <fstream>
#include <bitset>
#include <iostream>
#include <filesystem>

namespace fs = std::filesystem;

fs::permissions("file.txt", fs::perms::owner_all);                           // rwx------
fs::permissions("file.txt", fs::perms::owner_all | fs::perms::group_all);    // rwxrwx---
fs::permissions("file.txt", fs::perms::others_write);                        // -------w-
```

### Path Parts

```cpp
#include <filesystem>

const auto path = std::filesystem::path("/dir/file.txt");
path.filename();      // file.txt
path.stem();          // file
path.extension();     // txt  
path.parent_path();   // /dir
```

## Hashed

### Map

```cpp
#include <map>

std::map<std::string, int> text_to_int;
text_to_int.insert(std::make_pair("foo", 1));
// or ...
text_to_int.insert({"foo", 1});
// or ...
text_to_int["foo"] = 1;
```

```cpp
#include <map>
#include <string_view>

std::map<std::string, MyObject> text_to_int;
// ... insert stuff
for (auto it = text_to_int.begin(); it != text_to_int.end(); ++it) {
    std::string_view t = it->first;
    const int x = it->second;
    // ...
}
```

```cpp
#include <map>
#include <string_view>

std::map<std::string, MyObject> text_to_int;
// ... insert stuff
auto it = text_to_int.find("foo");
if (it == text_to_int.end()) {
  // not found
} else {
  std::string_view t = it->first;
  const int x = it->second;
}
```

### Set

```cpp
#include <set>

std::set<std::string> texts;
auto pair = texts.insert("foo");
auto it = pair.first;   // iterator at inserted or already inserted value
bool inserted = it.second;
```

```cpp
#include <set>

std::set<std::string> texts;
auto it = texts.find("foo");
bool found = it != texts.end();
const std::string value = *it;  // "foo"
```


```cpp
#include <set>

std::set<std::string> texts;
texts.insert({"bar", "baz"});
```

## Iterators

### Copy

```cpp
#include <algorithm>
#include <iterator>
#include <vector>

std::vector<int> source{1, 2, 3, 4};
std::vector<int> target;
std::copy(source.begin(), source.end(), target.begin());
// target = {1, 2, 3, 4}
```

```cpp
#include <algorithm>
#include <iterator>
#include <vector>

std::vector<int> source{1, 2, 3, 4};
std::vector<int> target;
std::copy(source.begin() + 1, source.end() - 1, target.begin());
// target = {2, 3}
```

```cpp
#include <algorithm>
#include <iterator>
#include <vector>

std::vector<int> source{1, 2, 3, 4};
std::vector<int> target;
std::copy_if(source.begin(), source.end(), target.begin(),
             [](int x) { return x % 2 == 0 });
// target = {2, 4}
```

### Filter

```cpp
#include <ranges>
#include <vector>

std::vector<int> source{1, 2, 3, 4, 5};
std::vector<int> target;

auto is_even = [](int x) { return 0 == x % 2; };
auto square = [](int x) { return x * i; };

for (int element : elements | std::views::filter(is_even) |
                              std::views::transform(square)) {
    target.push_back(element);
}
// target = { 4, 16 }
```

### Find

```cpp
#include <algorithm>
#include <vector>
#include <iterator>

std::vector<int> elements{1, 2, 3, 4};
auto it = std::find(elements.begin(), elements.end(), 3);
// *it = 3
```

```cpp
#include <algorithm>
#include <vector>
#include <iterator>

std::vector<int> elements{1, 2, 3, 4};
auto it = std::find_if(elements.begin(), elements.end(),
                  [](int x) { return x == 3; });
// *it = 3
```

### Loop

```cpp
#include <vector>
#include <iterator>

std::vector<int> source{1, 2, 3, 4};
std::vector<int> target;
for (std::vector<int>::iterator it = source.begin(); it < source.end(); ++it) {
  target.push_back(*it);
}
// target = {1, 2, 3, 4}
```

```cpp
#include <vector>
#include <iterator>

std::vector<int> source{1, 2, 3, 4};
std::vector<int> target;
for (auto it = source.begin(); it < source.end() - 1; ++it) {
  target.push_back(*it);
}
// target = {1, 2, 3}
```

```cpp
#include <vector>
#include <iterator>

std::vector<int> source{1, 2, 3, 4, 5};
std::vector<int> target;
for (auto it = source.begin(); it < source.end(); ++it) {
  target.push_back(*it++);
}
// target = {1, 3, 5}
```

```cpp
#include <vector>
#include <iterator>

int i = 0;
std::vector<int> elements{4, 0};  // elements = {0, 0, 0, 0}
for (auto it = elements.begin(); it < elements.end(); ++it) {
  *it = ++i;
}
// elements = {1, 2, 3, 4}
```

## Macros

Can be used to create slightly redundant function signatures or in modules like
tests. The following macros contains 31 lines of code (LOC) and replaces 392
(LOC).

```cpp
// For each function replace mentions of:
//   N with {1-7} and
//   M with {1-7}
// gives 49 functions with 8 lines of code each
// gives 392 lines of code
std::string GetFooNM(int& foo_value) {
  std::string value = DoSomething(foo_value);
  DoOtherStuff(&value);
  if (value == "foo") {
    return N;
  } else {
    return M;
  }
}
std::string GetBarNM(const int& bar_value) {
  std::string value = DoSomething(bar_value);
  DoOtherStuff(&value);
  if (value == "foo") {
    return N;
  } else {
    return M;
  }
}
int GetBazNM(std::string_view baz1_value, int baz2_value) {
  std::string value = DoSomething(baz1_value);
  DoOtherStuff(&value);
  if (value == "foo") {
    return N;
  } else {
    return M;
  }
}

// Allows for variadic macros with no arguments.
#define VA_ARGS(...) , ##__VA_ARGS__

#define GET_DECL_NM(n, m, return_type, func_name, ...)    \
int Get##func_name##n##m(VAR_ARGS) {                      \
  std::string value = DoSomething(VAR_ARGS(__VA_ARGS__)); \
  DoOtherStuff(&value);                                   \
  if (value == "foo") {                                   \
    return n;                                             \
  } else {                                                \
    return m;                                             \
  }

#define GET_DECL_N(m, return_type, func_name, ...)    \
  return_type func_name##1##m(VAR_ARGS(__VA_ARGS__)); \
  return_type func_name##2##m(VAR_ARGS(__VA_ARGS__)); \
  return_type func_name##3##m(VAR_ARGS(__VA_ARGS__)); \
  return_type func_name##4##m(VAR_ARGS(__VA_ARGS__)); \
  return_type func_name##5##m(VAR_ARGS(__VA_ARGS__)); \
  return_type func_name##6##m(VAR_ARGS(__VA_ARGS__)); \
  return_type func_name##7##m(VAR_ARGS(__VA_ARGS__));

#define GET_DECL(return_type, func_name, ...) \
  GET_DEC_N(1. return_type, func_name, ...);  \
  GET_DEC_N(2. return_type, func_name, ...);  \
  GET_DEC_N(3. return_type, func_name, ...);  \
  GET_DEC_N(4. return_type, func_name, ...);  \
  GET_DEC_N(5. return_type, func_name, ...);  \
  GET_DEC_N(6. return_type, func_name, ...);  \
  GET_DEC_N(7. return_type, func_name, ...);

GET_DECL(std::string, Foo int& foo_value);
GET_DECL(std::string, Bar, const int& foo_value);
GET_DECL(std::string, Baz, std::string_view baz1_value, int baz2_value);

#undef GET_DECL
#undef GET_DECL_N
#undef VA_ARGS
```

## Protocol Buffers

[Protocol Buffers C++ API](https://developers.google.com/protocol-buffers/docs/reference/cpp)

### Differencer

```cpp
#include <google/protobuf/util/message_differencer.h>
Proto proto1 = /* ... */;
Proto proto2 = /* ... */;
bool is_equal = google::protobuf::util::MessageDifferencer::Equals(&proto1, &proto2);
```

### Repeated Fields

```cpp
#include <google/protobuf/repeated_field.h>

Proto message;
message.add_int32_fields(1);
message.add_int32_fields(2);
message.add_int32_fields(3);

void Add(google::protobuf::RepeatedPtrField<Proto> int32_fields) {
  int32_fields.Add(4);
  int32_fields.Add(5);
}

google::protobuf::RepeatedPtrField<Proto> int32_fields = message.mutable_int32_fields();

Add(int32_fields);

// message.int32_fields = {1, 2, 3, 4, 5}
```

### Parse File

```cpp
#include <google/protobuf/text_format.h>
#include <fstream>
#include <iostream>

std::string proto_text;
std::ifstream my_file;
my_file.open("/dir/file.text_proto");
my_file >> proto_text;

Proto proto;
const bool parsed = google::protobuf::TextFormat().ParseFromString(proto_text, &proto);
```

### Parse Text

```cpp
#include <google/protobuf/text_format.h>

std::string_view proto_text = R"pb({ foo: "test_foo1" bar: "test_bar1" })pb";
Proto proto;
const bool parsed = google::protobuf::TextFormat().ParseFromString(proto_text, &proto);
```

```cpp
#include <google/protobuf/text_format.h>
#include <string_view>

Proto proto;

std::string_view proto_text = R"pb({ foo: "test_foo1" bar: "test_bar1" })pb";
bool success1 = google::protobuf::TextFormat::ParseFromString(proto_text, &proto);

std::string_view proto_text_view =
    R"pb({ foo: "test_foo1" bar: "test_bar1" })pb";
bool success2 = google::protobuf::TextFormat::ParseFromStringPiece(proto_text_view,
                                                         &proto);
```

## Random

[C++ Reference: Random](https://en.cppreference.com/w/cpp/numeric/random) - For a complete listing of different distributions.

WARNING: The following are not cryptographically secure.

```cpp
#include <random>

// Other RNGs can also be defined instead.
std::default_random_engine rng;

// Random signed int32 interval [1, 2^31)
std::uniform_int_distribution<int> distribution(1, 1 << 31);
int x = distribution(rng);
// Random signed int32 interval [2, 10).
std::uniform_int_distribution<int> distribution(2, 10);
int y = distribution(rng);
// Random bool weighted 75% true and 25% false.
std::bernoulli_distribution distribution(0.75);
bool x = distribution(rng);
```

## Strings

[C++ Reference: Strings](https://en.cppreference.com/w/cpp/string)

### Case

[C++ Reference: tolower](https://en.cppreference.com/w/cpp/string/byte/tolower)<br/>
[C++ Reference: toupper](https://en.cppreference.com/w/cpp/string/byte/tolower)

```cpp
#include <cctype>
#include <string_view>

std::string_view text = "Foo";
std::tolower(text); // -> foo
std::toupper(text); // -> FOO
```

### Concatenate

```cpp
#include <string>
#include <string_view>
std::string_view text = "cat" + "this" + "together";
```

### Contains

```cpp
#include <string>
#include <string_view>
std::string_view text = "foo bar baz";
const std::size_t pos = text.find("foo");
const bool found = pos != std::string::npos;
```

### Format

[C++ Reference: #print# functions](https://en.cppreference.com/w/cpp/io/c/fprintf)

```cpp
#include <cstdio>
std::printf("%c", 32)       // Character = " "
std::printf("%s", "foo")    // String = "foo"
std::printf("%02d", 1)      // Decimal = "01"
std::printf("%o", 16)       // Octal = "20"
std::printf("%#x", 0x16)    // Hex = "0x16"
std::printf("%X", 10)       // Hex = "A"
std::printf("%05.2f", 1.6)  // Floating Point = "01.60"
std::printf("%e", 1.6)      // Scientific = "1.600000e+00"
std::printf("%p", ptr)      // Pointer = "0x7ffdeb6ad2a4"
```

[C++ Reference: std::format](https://en.cppreference.com/w/cpp/utility/format/format)

```cpp
#include <format>
#include <string>
// text = "x = 1, y = 2.0, z = "z""
const std::string text = std::format("x = {}, y = {}, z = {}", 1, 2.0, "z");
```

### Join

```cpp
#include <string>
#include <string_view>
#include <vector>

std::vector<std::string> words{"foo", "bar", "baz"};
std::string_view delimiter = "--";

std::string joined;
for (int i = 0; i < words.size() - 1; ++i) {
  joined.append(words[i]);
  joined.append(delimiter);
}
joined.append(words[words.size()-1]);
```

### Replace

```cpp
#include <string>
#include <string_view>

std::string text = "foo bar foo baz";
std::string_view target = "foo";
std::string_view replacement = "qux";

std::size_t pos = text.find(foo);
while (pos != std::string::npos) {
  text = text.replace(pos, target.size(), replacement);
  pos = text.find(foo);
}
```

### RegEx

[C++ Reference: RegEx](https://en.cppreference.com/w/cpp/regex)

```cpp
#include <regex>

std::regex re(R"(([A-Z][a-z]+) ([A-Z][a-z]+)");
std::smatch matches; // alias to std::match_results<string::const_iterator>

std::regex_match("Theodore Smiley", matches, re); // = true
// matches = {"Theodore Smiley", "Theodore", "Smiley"}; // First one is the full match.

std::regex_match("Theodore Smiley II", matches, re); // = false; must be a full match.
```

```cpp
#include <regex>

std::regex re(R"(([A-Z][a-z]+) ([A-Z][a-z]+)");
std::smatch matches; // alias to std::match_results<string::const_iterator>

std::regex_search("Theodore Smiley II", matches, re); // = true
// matches = {"Theodore Smiley", "Theodore", "Smiley"}; // First one is the full match.

std::regex_search("Theodore", matches, re); // = false; must match the whole RegEx.

std::regex_search("Theodore Louis Tenacious Smiley II", matches, re); // = true
// matches = {"Theodore Louis", "Theodore", "Louis"}; // Only matches for one found.
```

### Split

```cpp
#include <string_view>
#include <vector>

std::string_view text = "foo::bar::::baz";
std::string_view delimiter = "::";

std::vector<std::string_view> elements;
std::size_t start = 0;
std::size_t end = text.find(delimiter);
while (end != std::string::npos) { 
  elements.push_back(text.substr(start, end - start));
  start = end + delimiter.size();
  end = text.find(delimiter, start);
}
elements.push_back(text.substr(start)); // {"foo", "bar", "", "baz"}
```

### Starts With

```cpp
#include <string_view>
std::string_view text = "foo/bar";
const bool starts_with = text.rfind("foo", 0) == 0;
```

### String View Materialize

```cpp
#include <string>
#include <string_view>
void DoSomething(std::string_view text);
auto materialized = std::string(text);    // Materialize to a string copy.
```

### Strip Prefix

```cpp
#include <string>
#include <string_view>
std::string_view text = "foo/bar";
std::string_view prefix = "foo";
std::string_view stripped = text.rfind(prefix, 0) ? text : text.substr(0, prefix.length);
```

## Structs

```cpp
struct Point {
  int x;
  int y;
};

struct Point p = {1, 2};
struct Point p = {.y = 2, .x = 2};
```

The operator overloading below can be applied to classes as well. See the Syntax section of the [C++ Reference: Operators](https://en.cppreference.com/w/cpp/language/operators) Syntax section for an exhaustive list.

```cpp
struct Point {
  int x;
  int y;

  struct Point& operator+(const Point& rhs){ 
    x += rhs.x;
    y += rhs.y;
    return *this;
  }
  struct Point& operator++(){ 
    x++;
    y++;
    return *this;
  }
  struct Point& operator+=(const Point& rhs) {
    x += rhs.x; 
    y += rhs.y; 
    return *this;
  }
  struct Point& operator+=(const int& value) { 
    x += value;
    y += value;
    return *this;
  }
  struct Point operator()(int value) {
    return {value, value};
  }

  // Apply the same idea for
  // -, --, -=
  // *, *=
  // /, /=
  // etc.
};

```

### Unpack

```cpp
struct Packed {
  int x;
  char y;
  float z;
};

Packed p = /* ... */;

// access by reference
auto & [ x, y, z ] = p;
// access by move
auto && [ xx, yy, zz ] = p;
```

## Templates

```cpp
template <class T>
T DoSomething(T a, T b) {
 // ...
}
```

The definitions below will expand out the functions as needed from code.

```cpp
template<typename T>
T Add(T v) {
  return v;
}

template<typename T, typename... Ts>
T Add(T first, Ts... args) {
  return first + Add(args...);
}
```

## Time

[C++ Reference: Chrono](https://en.cppreference.com/w/cpp/chrono/system_clock)

```cpp
#include <chrono>

std::chrono::system_clock::time_point current = std::chrono::system_clock::now();
```

```cpp
#include <chrono>
#include <ctime>

std::chrono::system_clock::time_point now = std::chrono::system_clock::now();
std::time_t time_now = std::chrono::system_clock::to_time_t(now);
// or ...
std::time_t time_now = std::time(nullptr);

std::ctime(&time_now);                  // -> Tue Jul  7 12:00:01 2020  (UTC)
std::asctime(std::localtime(time_now)); // -> Tue Jul  7 08:00:01 2020  (Local)

// https://en.cppreference.com/w/cpp/chrono/c/strftime
char time_text[80]; // Arbitrary but made to cover any possible string length for time.
std::strftime(time_text, 80, "%Y-%m-%d", time_now);             // -> 2020-07-07
std::strftime(time_text, 80, "%Y-%m-%d %H:%M:%S", time_now);    // -> 2020-07-07 23:50:02
std::strftime(time_text, 80, "%Y-%m-%dT%H:%M:%S", time_now);    // -> 2020-07-07T23:50:02Z   (ISO 8601 UTC)
std::strftime(time_text, 80, "%Y-%m-%dT%H:%M:%S %Z", time_now); // -> 2020-07-07T23:50:02 +02
std::strftime(time_text, 80, "%A, %B %e, %Y", time_now);        // -> Monday, July 7, 2020
```

```cpp
#include <ctime>
#include <time.h>

std::time_t time_now = std::time(nullptr);
std::localtime(&time_now);
// or for GMT ...
std::gmtime(&time_now);

// https://en.cppreference.com/w/c/chrono/tm
//
// All below are numerics.
struct tm* time = std::localtime(&time_now);
time->tm_year;  // Year
time->tm_mon;   // Month
time->tm_mday;  // Day of Month
time->tm_wday;  // Day of Week
// ...
```

## Tuple

### Unpack

```cpp
auto tuple = std::make_tuple(1, 'a', 2.3);
const auto [a, b, c] = tuple;

// Same goes for arrays.
std::array<int, 3> arr{1, 2, 3};
auto [x, y ,z] = arr;
```

## Unique Pointer

```cpp
#include <memory>

auto my_object_ptr1 =
  std::make_unique(new MyObject(myobject_ctor_arg1, myobject_ctor_arg2));
auto my_object_ptr2 =
  std::make_unique<MyObject>(myobject_ctor_arg1, myobject_ctor_arg2);
```

```cpp
#include <memory>

auto int_ptr1 = std::make_unique<MyObject>();
int_ptr1.reset();   // Delete wrapped pointer.

auto int_ptr2 = std::make_unique<MyObject>();
int_ptr1.release(); // Release control of pointer.
```

## Vector

### Concat

```cpp
#include <vector>
std::vector<int> v1{1, 2, 3};
std::vector<int> v2{4, 5, 6};
v1.insert(v1.end(), v2.begin(), v2.end());
```

### Iterate

```cpp
#include <vector>
std::vector<int> v = {1, 2};
for(int i=0; i < v.size(); i++) {
  int x = v[i]
}
for(int x : v) {
  int y = x;
}
```

### Copy

```cpp
#include <vector>
std::vector<int> from = {1, 2};
std::vector<int> to(from.begin(), to.end());
```

### Appends

```cpp
#include <vector>
std::vector<int> v1 = {1, 2};
std::vector<int> v2 = {3, 4};
v1.insert(v1.end(), v2.begin(), v2.end());
```
