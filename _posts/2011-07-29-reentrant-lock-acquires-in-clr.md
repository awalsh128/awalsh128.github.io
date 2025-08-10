---
title: Reentrant lock acquires in CLR.
date: '2011-07-29T10:41:00.000-07:00'
author: awalsh128
tags:
- CLR
- ".NET"
- multithreading
modified_time: '2012-10-03T13:44:29.505-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-2025164316266516224
blogger_orig_url: https://awalsh128.blogspot.com/2011/07/reentrant-lock-acquires-in-clr.html
---

I always like when a post gets to the point (especially after searching
in Google). In short, *[if you perform an operation that waits to
acquire a lock, the thread doesn\'t actually
stop](http://msdn.microsoft.com/en-us/library/ms741870.aspx)*.\
\
In concrete terms of .NET coding, if you call the
[WaitOne](http://msdn.microsoft.com/en-us/library/system.threading.waithandle.waitone.aspx) method
on a thread, it may still process events that the CLR deems \"high
priority\". This can be a big problem if the event handlers go into the
critical region you are trying to protect.\
\

``` csharp
int criticalRegion = 0;

private void criticalRegionWait() 
{
   AutoResetEvent are = new AutoResetEvent(false);
   Thread thread = new Thread(() => 
      { 
         criticalRegion = -1
         Debug.WriteLine(criticalRegion);
         are.Set();
      });
   thread.SetApartmentState(ApartmentState.STA);
   thread.IsBackground = true;
   thread.Start();
}

private void criticalRegionUpdateEvent(object sender, EventArgs e) 
{
   criticalRegion = 1;
}
```

In the above example, if there is a high priority event that has
[criticalRegionUpdateEvent ]{.Apple-style-span
style="font-family: 'Courier New', Courier, monospace;"}in its call path
a race condition is possible. While [criticalRegionWait
]{.Apple-style-span
style="font-family: 'Courier New', Courier, monospace;"}waits for the
thread to finish, the [criticalRegionUpdateEvent ]{.Apple-style-span
style="font-family: 'Courier New', Courier, monospace;"}has a chance of
setting [criticalRegion = 1]{.Apple-style-span
style="font-family: 'Courier New', Courier, monospace;"} so that
[WriteLine ]{.Apple-style-span
style="font-family: 'Courier New', Courier, monospace;"}ends up printing
1 instead of -1.
