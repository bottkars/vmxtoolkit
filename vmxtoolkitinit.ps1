﻿[CmdletBinding()]
param
(
$VMX_Path)

################## Some Globals
write-Host "trying to get os type ... "
if  (Test-Path C:\WINDOWS\system32\ntdll.dll)
	{
	$OS  = Get-Command C:\WINDOWS\system32\ntdll.dll
	Write-Host "running on Windows $($OS.Version)"
	$vmxtoolkit_type ="win_x86_64"
    write-verbose "getting VMware Path from Registry"
    if (!(Test-Path "HKCR:\")) { $NewPSDrive = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT }
    if (!($VMware_Path = Get-ItemProperty HKCR:\Applications\vmware.exe\shell\open\command -ErrorAction SilentlyContinue))
        {
	    Write-Error "VMware Binaries not found from registry"
        Break
        }
	$VMX_Basedir ='\Documents\Virtual Machines\'
    $VMware_Path = Split-Path $VMware_Path.'(default)' -Parent
    $VMware_Path = $VMware_Path -replace '"', ''
    $Global:vmwarepath = $VMware_Path
    $Global:vmware = "$VMware_Path\vmware.exe"
    $Global:vmrun = "$VMware_Path\vmrun.exe"
	$Global:vmware_vdiskmanager = Join-Path $VMware_Path 'vmware-vdiskmanager.exe'
	$Global:VMware_OVFTool = Join-Path $Global:vmwarepath 'OVFTool\ovftool.exe'
    $VMwarefileinfo = Get-ChildItem $Global:vmware
    $Global:vmxinventory = "$env:appdata\vmware\inventory.vmls"
    $Global:vmwareversion = New-Object System.Version($VMwarefileinfo.VersionInfo.ProductMajorPart,$VMwarefileinfo.VersionInfo.ProductMinorPart,$VMwarefileinfo.VersionInfo.ProductBuildPart,$VMwarefileinfo.VersionInfo.ProductVersion.Split("-")[1])
	}
else
	{
	if ($OS = uname)
		{
		Write-Host "found OS $OS"
		Switch ($OS)
			{
			"Darwin"
				{
				$vmxtoolkit_type = "OSX"
				$OS_Version = (uname -r)
				Write-Host "running $OS_Version"
				$VMX_BasePath = 'Documents/Virtual Machines.localized'
				$VMware_Path = "/Applications/VMware Fusion.app"
				$Global:vmwarepath = $VMware_Path
				$VMware_BIN_Path = Join-Path $VMware_Path  '/Contents/Library'
				$Global:VMware_vdiskmanager = Join-Path $VMware_BIN_Path "vmware-vdiskmanager"
				$Global:vmrun = Join-Path $VMware_BIN_Path "vmrun"
				$Global:VMware_OVFTool = Join-Path $VMware_Path 'ovftool'
				[version]$Global:vmwareversion = "12.0.0.0"
				}
			default
				{
				Write-host "Sorry, rome was not build in one day"
				Break
				}
			}
		}
	}
if (!$VMX_Path)
	{
	try
		{
		$Global:vmxdir = Join-Path $HOME $VMX_Basedir
		}
	catch
		{
		Write-Warning "could not evaluate default Virtula machines home, using $PSScriptRoot"
		$Global:vmxdir = $PSScriptRoot
		}
	}
else
	{
	$Global:vmxdir = $VMX_Path
	}
Write-Host -ForegroundColor Gray " ==>vmrun used from $Global:vmrun"
Write-Host -ForegroundColor Gray " ==>vmwarepath is $Global:vmwarepath"
Write-Host -ForegroundColor Gray " ==>default vmxdir is $Global:vmxdir"
Write-Host -ForegroundColor Gray " ==>running VMware Version Mode $Global:vmwareversion"
Write-Host -ForegroundColor Gray " ==>running OVFtool $Global:VMware_OVFTool"