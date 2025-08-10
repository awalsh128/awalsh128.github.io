---
title: 'EF 4.1 Code First: Many one-to-one properties for same class type on an object.'
date: '2011-10-05T15:00:00.000-07:00'
tags:
- Entity Framework
modified_time: '2012-08-01T16:27:10.131-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-3538605715683731614
blogger_orig_url: https://awalsh128.blogspot.com/2011/10/ef-41-code-first-many-one-to-one.html
---

I just started using the Entity Framework recently to employ persistence
for an already established code base. Initially I was using the \"Model
& Database First\" paradigm where a designer is used to layout the data
model. Although, this ended up being tedious since my
[POCO](http://en.wikipedia.org/wiki/Plain_Old_CLR_Object) instance had
to exactly match the [POCO
proxy](http://msdn.microsoft.com/en-us/library/dd456853.aspx) instance
in my model designer view. After upgrading to EF 4.1, I realized the
[\"Code First\"
paradigm](http://blogs.msdn.com/b/adonet/archive/2011/09/13/ef-code-first-fluent-api-with-vb-net.aspx)
was the way to go since I had to adapt the persistence model to my
already existing code.\
\
One of the earliest problems that I ran into was having more than one
property on a class that referenced the same class type. This example
was taken from [a great
site](http://weblogs.asp.net/manavi/archive/2011/03/28/associations-in-ef-4-1-code-first-part-2-complex-types.aspx)
that explored the different EF properties.\
[]{.Apple-style-span
style="background-color: #f8f8f8; color: #2e2e2e; font-family: 'Courier New', Courier, mono; font-size: 12px;"}\

```vbsharp
    public class Customer
    {
     public int Id { get; set; }
     public int Age { get; set; }
     public Address BillingAddress { get; set; }
     public Address DeliveryAddress { get; set; }
    }
```

\
Notice how both the [BillingAddress ]{.Apple-style-span
style="background-color: #f8f8f8; color: #2e2e2e; font-family: monospace; font-size: 12px; white-space: pre;"}and [DeliveryAddress
]{.Apple-style-span
style="background-color: #f8f8f8; color: #2e2e2e; font-family: monospace; font-size: 12px; white-space: pre;"}properties
references the same class type. I kept trying to establish two 1-to-1
relationships on the class but this caused a problem with cascading
deletes and foreign key constraints. I found [a
solution](http://weblogs.asp.net/manavi/archive/2011/05/01/associations-in-ef-4-1-code-first-part-5-one-to-one-foreign-key-associations.aspx) but
it still required exceptional behavior on the part of my context and the
database schema.\
\
The most elegant solution was to just treat both of the properties as
[complex
types](http://weblogs.asp.net/manavi/archive/2010/12/11/entity-association-mapping-with-code-first-part-1-one-to-one-associations.aspx).
The only thing I had to do was remove the [Id ]{.Apple-style-span
style="background-color: #f8f8f8; color: #2e2e2e; font-family: monospace; font-size: 12px; white-space: pre;"}property
from the properties\' class and the context took care of the rest. So
instead of two tables in the database (one for [Customer
]{.Apple-style-span
style="font-family: monospace; font-size: 12px; white-space: pre;"}and
the other for [Address]{.Apple-style-span
style="font-family: monospace; font-size: 12px; white-space: pre;"}),
there would be only one. Below is a layout of what the table would look
like.\
\

```vbsharp
Customer
{
 Id
 Age
 BillingAddress_City
 BillingAddress_Street
 BillingAddress_Zipcode
 DeliveryAddress_City
 DeliveryAddress_Street
 DeliveryAddress_Zipcode
}
```

\
\
