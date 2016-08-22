[CmdletBinding()]
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
    if (!($VMWAREpath = Get-ItemProperty HKCR:\Applications\vmware.exe\shell\open\command -ErrorAction SilentlyContinue))
        {
	    Write-Error "VMware Binaries not found from registry"
        Break
        }
	$VMX_Basedir ='\Documents\Virtual Machines\'
    $VMWAREpath = Split-Path $VMWAREpath.'(default)' -Parent
    $VMWAREpath = $VMWAREpath -replace '"', ''
    $Global:vmwarepath = $VMWAREpath
    $Global:vmware = "$VMWAREpath\vmware.exe"
    $Global:vmrun = "$VMWAREpath\vmrun.exe"
	$Global:VMware_OVFTool = Join-Path $Global:vmwarepath 'OVFTool\ovftool.exe'
    $vmwarefileinfo = Get-ChildItem $Global:vmware
    $Global:vmxinventory = "$env:appdata\vmware\inventory.vmls"
    $Global:vmwareversion = New-Object System.Version($vmwarefileinfo.VersionInfo.ProductMajorPart,$vmwarefileinfo.VersionInfo.ProductMinorPart,$vmwarefileinfo.VersionInfo.ProductBuildPart,$vmwarefileinfo.VersionInfo.ProductVersion.Split("-")[1])
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
				$VMWAREpath = "/Applications/VMware Fusion.app"
				$Global:vmwarepath = $VMWAREpath
				$Global:vmrun = Join-Path $VMWAREpath "/Contents/Library/vmrun"
				[version]$Global:vmwareversion = "12.0.0.0"
				$VMX_Basedir = 'Documents/Virtual Machines.localized'
				try
					{
					$Global:VMware_OVFTool = Join-Path $VMWAREpath '/Contents/Library/VMware OVF Tool/ovftool'
					}
				catch
					{
					Write-Warning "could not evaluate OVFtool"
					}
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

	# 				$Global:vmxdir = split-path $PSScriptRoot

Write-Host -ForegroundColor Gray " ==>vmrun used from $Global:vmrun"
Write-Host -ForegroundColor Gray " ==>vmwarepath is $Global:vmwarepath"
Write-Host -ForegroundColor Gray " ==>default vmxdir is $Global:vmxdir"
Write-Host -ForegroundColor Gray " ==>running VMware Version Mode $Global:vmwareversion"
Write-Host -ForegroundColor Gray " ==>running OVFtool $Global:VMware_OVFTool"


