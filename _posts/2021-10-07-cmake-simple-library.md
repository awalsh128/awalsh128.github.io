---
title: CMake Simple Library Example
excerpt: "An example of a simple library using CMake."
last_modified_at: 2021-10-10 00:00:01 -0700
tags:
- CMake
toc: true
toc_icon: "columns"
---

## Motivation

There are already some tutorials and examples of setting up a CMake project already but I work very much ny example and then deep dive later. It's just how my brain works I guess. So let's skim the waters.

## Assumptions

This example uses the follow dev stack.

* CMake (obviously)
* C++ code.
* Catch2 testing framework ([GitHub](https://github.com/catchorg/Catch2)).

The file layout has subdirectory for source code and tests, each with their own CMake file and one at the root level.

```txt
CMakeLists.txt
tests
├── CMakeLists.txt
└── mylib_test.cpp
src
├── CMakeLists.txt
├── mylib.h
└── mylib.h
```

## Configuration

Here is the whole configuration in its respective files.

``/CMakeLists.txt``

```cmake
cmake_minimum_required(VERSION 3.16.3)

include(GNUInstallDirs)     # Make CMAKE_INSTALL_*DIR variables available.
set(CMAKE_CXX_STANDARD 20)  # Use standard C++20 for compilation.

project(mylib VERSION 0.1 DESCRIPTION "My library is a library that you can use as a library.")

# Make the src directory available for include lookup.
include_directories(src)

# Tell CMake to include the /src/CMakeLists.txt file in the build.
add_subdirectory(src)

# Must live in the top level file or tests won't be found.
include(CTest)  # Automatically invokes enable_testing()
# Tell CMake to include the /tests/CMakeLists.txt file in the build.
add_subdirectory(tests)
```

``/src/CMakeLists.txt``

```cmake
message(STATUS "Building and installing library.")

# Add library to build.
#
# STATIC rolls all code (including related includes) into a single compiled object.
# SHARED rolls only mylib code into a single compiled object.
#
# https://stackoverflow.com/questions/2649334/difference-between-static-and-shared-libraries
#
# If you are using a different type of library than STATIC, make sure to look into how the target properties and 
# install will be different. For example https://cmake.org/cmake/help/latest/command/install.html
#
add_library(mylib STATIC mylib.h mylib.cpp)

set_target_properties(mylib PROPERTIES
  VERSION ${PROJECT_VERSION}  # Already set in the parent CMakeLists.txt via 'project'.
  PUBLIC_HEADER mylib.h       # Pulic headers you intend other projects to include.
  CXX_STANDARD_REQUIRED 20)   # Enforce the C++20 standard to compile against.

install(TARGETS mylib
  # Used for STATIC library headers.
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT lib
  # Rolled code lives here.
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mylib COMPONENT dev)
```

``/tests/CMakeLists.txt``

```cmake
include(FetchContent)

message(STATUS "Building tests.")

# Pull in the Catch2 framework.
FetchContent_Declare(
  Catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG        v3.0.0-preview3)
FetchContent_MakeAvailable(Catch2)

# Most all test frameworks create a binary that then runs the tests.
# This is a simple expression of that and nothing special to tests themselves.
#
# In this framework, Catch2 provides a main function as executable entry point.
add_executable(query_tests mylib_test.cpp)

# Link the included libraries in for the tests.
target_link_libraries(my_tests PUBLIC Catch2 Catch2WithMain mylib)

add_test(NAME tests COMMAND query_tests)
```

## More Resources

Here are some more examples to help you along.

* [Dev Cafe: CMake Cookbook Examples](https://github.com/dev-cafe/cmake-cookbook)
* [GitHub: CMakeLists.txt Search](https://github.com/search?q=filename%3ACMakeLists.txt)
* CMake Documentation
  * [add_library](https://cmake.org/cmake/help/latest/command/add_library.html)
  * [add_test](https://cmake.org/cmake/help/latest/command/add_test.html)
  * [install](https://cmake.org/cmake/help/latest/command/install.html)
  * [set_target_properties](https://cmake.org/cmake/help/latest/command/set_target_properties.html)