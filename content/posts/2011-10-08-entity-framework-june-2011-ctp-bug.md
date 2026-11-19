---
title: Entity Framework June 2011 CTP Bug
date: '2011-10-08T17:22:00.000-07:00'
tags:
- .NET
- Entity Framework
- Databases
---

I recently installed the Entity Framework June 2011 CTP to preview the
enum support but ran into a bug along the way that reported an error
while processing the template.\
\

::: {.separator style="clear: both; text-align: center;"}
[![](http://3.bp.blogspot.com/-0DqQltTWwFQ/TpDnAfXrk9I/AAAAAAAAAks/MprJzZRNH2Y/s400/entityfail.png){width="400"
height="390"}](http://3.bp.blogspot.com/-0DqQltTWwFQ/TpDnAfXrk9I/AAAAAAAAAks/MprJzZRNH2Y/s1600/entityfail.png)
:::

\
I encountered this error while trying to run an Entity based project
using the \"Database & Model First\" paradigm. Uninstalling the preview
removed the problem. Not sure why this error occured since the preview
doesn\'t modify the
[assembly](http://msdn.microsoft.com/en-us/library/92t2ye13.aspx) it is
complaining about not finding an entry point in.
