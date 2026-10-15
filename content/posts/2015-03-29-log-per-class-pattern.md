---
title: Log per class pattern.
date: '2015-03-29T14:12:00.002-07:00'
author: awalsh128
tags: 
modified_time: '2015-04-20T22:36:30.261-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-5920472353607306682
blogger_orig_url: https://awalsh128.blogspot.com/2015/03/log-per-class-pattern.html
---

### Rookie Moves

Awhile ago, I had originally created a single logger for each service
and shared it statically across the application.

``` csharp
public static class Log
{
  private readonly static Lazy<Log> instance = new Lazy<Log>(() => new Log(), true);
  public static Log Instance
  {
    get { return instance.Value; }
  }
}
```

It always had felt strange doing this since it violated
[encapsulation](http://en.wikipedia.org/wiki/Encapsulation_%28object-oriented_programming%29).
I was referencing a static instance inside my objects without ensuring
the existence of the log instance itself, while also making assumptions
about the instance\'s state. Essentially reaching outside the class
every time to the
[singleton](http://en.wikipedia.org/wiki/Singleton_pattern), which is a
global state instance in my case.

### Best Practices

As I researched more on best practices with logging, logger per class
appeared to be the best pattern since it offered the most fine grain
control with respect to filtering and configuration.

When using logging in your class, you should separate the concern of how
the log gets created from the use of the log. This can be achieved by
having a factory accessor.

``` csharp
public class Log
{
  // Set your factory property to the actual log implementation you wish to use.
  public static Func<Type, Log> Factory { get; set; }

  // Instance based properties and methods.
}
```

You can also use the [abstract factory
pattern](http://en.wikipedia.org/wiki/Abstract_factory_pattern) if you
have to wrap your logging implementations.

``` csharp
public abstract class LogBase
{
  // Set your factory property to the actual log implementation you wish to use.
  public static Func<Type, LogBase> Factory { get; set; }

  // Abstract properties and methods.
}
```

Then just call the factory by passing in the class type it is for.

``` csharp
public class SomeObject
{
  private static readonly LogBase log = Log.Factory(typeof(SomeObject));
}
```

### The Difference

It may not seem like much of a change but subtle differences are
happening:

-   Calling class can now communicate it\'s state to the log\'s
    creation.
-   Log creation is no longer the responsibility, implicitly or
    otherwise, of the class.

In my case, this was very liberating since we had several log
implementations in our large codebase. I no longer needed to worry about
which log implementation was being used by messing with the singleton
construction, and could leverage filtering when I need to isolate a
single component or service that was causing trouble. Something that I
couldn\'t do before.

### More Reading & Resources

-   [C&C Inc: Logging Best
    Practices](http://c2.com/cgi/wiki?LoggingBestPractices)
-   [beefycode: Log4Net Recommended Practices pt 1: Your
    Code](http://www.beefycode.com/post/Log4Net-Recommended-Practices-pt-1-Your-Code.aspx)
-   [JayWay: A nice, basic log4net
    setup](http://www.jayway.com/2011/06/13/a-nice-basic-log4net-setup/)
-   [Stack Overflow: Why do loggers recommend using a logger per
    class?](http://stackoverflow.com/questions/3143929/why-do-loggers-recommend-using-a-logger-per-class)
-   [Stack Overflow: log4net: Configure to ignore messages from a
    specific
    class](http://stackoverflow.com/questions/5504148/log4net-configure-to-ignore-messages-from-a-specific-class)
-   [Rolf Engelhard: Logging Anti-Patterns, Part
    I](http://rolf-engelhard.de/2013/03/logging-anti-patterns-part-i/)
