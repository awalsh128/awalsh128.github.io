---
layout: posts
title: POCO not transforming into a POCO proxy.
date: '2011-11-07T14:19:00.000-08:00'
author: awalsh128
tags:
- ".NET"
- Entity Framework
- ADO.NET
modified_time: '2012-10-03T13:44:50.869-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-2935694402221043627
blogger_orig_url: https://awalsh128.blogspot.com/2011/11/poco-not-transforming-into-poco-proxy.html
---

A POCO (Plain Old CLR Object) must be transformed into a POCO proxy\
[MyNamespace.MyClass
-\>{System.Data.Entity.DynamicProxies.MyClass\_0A943C2FC37D33304CEB497A9210C754E3F553B50315F8E6F0F7A6FAF43777F2}]{.Apple-style-span
style="font-size: x-small;"})\
in order for features like lazy loading and change tracking to work.\
\
[MSDN has a great
article](http://msdn.microsoft.com/en-us/library/dd468057.aspx) that
explains how to prepare a POCO to be transformed into a proxy. If you
find that an object retrieved or attached to the context does not show
itself in the DynamicProxies namespace (eg. MyNamespace.MyClass instead
of \...DynamicProxies.MyClass), then you probably don\'t have a
compliant class. You may have noticed this already when hovering your
mouse cursor over an instance and seeing the runtime information on it.\
\
The distilled points are that your POCO must:

-   be public, not abstract and not sealed;
-   have a public or protected parameterless constructor;
-   have public overridable properties that are read/write if they are
    navigation properties;
-   and implement ICollection if they are a one-to-many navigation
    property.
