##vmxtoolkit on OSX

labbuildr for osx is currently in an "ALPHA" state.

![github_osx_powershell_vmxtoolkit](https://cloud.githubusercontent.com/assets/8255007/17848963/c08f8588-6856-11e6-8714-82d50f96dc93.gif)

##Installation on OSX
to run vmxtoolkit on OSX, you need to have PowerShell for OSX installed  
see [PowerShell for OSX](https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#os-x-1011) for instructions
it is also recommended to install .NET Core for OSX from for details on installation of .NET Core LIBS see [.NET Core on MACOS](https://www.microsoft.com/net/core#macos)   
OSX port is currently only available via Git clone, no auto installer  
use
```Bash
git clone https://github.com/bottkars/vmxtoolkit --branch osx
```

##Usage
with vmxtookit on OSX, i will change the way the modules are loaded  
vmxtoolkit will use the OS specific User Homedirectory to browse vm´s.  

For OSX, this is $HOME/Documents/Virtual Machines.localized, for Windows $ENV:HOME/Virtual Machines
if you want to use another VM Directory as search base, load vmxtoolkit with -ArgumentList [Directory]
```Powershell
ipmo /Users/bottk/vmxtoolkit -ArgumentList "/Users/bottk/labbuildr.osx" -Force
```
this will set the $Global:vmxdir to /Users/bottk/labbuildr.osx  
when running Get-VMX without parameter, i will use this Directory as Base Search path for VM´s.


a list of tested Command is checked in [Issue 8](https://github.com/bottkars/vmxtoolkit/issues/8)
a list of OS relevant changes can be found here [Issue 9](https://github.com/bottkars/vmxtoolkit/issues/9)
