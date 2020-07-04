---
layout: posts
title: Using Ubuntu 10.04 with SVN+HTTP.
date: '2011-07-13T09:38:00.000-07:00'
author: awalsh128
tags:
- SVN
- Apache
modified_time: '2012-08-01T16:28:39.199-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-2451860563261041626
blogger_orig_url: https://awalsh128.blogspot.com/2011/07/using-ubuntu-1004-with-svnhttp.html
---

I setup a server recently using Ubuntu 10.04. LAMP was easy to
configure, as was Subversion. Although making Subversion and Apache2
play nice together with DAV SVN was a nightmare. I followed the [guide
provided](https://help.ubuntu.com/10.04/serverguide/C/subversion.html) but
the website location just kept reprompting for my login.\
\
After hours of running in circles, I was able to find the solution. The
*Require valid-user* directive in
/etc/apache2/mods-available/dav\_svn.conf [required the Limit
directive](http://www.linuxquestions.org/questions/showthread.php?p=4413943#post4413943)
to be around it.\
\

> \<Limit GET POST PUT DELETE CONNECT OPTIONS PATCH PROPFIND PROPPATCH
> MKCOL COPY MOVE LOCK UNLOCK\>\
>    Require valid-user\
> \</Limit\>

The *LimitExcept* directive can also be used as long as the limitations
are specified.
