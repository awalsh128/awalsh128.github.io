---
layout: posts
title: Bit specific builds in Visual Studio 2010.
date: '2012-04-23T11:41:00.001-07:00'
author: awalsh128
tags:
- Visual Studio
modified_time: '2012-08-01T16:21:00.286-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-5339534703502308981
blogger_orig_url: https://awalsh128.blogspot.com/2012/04/bit-specific-builds-in-visual-studio.html
---

Using Conditioned Tags
----------------------

The Visual Studio 2010 UI does not have options to handle conditional
references based on what kind of configuration and platform you are
running. For example, you may have a project reference that needs to
change depending on whether you are doing a 32 or 64 bit build.

Fortunately, the project file syntax does support conditional
references. I was able to find this out on [stack
overflow](http://stackoverflow.com/questions/1997268/how-to-reference-different-version-of-dll-with-msbuild).

In our case, we have our DLL\'s in source control under the project\'s
bin directory. For some reason I kept getting the 64-bit version of the
DLL and then found out it was because the Content tags also needed to be
conditioned.

Example
-------

Lets say you have a project (MyProject) with two DLL\'s, 32bit.dll and
64bit.dll, that are referenced by the project and kept under the bin
directory for the project:

-   MyProject\\bin\\x86\\32bit.dll
-   MyProject\\bin\\x64\\64bit.dll

You will need to hand edit the MyProject\\MyProject.vbproj file and add
these entries to it (or change it if they are already in there). The
first two entries are for the project references and the last two are
for their inclusion as a content item in the project.

``` {.prettyprint}
   <Reference Include="32bit" Condition="'$(Platform)' == 'x86'">
      <HintPath>bin\x86\32bit.dll</HintPath>
   </Reference>  
   <Reference Include="64bit" Condition="'$(Platform)' == 'x64'">
      <HintPath>bin\x64\64bit.dll</HintPath>
   </Reference>
   ...
   <ItemGroup>    
      <Content Include="bin\x86\32bit.dll" Condition="'$(Platform)' == 'x86'"/>
      <Content Include="bin\x64\64bit.dll" Condition="'$(Platform)' == 'x64'"/>
   </ItemGroup>
```

Now, whenever the platform is changed to x86, it will only use the x86
conditioned tags and likewise when changed to x64. This can also be
applied to other conditions too, check the links below for a complete
breakdown of the MSBuild schema and conditions.

-   [MSBuild Project File Schema
    Reference](http://msdn.microsoft.com/en-us/library/5dy88c2e.aspx)
-   [MSBuild
    Conditions](http://msdn.microsoft.com/en-us/library/7szfhaft.aspx)
