---
title: Using type converters for JSON.NET.
date: '2015-03-28T22:10:00.000-07:00'
author: awalsh128
tags: 
modified_time: '2015-03-28T23:52:45.190-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-2997275603564491104
blogger_orig_url: https://awalsh128.blogspot.com/2015/03/using-type-converters-for-jsonnet.html
---

### Motivation

I had these [flyweights](http://en.wikipedia.org/wiki/Flyweight_pattern)
that added a lot of overhead to the
[serialization](http://en.wikipedia.org/wiki/Serialization) process.
They weren\'t really needed in the serialized payload either. In fact, I
could recreate the flyweight in memory from just a single property on
the object.

``` csharp
public class FlyweightObject
{
   public string Key { get; private set; }
   public string AProperty { get; private set; }
   public string AnotherProperty { get; private set; }
   public string YetAnotherProperty { get; private set; }
   // ... Lots of properties.

   // Overridden GetHashCode and Equals methods to make equality by Key.
}
```

``` csharp
public class FlyweightObjectFactory
{
   public static FlyweightObjectFactory Instance { get; private set; }

   // Singleton initialization code.

   public FlyweightObject GetObject(string key)
   {
      // Get from dictionary, or create object and add to dictionary.
      // Return object from dictionary.
   }
}
```

Nothing out of the ordinary here. Although, these flyweights were also
used as keys in a dictionary I was serializing. This was a problem too
because [only scalars can be used when serializing dictionaries with
JSON.NET](http://www.newtonsoft.com/json/help/html/SerializationGuide.htm#Dictionarys).
It does mention that I can use a [type
converter](https://msdn.microsoft.com/en-us/library/system.componentmodel.typeconverter%28v=vs.110%29.aspx)
though.

### Serializing

Let focus on serializing this object to a
[scalar](http://en.wikipedia.org/wiki/Primitive_data_type) first. The
[JSON.NET serialization
guide](http://www.newtonsoft.com/json/help/html/SerializationGuide.htm)
mentions that I can override the
[`Object.ToString`](https://msdn.microsoft.com/en-us/library/system.object.tostring%28v=vs.110%29.aspx)
method. So let\'s do that.

``` csharp
public class FlyweightObject
{
   public string Key { get; private set; }
   public string AProperty { get; private set; }
   public string AnotherProperty { get; private set; }
   public string YetAnotherProperty { get; private set; }
   // ... Lots of properties.

   // Overridden GetHashCode and Equals methods to make equality by Key.

   public override string ToString()
   {
      return this.Key;
   }
}
```

I\'m done right? Who needs type converters? Well this doesn\'t help us
when I need to deserialize. This is where type converters come into
play.

### Implementing a Type Converter

First we have to provide the concrete implementation of our type
converter class for the flyweight.

``` csharp
internal class FlyweightObjectConverter
   : TypeConverter
{      
   /// <summary>
   /// Returns whether this converter can convert an object of the given type to the type of this converter, using the specified context.
   /// </summary>
   /// <returns>
   /// true if this converter can perform the conversion; otherwise, false.
   /// </returns>
   /// <param name="context">An  that provides a format context. </param>
   /// <param name="sourceType">A <see cref="T:System.Type"/> that represents the type you want to convert from. </param>
   public override bool CanConvertFrom(ITypeDescriptorContext context, Type sourceType)
   {
      return sourceType == typeof(string) || base.CanConvertFrom(context, sourceType);
   }

   /// <summary>
   /// Converts the given object to the type of this converter, using the specified context and culture information.
   /// </summary>
   /// <returns>
   /// An <see cref="T:System.Object"/> that represents the converted value.
   /// </returns>
   /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context. </param>
   /// <param name="culture">The <see cref="T:System.Globalization.CultureInfo"/> to use as the current culture. </param>
   /// <param name="value">The <see cref="T:System.Object"/> to convert. </param><exception cref="T:System.NotSupportedException">The conversion cannot be performed. </exception>
   public override object ConvertFrom(ITypeDescriptorContext context, CultureInfo culture, object value)
   {
      return FlyweightObjectFactory.Instance.GetObject((string)value);
   }
}
```

Then attribute the convertible class with the implementation.

``` csharp
[TypeConverter(typeof(FlyweightObjectConverter))]
public class FlyweightObject
{
   public string Key { get; private set; }
   public string AProperty { get; private set; }
   public string AnotherProperty { get; private set; }
   public string YetAnotherProperty { get; private set; }
   // ... Lots of properties.

   // Overridden GetHashCode and Equals methods to make equality by Key.
}
```

Good to go. Now I can deserialize the flyweights. The JSON.NET secret
sauce can be found in [the static method
`Newtonsoft.Json.Utilities.ConvertUtils.TryConvertInternal`](https://github.com/JamesNK/Newtonsoft.Json/blob/master/Src/Newtonsoft.Json/Utilities/ConvertUtils.cs).
This method is used by the internal reader class for its own
deserialization method and consequently for the final
Newtonsoft.Json.JsonSerializer class, which is the lynchpin for all the
serialization helper methods in the JSON.NET ecosystem.

### Considerations

Instead of overriding the `Object.ToString` method, I could implement
the `TypeConverter.CanConvertTo` and `TypeConverter.ConvertTo` methods.
It is really up to you. In my case, I already had the `Object.ToString`
method overridden since the key property uniquely identifies the object
without having to create an implicitly structured string (ie. comma
delimited properties as a single string; \"Prop1\|Prop2\|Prop3\").

If you only need a type conversion for JSON, you can also use
JSON.NET\'s own [custom type
converters](http://www.newtonsoft.com/json/help/html/CustomJsonConverter.htm).
Although this doesn\'t work in the case of dictionary keys.

Lastly, if you have a [complex
type](http://en.wikipedia.org/wiki/Composite_data_type) as your
dictionary key, you may want to consider just serializing it as a
collection and then deserializing it using a JSON.NET custom converter.

### More Reading & Resources

-   [MSDN: Type Conversion in the .NET
    Framework](https://msdn.microsoft.com/en-us/library/98bbex99%28v=vs.110%29.aspx)
-   [MSDN: How to: Implement a Type
    Converter](https://msdn.microsoft.com/en-us/library/ayybcxe5.aspx)
-   [JSON.NET: Add support for IReadOnlyList and
    IReadOnlyDictionary](https://json.codeplex.com/workitem/23872) -
    Provides `JsonConverter` implementations for read only collections.
