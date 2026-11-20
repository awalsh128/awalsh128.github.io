---
title: PCAP-NG reader for .NET.
date: "2013-04-10T18:46:00.000-07:00"
tags:
  - C#
  - .NET
lastmod: "2016-03-30T23:52:15.452-07:00"
---

### Introduction & Scope

The PCAP-NG file format is used to store network captured data used by great programs like
[Wireshark](http://www.wireshark.org/download.html). There are several API\'s available for both
[Linux](http://www.tcpdump.org/) and [Windows](http://www.winpcap.org/) but none that are ported to .NET. I
decided to [make one](https://github.com/awalsh128/PcapngFile/) for my own use in building a network traffic
replay agent.

This code demonstrates an approach to reading in PCAP-NG files. Most of the time I was concerned with the
[enhanced packet block type](http://www.winpcap.org/ntar/draft/PCAP-DumpFileFormat.html#sectionepb) since it
stored the TCP payloads I wanted to replay.

### Design Considerations

All block types derive from a common abstract class (BlockBase). This is useful when you need a collection of
blocks with different subtypes, as in the second code segments below. Internally, all classes populate
themselves from the underlying binary reader.

The reader class can be used to iterate over a single block type.

```csharp
var reader = new PcapngFile.Reader("test.pcapng");
foreach (var packet in reader.EnhancedPackets)
{
   byte[] payload = packet.Data;
}
```

\... or all of them, cast into their parent type.

```csharp
var blocks = new List<PcapngFile.BlockBase>();
while (reader.PeekStoreType() != PcapngFile.BlockType.None)
{
   blocks.Add(reader.ReadBlock());
}
```

### The Code and NuGet Package

Get access to the complete project [here](https://github.com/awalsh128/PcapngFile/) on my GitHub account. If
you have any suggestions or comments, feel free to leave a comment. I also have the assembly available via
NuGet [here](https://www.nuget.org/packages/PcapngFile/1.0.1).

### More Reading & Resources

- [WinPcap: PCAP-NG File Format](http://www.winpcap.org/ntar/draft/PCAP-DumpFileFormat.html)
- [Wireshark: Development - PcapNg](http://wiki.wireshark.org/Development/PcapNg)
- [Pcap.Net: Useful for reading transport payloads.](http://pcapdotnet.codeplex.com)
