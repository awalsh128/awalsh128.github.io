---
layout: posts
title: Code Analysis for GitHub Projects
excerpt: "Integrate your GitHub projects with a code analysis tool."
last_modified_at: 2021-10-10 00:00:01 -0700
tags:
- Code Analysis
- GitHub
toc: true
toc_icon: "columns"
---

LGTM is a nice little integration for your GitHub projects that performs code analysis and alerts if any violations are found. And example of what an alert screen looks like on the LGTM site below (using my fluentcpp project as a demonstration).

![Example LGTM Alert Screen](/assets/img/2021-10-10-integrating-lgtm/alert_screen.png)

You will need to grant the application access to your repositories using their guide [Integration with GitHub Apps](https://lgtm.com/help/lgtm/github-apps-integration).

You can then setup badges on your project site that show the status of your code quality.

[![Code Grade](https://img.shields.io/lgtm/grade/cpp/g/awalsh128/fluentcpp.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/awalsh128/fluentcpp/context:cpp)
[![Code Alerts](https://img.shields.io/lgtm/alerts/g/awalsh128/fluentcpp.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/awalsh128/fluentcpp/alerts/)

If more customization is needed, an ``.lgtml.yml`` file can be created in the root of the repository per [their instructions](https://lgtm.com/help/lgtm/lgtm.yml-configuration-file). You can also download [their canonical template](https://lgtm.com/static/downloads/lgtm.template.yml) too to get started.

Here's [a search of GitHub](https://github.com/search?q=filename%3A.lgtm.yml&type=Code) to look at other example configuration files. For example in my project I needed a more recent version of CMake. This is what mine looks like so it is in the environment before LGTM performs its analysis.

```yml
extraction:
  cpp:
    after_prepare:
      - "mkdir custom_cmake"
      # Need later version of CMake than lgtm has.
      - "wget --quiet -O - https://cmake.org/files/v3.16/cmake-3.16.3-Linux-x86_64.tar.gz | tar --strip-components=1 -xz -C custom_cmake"
      - "export PATH=$(pwd)/custom_cmake/bin:${PATH}"
    index:
      build_command:
        - cd $LGTM_SRC
        - mkdir build; cd build
        - cmake .. -DCMAKE_BUILD_TYPE=RELWITHDEBINFO
        - make
```

Here's another [taken from GitHub](https://github.com/rafifm/olshop_ci4/blob/ce1b0095ab3e45e373f05d143374ad9a941054f4/public/themes/.lgtm.yml) that excludes specified directories from analysis.

```yml
path_classifiers:
  plugins:
    - plugins/

extraction:
  javascript:
    # https://lgtm.com/help/lgtm/javascript-extraction#customizing-index
    # The `index` step extracts information from the files in the codebase.
    index:
      # Specify a list of files and folders to exclude from extraction.
      exclude:
        - bower_components/
        - docs/assets/js/plugins/
        - plugins/
```

... or [from another repository](https://github.com/Johncrown56/News-App/blob/d7c3255d744036cf4d73655b2f3e3723cad3bdff/node_modules/regextras/lgtm.yml) more simply.

```yml
extraction:
  javascript:
    index:
      filters:
        - exclude: "dist"
```

Here's yet [another repository](https://github.com/CPTX1/Curl/blob/3027f06078f89232251eb1c921f6142894982ea1/curl-master/.lgtm.yml). This one disables CMake and sets the configuration options before build.

```yml
extraction:
  cpp:
    prepare:
      packages: # to avoid confusion with libopenafs-dev which also provides a des.h
        - libssl-dev
    after_prepare: # make sure lgtm.com doesn't use CMake (which generates and runs tests)
      - rm -f CMakeLists.txt
      - ./buildconf
    configure: # enable as many optional features as possible
      command: ./configure --enable-ares --with-libssh2 --with-gssapi --with-librtmp --with-libmetalink --with-libmetalink
```

I think you get the point. Just give the app permission, customize as needed with the ``.lgtml.yml`` and setup your cute badges.
