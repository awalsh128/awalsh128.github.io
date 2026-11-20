---
title: Get Windows Service name from executable in PowerShell.
date: '2015-04-20T22:50:00.002-07:00'
tags:
- PowerShell
- System Administration
lastmod: '2015-04-20T22:53:20.126-07:00'
---

I was recently putting some PowerShell scripts together for deployment
and maintenance of software to our machine instances. One of the
requirements was to be able to discover the service name from a Windows
Service executable that uses
[ServiceInstaller](https://msdn.microsoft.com/en-us/library/system.serviceprocess.serviceinstaller%28v=vs.110%29.aspx).
I needed to be able to extract this value in a generic way in order to
query the service and stop it if running. Here is what I was able to put
together.

``` powershell
Function Get-WindowsServiceName([string]$exePath)
{
    $assembly = [System.Reflection.Assembly]::LoadFrom($exePath)
    $type = $assembly.GetTypes() | Where { $_.GetCustomAttributes([System.ComponentModel.RunInstallerAttribute], 0).Length -gt 0 } | Select -First 1
    $installer = [System.Configuration.Install.Installer][Activator]::CreateInstance($type)
    $serviceInstaller = [System.ServiceProcess.ServiceInstaller]$installer.Installers[0]
    $serviceInstaller.ServiceName
}
```

Note that this doesn\'t support multiple installers in a single
executable.
