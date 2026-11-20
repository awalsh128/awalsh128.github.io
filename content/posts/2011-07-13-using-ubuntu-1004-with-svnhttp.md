---
title: Using Ubuntu 10.04 with SVN+HTTP.
date: "2011-07-13T09:38:00.000-07:00"
tags:
  - System Administration
---

I setup a server recently using Ubuntu 10.04. LAMP was easy to configure, as was Subversion. Although making
Subversion and Apache2 play nice together with DAV SVN was a nightmare. I followed the
[guide provided](https://help.ubuntu.com/10.04/serverguide/C/subversion.html) but the website location just
kept reprompting for my login.\
\
After hours of running in circles, I was able to find the solution. The _Require valid-user_ directive in
/etc/apache2/mods-available/dav\_svn.conf [required the Limit directive](http://www.linuxquestions.org/questions/showthread.php?p=4413943#post4413943)
to be around it.\
\

> \<Limit GET POST PUT DELETE CONNECT OPTIONS PATCH PROPFIND PROPPATCH MKCOL COPY MOVE LOCK UNLOCK\>\
>    Require valid-user\
> \</Limit\>

The _LimitExcept_ directive can also be used as long as the limitations are specified.
