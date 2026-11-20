---
title: Delete long file path names.
date: "2011-07-19T09:38:00.000-07:00"
tags:
  - System Administration
lastmod: "2011-07-19T09:41:59.162-07:00"
---

I made the stupid mistake of importing an Eclipse project into my workspace when
the [import location was from the workspace itself](https://bugs.eclipse.org/bugs/show_bug.cgi?id=279781). I
went to delete the recursive folder when I encountered an error that the file path name was too long to
delete.\
\
The [best manual solution](http://stackoverflow.com/questions/236533/how-do-you-automate-copying-file-with-path-too-deep-issues-in-windows)
that I found was to go as deep as possible in the recursive folder and then map it to a virtual drive.\
[\
]{.Apple-style-span style="font-family: 'Courier New', Courier, monospace;"}\
[subst x: c:\\recursiveFolder\\]{.Apple-style-span style="font-family: 'Courier New', Courier,
monospace;"}[recursiveFolder\\]{.Apple-style-span style="font-family: 'Courier New', Courier,
monospace;"}[recursiveFolder\\\...]{.Apple-style-span style="font-family: 'Courier New', Courier,
monospace;"}\
[\
]{.Apple-style-span style="font-family: inherit;"}\
[This can be quite an arduous process; I found myself creating up to 9 virtual drives. It eventually worked
though and I was able to delete the recursive folder.]{.Apple-style-span style="font-family: inherit;"}\
[\
]{.Apple-style-span style="font-family: inherit;"}\
[I also
[found a site](http://processors.wiki.ti.com/index.php/Recursive_Directory_Bug_in_Eclipse_Project_Import) with
a Perl script that deletes long file paths but haven\'t tested it myself.]{.Apple-style-span
style="font-family: inherit;"}
