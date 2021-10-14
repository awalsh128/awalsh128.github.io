---
layout: posts
title: GitHub Actions - Cache APT Packages v1 Released
excerpt: "An example of a simple library using CMake."
last_modified_at: 2021-10-10 00:00:01 -0700
tags:
- GitHub
toc: true
toc_icon: "columns"
---

I created a GitHub action [awalsh128/cache-apt-packages](https://github.com/marketplace/actions/cache-apt-packages) that allows caching of Advanced Package Tool (APT) package dependencies to improve workflow execution time instead of installing the packages on every run.

Here is an example using it to cache Doxygen dependencies.

```yaml
name: Create Documentation
on: push
jobs:

  build_and_deploy_docs:
    runs-on: ubuntu-latest
    name: Build Doxygen documentation and deploy
    steps:
      - uses: actions/checkout@v2
      - uses: awalsh128/cache-apt-pkgs-action-action@v1
        with:
          packages: dia doxygen doxygen-doc doxygen-gui doxygen-latex graphviz mscgen

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

This action is a composition of [actions/cache](https://github.com/actions/cache/README.md) and the `apt` utility. For more information, see [the repository README on GitHub](https://github.com/awalsh128/cache-apt-pkgs-action#readme).
