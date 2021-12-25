---
title: Writing a TEDS (IEEE 1451.4) parser.
date: '2011-08-17T12:59:00.000-07:00'
author: awalsh128
tags:
- ".NET"
- C#
- data acquisition
modified_time: '2012-10-03T13:43:56.066-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-204799628728171749
blogger_orig_url: https://awalsh128.blogspot.com/2011/08/writing-teds-ieee-14514-parser.html
---

I was tasked recently with writing a parser for TEDS bit stream data.
There is an [IEEE published
paper](http://standards.ieee.org/develop/regauth/tut/teds.pdf) with an
overview of the standard but it doesn\'t give any examples for
implementation. I was finally able to find a
[paper](http://standards.ieee.org/develop/regauth/tut/tdl.pdf) that gave
examples but still had trouble parsing the data. I finally realized
there is not only 2 selector bits after the basic TEDS block but
selector bits inside the standard template (2 in the case of template
25). Here are my main findings:\
\

-   It depends on the software interface to get the bit-stream, but bits
    usually start their indexing from left to right. If you are using a
    language that assumes right to left bit encoding, the stream indices
    will need to be reversed (eg. 01011000[2]{.Apple-style-span
    style="font-size: xx-small;"}[ ]{.Apple-style-span
    style="font-size: xx-small;"}translates
    to 00011010[2 ]{.Apple-style-span style="font-size: xx-small;"}=
    26[10]{.Apple-style-span style="font-size: xx-small;"}).
-   If you are using an little-endian architecture (eg. x86), then the
    byte order will need to be converted from big-endian (reverse the
    byte indices). It is big-endian since the standard is defined for
    networks and thus has a network byte order.
-   To calculate [ConRelRes ]{.Apple-style-span
    style="font-family: Arial, Helvetica, sans-serif;"}values, use the
    formula\...\
    [\<start\_value\> \* \[1 + 2 \* \<tolerance\>\] \^
    \<teds\_value\>]{.Apple-style-span
    style="font-family: 'Courier New', Courier, monospace;"}\
    In the published paper, you will see an entry like [ConRelRes(5E-7
    to 172, +- 0.15%)]{.Apple-style-span
    style="font-family: Arial, Helvetica, sans-serif;"} in the \"[Data
    Type (and Range)]{.Apple-style-span
    style="font-family: Arial, Helvetica, sans-serif;"}\" field. 5E-7 is
    the start value, 0.15 is the tolerance and the TEDS value is
    whatever value gets parsed from the bit stream.

\
Here are some helper functions to parse TEDS correctly on the .NET
platform (x86 systems).\

``` csharp
int _streamOffset = 0;

private System.Collections.BitArray _GetBits(System.Collections.BitArray bits, int length)
{
 System.Collections.BitArray result = new System.Collections.BitArray(length);
 for (int index = 0; index <= length - 1; index++) {
  result[index] = bits[_streamOffset + index];
 }
 return result;
}
private byte[] _GetBytes(System.Collections.BitArray bits)
{
 int byteCount = Convert.ToInt32(Math.Ceiling(bits.Count / 8));
 int padCount = (byteCount * 8) - bits.Count;
 byte[] bytes = new byte[byteCount];
 int byteIndex = 0;
 int bitIndex = 0;
 System.Collections.BitArray reverseBits = new System.Collections.BitArray(bits.Count + padCount);

 //byte align new bit array
 for (int index = 0; index <= padCount - 1; index++) {
  reverseBits[index] = false;
 }
 //reverse bits to read from right to left
 for (int index = 0; index <= bits.Length - 1; index++) {
  reverseBits[padCount + index] = bits[bits.Length - 1 - index];
 }

 //create byte array from byte aligned right to left bits
 for (int index = 0; index <= reverseBits.Count - 1; index++) {
  if ((reverseBits[index])) {
   bytes[byteIndex] = bytes[byteIndex] | Convert.ToByte(1 << (7 - bitIndex));
  }

  bitIndex += 1;
  if ((bitIndex == 8)) {
   bitIndex = 0;
   byteIndex += 1;
  }
 }

 return bytes;
}

private bool _GetBoolean(System.Collections.BitArray bits)
{
 bool result = bits[_streamOffset];
 _streamOffset += 1;
 return result;
}
private char _GetChar(System.Collections.BitArray bits, int length)
{
 char result = BitConverter.ToChar(new byte[] {
  0,
  _GetBytes(_GetBits(bits, length))[0]
 }, 0);
 _streamOffset += length;
 return result;
}
private int _GetInteger(System.Collections.BitArray bits, int length)
{
 byte[] intBytes = new byte[] {
  0,
  0,
  0,
  0
 };
 byte[] bytes = _GetBytes(_GetBits(bits, length));
 int result = 0;
 //pad out rest of bytes so it is int32 aligned and convert endianess
 for (int index = 0; index <= bytes.Length - 1; index++) {
  intBytes[index] = bytes[bytes.Length - 1 - index];
 }
 result = Convert.ToInt32(BitConverter.ToUInt32(intBytes, 0));
 _streamOffset += length;
 return result;
}
```
