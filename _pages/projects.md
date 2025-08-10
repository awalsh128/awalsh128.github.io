---
permalink: /projects/
title: "My Projects"
excerpt: "My more popular projects that I have been maintaining."
last_modified_at: 2021-10-16T00:00:00-07:00
toc: true
---

## Fluent C++

Fluent C++ is a library that can be used to express information in a functional way that allows for easy auto-complete and shorter expressions.

* [Releases](https://github.com/awalsh128/fluentcpp/releases)
* [Source Code](https://github.com/awalsh128/fluentcpp)

```cpp
#include <fluentcpp/query.h>
#include <iostream>
#include <vector>

int main()
{
  std::vector<int> xs;
  for (int x = 0; x < 1000; x++) xs.push_back(x);

  std::vector<int> queried = fcpp::query(xs)
      .where(EXPR(x, x > 500))
      .shuffle()
      .skip(10)
      .select(EXPR(x, x % 10))
      .distinct();
}
```

## PCAP-NG File Reader

Reads PCAP Next Generation files and generates CLR objects from its data. Implemented according to the draft specification at <http://www.winpcap.org/ntar/draft/PCAP-DumpFileFormat.html>.

* [Nuget](https://www.nuget.org/packages/PcapngFile/)
* [Source Code](https://github.com/awalsh128/PcapngFile)

```csharp
using (var reader = new Reader("myfile.pcapng"))
{
   BlockBase block;
   while ((block = reader.ReadBlock()) != null)
   {
      // Act on received block. It's cast will be BlockBase 
      // but its true underlying type will be any of BlockBase's
      // children.
   }

   reader.Reset();

   // Which is equivalent to.
   foreach (var readBlock in reader.AllBlocks)
   {
      // ...
   }
}
```

## Github Actions: Cache APT Packages

This [Github action](https://docs.github.com/en/actions) allows caching of Advanced Package Tool (APT) package dependencies to improve workflow execution time instead of installing the packages on every run.

* [Marketplace](https://github.com/marketplace/actions/cache-apt-packages)
* [Source Code](https://github.com/awalsh128/cache-apt-pkgs-action)

```yml
name: Create Documentation
on: push
jobs:
  
  build_and_deploy_docs:
    runs-on: ubuntu-latest
    name: Build Doxygen documentation and deploy
    steps:
      - uses: actions/checkout@v2
      - uses: awalsh128/cache-apt-pkgs-action@v1
        with:
          packages: dia doxygen doxygen-doc doxygen-gui doxygen-latex graphviz mscgen
          version: 1.0

      - name: Build        
        run: |
          cmake -B ${{github.workspace}}/build -DCMAKE_BUILD_TYPE=${{env.BUILD_TYPE}}      
          cmake --build ${{github.workspace}}/build --config ${{env.BUILD_TYPE}}

      - name: Deploy
        uses: JamesIves/github-pages-deploy-action@4.1.5
        with:
          branch: gh-pages
          folder: ${{github.workspace}}/build/website
```
