---
title: Entity Framework June 2011 CTP Bug
date: '2011-10-08T17:22:00.000-07:00'
author: awalsh128
tags:
- bugs
- Entity Framework
modified_time: '2012-08-01T16:24:28.064-07:00'
thumbnail: http://3.bp.blogspot.com/-0DqQltTWwFQ/TpDnAfXrk9I/AAAAAAAAAks/MprJzZRNH2Y/s72-c/entityfail.png
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-7398149697711595746
blogger_orig_url: https://awalsh128.blogspot.com/2011/10/entity-framework-june-2011-ctp-bug.html
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
