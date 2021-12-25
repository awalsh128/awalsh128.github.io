---
title: IMAPI version 2 managed wrapper.
date: '2012-09-18T10:03:00.000-07:00'
author: awalsh128
tags:
- ".NET"
- IMAPI
- C#
modified_time: '2012-10-03T13:42:35.290-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-7163167550647933156
blogger_orig_url: https://awalsh128.blogspot.com/2012/09/imapi-version-2-managed-wrapper.html
---

### Introduction

Microsoft [introduced native image
mastering](http://msdn.microsoft.com/en-us/library/windows/desktop/aa366450(v=vs.85).aspx)
support in Vista, going forward. The library itself is not too complex
but the latest version of the [image mastering API
(IMAPI)](http://en.wikipedia.org/wiki/Image_Mastering_API) has some
quirks. This is well documented by [Eric
Haddan](http://www.codeproject.com/script/Membership/View.aspx?mid=208197)
in his
[article](http://www.codeproject.com/Articles/24544/Burning-and-Erasing-CD-DVD-Blu-ray-Media-with-C-an)
describing how to build an interop file and use it from .NET.

### Implementation

I wanted to take it a step further and provide a library wrapper that
was CLI compliant. The end result is a class that provides 3 methods,
called in order, to burn an image. The project can be found on [my
GitHub account](https://github.com/awalsh128/IMAPI2).

Properties
----------

-   **Media**: A read only property that populates after the LoadMedia
    call and reports what type of physical media is connected (eg. CD-R,
    DVD-R, DVD+RW, etc.).
-   **MediaStates**: A read only collection of states in which the media
    is under, that populates after the LoadMedia call (eg. is blank,
    overwriteable, unsupported).
-   **MediaCapacity**: A read only property that populates after the
    LoadMedia call and reports the size capacity of the media.
-   **Nodes**: A root list of file and directory nodes that are to be
    written to the media.
-   **Recorders**: A read only selectable collection. A recorder must be
    selected for the LoadRecorder call.
-   **VolumeLabel**: A property that sets the volume label of the media
    to be written to.

Methods
-------

-   **LoadRecorder**: Verifies a recorder is selected, loads the
    recording drive resources and verifies that it is working.
-   **LoadMedia**: Loads the media resource and verifies that it is
    valid for the recorder. An exception will occur if the media isn\'t
    supported (eg. closed session disc, no disc present).
-   **FormatMedia**: Formats the media of any previous data.
-   **WriteImage**: The final step to write your files to disc. This is
    a blocking call.

Events
------

-   **FormatEraseUpdate**: Reports progress of FormatMedia call.
-   **FormatWriteUpdate**: Reports progress of files being written to
    the media.
-   **ImageUpdate**: Reports progress of files being added to the media
    image.

### Caveats

I use this library for the simple single purpose of writing finalized
images to a blank CD. It has not been fully tested to accomodate all
media and recorder state scenarios; I haven\'t tried it yet with DVD\'s
or multi-session discs. If you would like to extend the library, feel
free to push some changes to [the GitHub
project](https://github.com/awalsh128/IMAPI2) and I will wrap them in.

I decided to leave the method calls as blocking (synchronous) since
there could be many different synchronization models that may use this
library. For my purposes, I used this in an WPF application that would
call the WriteImage method from a
[Task](http://msdn.microsoft.com/en-us/library/system.threading.tasks.task.aspx)
and then post back the progress events of the write using the
[Dispatcher](http://msdn.microsoft.com/en-us/library/system.windows.threading.dispatcher.aspx)
from my WPF window. Below is a code snippet demonstrating this.

``` csharp
private ImageMaster _burner;

...

private void _CreateCd()
{
 // files added to _burner and _burner.WriteImage called
}

private void _burner_FormatWriteUpdate(IMAPI2.ImageMaster sender, IMAPI2.FormatWriteUpdateEventArgs e)
{
 this.Dispatcher.Invoke(() => this.statusProgressBar.Value == (e.ElapsedTime / e.TotalTime) * 100);
}

private void CreateCdWindow_Loaded(object sender, System.Windows.RoutedEventArgs e)
{
 System.Threading.Tasks.Task.Factory.StartNew(_CreateCd);
}
```
