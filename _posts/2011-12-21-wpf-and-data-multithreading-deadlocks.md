---
layout: posts
title: WPF and data multithreading deadlocks.
date: '2011-12-21T10:38:00.000-08:00'
author: awalsh128
tags:
- multithreading
- WPF
modified_time: '2014-10-25T18:18:59.954-07:00'
thumbnail: http://3.bp.blogspot.com/-frk5kVor7dU/TvIrjJ_uxeI/AAAAAAAAAuA/8xswKGeSKg0/s72-c/uithread.png
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-4664014493722431844
blogger_orig_url: https://awalsh128.blogspot.com/2011/12/wpf-and-data-multithreading-deadlocks.html
---

WPF & Multithreading
--------------------

In designing applications, it may be advantageous to run data processing
methods on a separate thread from the UI. This allows greater
responsiveness in the application and takes advantage of concurrent
computation.

The cornerstone interface to any binding in WPF is
[INotifyPropertyChanged](http://msdn.microsoft.com/en-us/library/system.componentmodel.inotifypropertychanged.aspx),
which is implemented on a data structure\'s different properties.
Although this can be the source of deadlocks if the data structure is
being processed on a separate thread where locks are explicitly
implemented by the developer.

A deadlock could occur if some UI event was being triggered on a data
structure (eg. expanding a view, changing a text box entry) while the
data thread was processing it with an acquired lock. ~~Internally, the
[PropertyChanged](http://msdn.microsoft.com/en-us/library/system.componentmodel.inotifypropertychanged.propertychanged.aspx)
event will call a
[Dispatcher.Invoke](http://msdn.microsoft.com/en-us/library/system.windows.threading.dispatcher.invoke.aspx)
on the UI. Although the UI could be waiting for the lock to release on
that same property that the data thread already has, creating a cyclic
dependency or deadlock.~~

The call stack for the UI thread. Note the wait call.

::: {.separator style="clear: both; text-align: center;"}
[![](http://3.bp.blogspot.com/-frk5kVor7dU/TvIrjJ_uxeI/AAAAAAAAAuA/8xswKGeSKg0/s400/uithread.png)](http://3.bp.blogspot.com/-frk5kVor7dU/TvIrjJ_uxeI/AAAAAAAAAuA/8xswKGeSKg0/s1600/uithread.png)
:::

The call stack for the data thread.

::: {.separator style="clear: both; text-align: center;"}
[![](http://3.bp.blogspot.com/-_CPhXd1Z3VQ/TvIr0eLxl9I/AAAAAAAAAuM/mneSJNQZZvs/s400/workerthread.png)](http://3.bp.blogspot.com/-_CPhXd1Z3VQ/TvIr0eLxl9I/AAAAAAAAAuM/mneSJNQZZvs/s1600/workerthread.png)
:::

Deadlock Scenario
-----------------

As an example, suppose you have your standard WPF application UI thread
and a separate data thread. The data thread polls a time stamp from a
remote database and updates a class property called
`DataObject.Timestamp`{.inlinecode}, which raises the
`PropertyChanged`{.inlinecode} event. The property is also bound to a
text box in our WPF application window, which is made visible in the
window based on the user\'s preference (ie. collapsing and expanding a
view).

In our deadlock example, the data thread puts a lock on the
`DataObject.Timestamp`{.inlinecode} property while it updates it and
other data structures. While this is happening, the view is expanded,
causing the text box to start binding to the
`DataObject.Timestamp`{.inlinecode} property and wait for an acquire of
the lock that the data thread is holding. The data thread then sets the
`DataObject.Timestamp`{.inlinecode} property inside the critical region
code and the `PropertyChanged`{.inlinecode} event is raised. ~~This
causes the new time stamp value to be marshaled back onto the
`Dispatcher`{.inlinecode} with a blocking/synchronous
`Dispatcher.Invoke`{.inlinecode} call. Although the data thread now
deadlocks in the critical region, waiting for the UI
`Dispatcher.Invoke`{.inlinecode} to return, which is waiting on the data
thread to release the lock.~~

Solution
--------

To prevent the data thread\'s deadlock ~~critical region from blocking
on the `Dispatcher.Invoke`{.inlinecode}~~, override the
`OnPropertyChanged`{.inlinecode} method to marshal the value
asynchronously to the dispatcher.

``` csharp
protected override void OnPropertyChanged(string propertyName)
{
 Application.Current.Dispatcher.BeginInvoke(new Action(() => { base.OnPropertyChanged(propertyName); }));
}
```

This will ensure that the critical region doesn\'t block and the
property changes are still serviced by the dispatcher.
