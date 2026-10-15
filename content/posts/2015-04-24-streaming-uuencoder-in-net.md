---
title: Streaming UUEncoder in .NET.
date: '2015-04-24T17:09:00.001-07:00'
author: awalsh128
tags:
- Encoding
modified_time: '2015-04-24T17:09:22.379-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-7225106951260315303
blogger_orig_url: https://awalsh128.blogspot.com/2015/04/streaming-uuencoder-in-net.html
---

### Flashback

The last time I used Unix-to-Unix format (AKA
[UUEncoding](http://en.wikipedia.org/wiki/Uuencoding)) was when
[USENET](http://en.wikipedia.org/wiki/Usenet) was still the big thing
and [Mosaic web
browser](http://en.wikipedia.org/wiki/Mosaic_%28web_browser%29) was just
coming out. That was until recently, when I had a requirement to encode
and decode this file type.

### Searching for an Implementation

Since [Base64](http://en.wikipedia.org/wiki/Base64) has largely replaced
this older format, it was hard to find a current implementation for the
.NET platform. I did run across [a port
of](http://geekswithblogs.net/kobush/archive/2005/12/18/63486.aspx)
[KDE\'s
kcodecs](http://websvn.kde.org/trunk/KDE/kdelibs/kdecore/kcodecs.cpp?view=markup&pathrev=486059).
Although the port wasn\'t a streaming solution in the context of
implementing the Stream class. Also, it allocated a lot of one item byte
arrays using the
[ReadByte](https://msdn.microsoft.com/en-us/library/system.io.stream.readbyte%28v=vs.110%29.aspx)
call for each character.

### Creating an Implementation

Originally I tried to create my own solution by implementing the .NET
[Encoder](https://msdn.microsoft.com/en-us/library/system.text.encoder%28v=vs.110%29.aspx)
class but the interface didn\'t fit the requirements of UUEncoding. For
example, the GetBytes call works on a per character basis whereas
UUEncoding takes 3 characters at a time. Also, a header and footer needs
to be written, and the encoded payload is segmented into lines prefixed
by encoded line lengths.

I ended up creating my own encoder class that was scoped to only handle
data line by line.

```cpp
public static class UUEncoder
{
  // Assumes the current position is at the start of a new line.
  public static byte[] DecodeLine(Stream buffer)
  {
    // ...
  }  
  public static byte[] EncodeLine(byte[] buffer)
  {
    // ...
  }
}
```

I then created encode and decode Stream classes that depended on the
encoder. Having the encoding and decoding happening in a Stream based
way was critical for my requirements since I was lazily evaluating the
data and wouldn\'t just read it all up front. This was important since
some of the files tended to be Gigabytes in size and an in-memory
solution would have created an unacceptable memory footprint. Along with
the nastiness that potentially comes with it like
[thrashing](http://en.wikipedia.org/wiki/Thrashing_%28computer_science%29).

### Using the Code

You can find my implementation, with tests, on Github
[here](https://github.com/awalsh128/Awalsh128.Text).

To decode any stream:

```cpp
using (Stream encodedStream = /* Any readable stream. */)
using (Stream decodedStream = /* Any writeable stream. */)
using (var decodeStream = new UUDecodeStream(encodedStream))
{ 
  decodeStream.CopyTo(decodedStream);
  // Decoded contents are now in decodedStream.
}
```

To encode any stream:

```cpp
bool unixLineEnding = // True if encoding with Unix line endings, otherwise false.
using (Stream encodedStream = /* Any readable stream. */)
using (Stream decodedStream = /* Any writeable stream. */)
using (var encodeStream = new UUEncodeStream(encodedStream, unixLineEnding))
{
  decodedStream.CopyTo(encodeStream);
  // Encoded contents are now in encodedStream.
}
```

### Note on Licensing

I published the code under version 2 (not 2.1) of the
[LGPL](http://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License)
since I took the bit twiddling and encoder maps from KDE\'s
implementation.

### More Resources & Reading

- [Github: Awalsh128.Text Library (contains UUEncoder implementation)](https://github.com/awalsh128/Awalsh128.Text)
- [GNU Lesser General Public License, version 2.1](https://www.gnu.org/licenses/lgpl-2.1.html)
