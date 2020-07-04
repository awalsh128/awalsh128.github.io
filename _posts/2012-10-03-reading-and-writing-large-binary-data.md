---
layout: posts
title: Reading and writing large binary data in T-SQL and ADO.NET.
date: '2012-10-03T13:40:00.000-07:00'
author: awalsh128
tags:
- ".NET"
- C#
- raw text
- T-SQL
- ADO.NET
modified_time: '2012-10-03T13:42:20.332-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-4541742311286759577
blogger_orig_url: https://awalsh128.blogspot.com/2012/10/reading-and-writing-large-binary-data.html
---

### Introduction

In some cases, you may want to read/write binary data from/to your
relational database. This can be a problem when the data set size
exceeds the memory address size (eg. 32-bit processes) or the [managed
large object
heap](http://msdn.microsoft.com/en-us/magazine/cc534993.aspx) cannot
load it all without throwing an
[OutOfMemoryException](http://msdn.microsoft.com/en-us/library/system.outofmemoryexception.aspx).
In those cases, you will need to load the data into memory in chunks.
Fortunately, the [T-SQL](http://en.wikipedia.org/wiki/Transact-SQL)
syntax supports this operation.

### Latest Standard

The old standard for reading and writing raw text data was by using the
[UPDATETEXT](http://msdn.microsoft.com/en-us/library/ms189466.aspx),
[READTEXT](http://msdn.microsoft.com/en-us/library/ms187365.aspx) and
[TEXTPTR](http://msdn.microsoft.com/en-us/library/ms176068.aspx)
commands. Although, these are being obsoleted for the newer command
[SUBSTRING](http://msdn.microsoft.com/en-us/library/ms187748.aspx) and
the addition of the `.WRITE` argument to the
[UPDATE](http://msdn.microsoft.com/en-us/library/ms177523.aspx) command.
I found the newer syntax much easier to use and requiring less
parameters. Below is an example schema and implementation.

### Example Schema

For this example, we will use a very simple table setup with a primary
key and binary data column.

``` sql
CREATE TABLE [dbo].[DataTable] (
 [Id] [int] IDENTITY(1,1) NOT NULL,
 [Data] [varbinary](max) NOT NULL
)
```

### Example Code

The `Read` method simply provides an offset into the data and the size
of the chunk it wishes to read. The same applies for the `Write` method,
except that a data argument is also supplied.

``` csharp
private const int ReadChunkSize = 1 << 21;   // 2MB Chunks
private const int WriteChunkSize = 1 << 21;  // 2MB Chunks

...

public static void Read(string connectionString, string readPath)
{
    using (var connection = new SqlConnection(connectionString))
    {
        int offsetIndex = 0;
        var buffer = new byte[1];
        var offset = new SqlParameter("@Offset", SqlDbType.Int, 32);
        var command = new SqlCommand(@"SELECT SUBSTRING([Data], @Offset, " + ReadChunkSize + ") FROM [dbo].[DataTable] WHERE [Id] = 1", connection);

        command.Parameters.Add(offset);

        connection.Open();

        using (var stream = File.Create(readPath))
        {
            using (var writer = new BinaryWriter(stream))
            {
                while (buffer.Length > 0)
                {
                    offset.Value = offsetIndex;
                    buffer = (byte[])command.ExecuteScalar();
                    if (buffer.Length > 0)
                    {
                        writer.Write(buffer);
                        offsetIndex += ReadChunkSize;
                    }
                }
            }
        }
    }
}

public static void Write(string connectionString, string writePath)
{
    using (var connection = new SqlConnection(connectionString))
    {
        int offsetIndex = 0;
        var buffer = new byte[1];
        var offset = new SqlParameter("@Offset", SqlDbType.Int, 32);
        var data = new SqlParameter("@Data", SqlDbType.Binary, WriteChunkSize);
        var command = new SqlCommand(@"UPDATE [dbo].[DataTable] SET [Data] .WRITE(@Data, @Offset, " + WriteChunkSize + ") WHERE [Id] = 1", connection);

        command.Parameters.Add(offset);
        command.Parameters.Add(data);

        connection.Open();

        using (var stream = File.OpenRead(writePath))
        {
            using (var reader = new BinaryReader(stream))
            {
                while (buffer.Length > 0)
                {
                    buffer = reader.ReadBytes(WriteChunkSize);
                    if (buffer.Length > 0)
                    {
                        offset.Value = offsetIndex;
                        data.Value = buffer;
                        command.ExecuteNonQuery();
                        offsetIndex += WriteChunkSize;
                    }
                }
            }
        }
    }
}
```

### Performance Considerations

When benchmarking my code against the simple database schema, execution
time was drastically different if the data was already read into memory.
When a read was performed after a write, it took 2 seconds. A read
without a write beforehand took about 10 seconds. This is also the same
time that the write took before a read. The chunk size did not seems to
have any significant impact when adjusted between 512K and 4MB sizes.
Your results may vary though depending on your system\'s memory layout.

These time benchmarks are very informal and highly dependent on system
architecture, network latency and hardware specifications. Although, the
relative performance gain between the two benchmarks can be gleaned from
these tests.

A further performance gain would be to front load the data into memory
on a separate thread and process the loaded data into and out of the
database on another. This would require some tweaking and knowledge of
the system\'s memory constraints to ensure it doesn\'t become a
performance bottleneck. If properly done, a lot can be gained from not
having to block on I/O between every chunk read and write.
