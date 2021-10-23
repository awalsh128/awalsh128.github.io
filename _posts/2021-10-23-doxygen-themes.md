---
layout: posts
title: Doxygen Themes
excerpt: "Customizable and modernized Doxygen themes."
last_modified_at: 2021-10-23 00:00:01 -0700
tags:
- Bootstrap
- Doxygen
toc: true
toc_icon: "columns"
---

I just released a new project on GitHub called [doxygen-themes](https://github.com/awalsh128/doxygen-themes) which allows users to customize Doxygen styling and colors using some example templates, including a stylesheet boiled down to a few color variables.

[Contributions](https://github.com/awalsh128/doxygen-themes/CONTRIBUTING.md) are definitely welcome. For the lazy, here is the README.md below.

Some sample Doxygen themes using Bootstrap 5 with different approaches to CSS use. Not all of the HTML is Bootstrap though, just the header and footer with Bootstrap like coloring applied to the body elements.

## Documentation

This project is a demonstration of possible approaches to theming Doxygen generated websites. Frameworks other than Bootstrap can be used, this is just an example of what is possible.

* Applied directly.
* Root variables applied.
* Simple color palette propagated.

## Pre-requisites

* CMake - Build the project and create the website.
* Doxygen - Create the website documentation.

## Components

All components use CDN links to keep project file overhead low.

* Bootstrap - Styles the header and footer. Also provides the primary colors for the Doxygen classes.
* Font Awesome - Header icons.
* jQuery - Required by Bootstrap and used for the custom palette picker.

## Sample CSS

Below is the CSS used for the Neon Pink theme.

```css
:root {
  --color-body: #bda9a9;
  --color-hyperlink: #ffffff;
  --color-title-background: #8a1253;
  --color-title-text: #ffffff;
  --color-footer-header-background: #c51350;
  --color-footer-header-text: #ffffff;
  --color-section-header-background: #e8751a;
  --color-section-header-text: #ffffff;
  --color-section-subheader-background: #fda403;
  --color-section-subheader-text: #ffffff;
  --color-section-text: #ffffff;
  --color-section-background: #bd9a9a;
}
```

Notice how there is a lot of ``#ffffff`` in there. This could probably be further simplified.

### Future Ideas

There are a lot of CSS features [that can be found](https://developer.mozilla.org/en-US/docs/Web/CSS). Some ways to simplify the palette even more.

* [Filter Functions](https://developer.mozilla.org/en-US/docs/Web/CSS/filter-function) - Allows for different affects and interesting functions like [brightness](https://developer.mozilla.org/en-US/docs/Web/CSS/filter-function/brightness()).
* [HSL Scheme](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/hsl()) - Makes darkening and lightening easier.
* [Arithmetic](https://developer.mozilla.org/en-US/docs/Web/CSS/calc()) - Useful for modifying color values.
