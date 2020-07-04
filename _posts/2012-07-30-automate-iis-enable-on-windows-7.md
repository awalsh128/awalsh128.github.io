---
layout: posts
title: Automate IIS enable on Windows 7.
date: '2012-07-30T11:33:00.000-07:00'
author: awalsh128
tags:
- batch
- IIS
modified_time: '2012-07-30T11:33:50.594-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-6062967377848179277
blogger_orig_url: https://awalsh128.blogspot.com/2012/07/automate-iis-enable-on-windows-7.html
---

### Background

There are plenty of sites that will tell you how to enable IIS through
the Control Panel. Although, if you are tasked with enabling IIS
automatically (eg. for an installer), it can be a nightmare. This is
only really needed though in special cases where the installer has more
control over the hardware specifications. Determining an upgrade or
uninstall scenario with IIS can be very tough since you are not
installing your own software but rather enabling a feature of Windows.
With that in mind, we can propose a solution for automated enabling of
IIS.

### Requirements

Windows Editions
----------------

The [edition of Windows 7 for
IIS](http://technet.microsoft.com/en-us/library/cc753473.aspx) must be
either Ultimate or Professional if you plan on using ASP.NET. You can
try this on other editions, or even Vista, but your results may differ
since this is only scenario I have tested against. More information can
be found at the [IIS TechNet
site](http://technet.microsoft.com/en-us/library/ee692294(v=ws.10).aspx).

DISM Tool
---------

To enable IIS features through the command line,
[DISM](http://technet.microsoft.com/en-us/library/dd744256(v=ws.10).aspx)
can be used. This can be reliably found on Windows 7 but is inconsistent
on Vista, where the older [Package
Manager](http://technet.microsoft.com/en-us/library/cc749465(v=ws.10).aspx)
is used instead. This was one of the reasons I decided to constrain the
specification to Windows 7.

The first step in using DISM, is to find out which features need to be
enabled, in order for IIS to work completely. I ran across this [MSDN
blog
entry](http://blogs.msdn.com/b/habibh/archive/2009/08/14/how-to-install-iis-7-5-on-windows-7-using-the-command-line.aspx?Redirected=true)
that lists all the needed features. Next task is to script the DISM
commands.

### Scripting

Caveats
-------

Iterating over each feature and enabling it with DISM can be very time
consuming. The faster approach is to evaluate the enabled state of each
feature and turn them all on in one command. PowerShell can be used but
the presence of it and its needed modules can be inconsistent on Windows
7. I had to fall back on batch scripting, which is the part that can
cause nightmares due to its ugly syntax.

Arrays are need to store the enabled states of each feature and the
feature names themselves. In my case, I needed an array of pairs. I was
able to fake it using a [suggestion on Stack
Overflow](http://stackoverflow.com/questions/8039128/batch-script-in-dos-traverse-multiple-lists-pairwise).
Also, special syntax is needed to reference variables inside a loop that
are scoped outside the loop.

Last, but not least, remember to register the ASP.NET framework version
being used with IIS. This will need to be done once IIS is enabled
(reboot is required). Adjust the framework bitness and version below
according to the one you are using.

``` bash
[WindowsFolder]\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -i
```

The Code
--------

The following batch script will discover which features are disabled,
concatenate them into the enable command and then execute. You may need
to replace
[SysNative](http://msdn.microsoft.com/en-us/library/windows/desktop/aa384187(v=vs.85).aspx)
with system32 or the Windows system folder being used by your target
system if this is being ran outside the installer.

``` bash
setlocal enableextensions enabledelayedexpansion
set features=IIS-ApplicationDevelopment IIS-ASPNET IIS-CommonHttpFeatures IIS-HostableWebCore IIS-HttpCompressionDynamic IIS-HttpCompressionStatic IIS-HttpErrors IIS-HttpLogging IIS-HttpRedirect IIS-HttpTracing IIS-Metabase IIS-NetFxExtensibility IIS-Performance IIS-StaticContent IIS-URLAuthorization IIS-WebServerRole WAS-ConfigurationAPI WAS-NetFxEnvironment WAS-ProcessModel WAS-WindowsActivationService
set dism_params=

set n=0
for %%f in (%features%) do (
 set /a n+=1
 set dism_params=!dism_params! /FeatureName:%%f
 set features[!n!]=%%f
)
set n=0
for /f "tokens=3*" %%i in ('%WINDIR%\SysNative\Dism.exe /Online /Get-FeatureInfo %dism_params% ^| findstr /b /r "^State : "') do (
 set /a n+=1
 set states[!n!]=%%i
)

set dism_params=
for /l %%i in (1,1,%n%) do (
 if "!states[%%i]!" == "Disabled" set dism_params=!dism_params! /FeatureName:!features[%%i]!
)

if "%dism_params%" neq "" %WINDIR%\SysNative\Dism.exe /Online /Enable-Feature %dism_params%
```
