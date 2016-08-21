[CmdletBinding()]
param
()

################## Some Globals 
write-Host "trying to get os type ... "
if  ($OS = get-command C:\WINDOWS\system32\ntdll.dll)
	{
	Write-Host "running on Windows $OS.Version"
	$vmxtoolkit_type ="win_x86_64"
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
				}
			default
				{
				Write-host "Sorry, rome was not build in one day"
				Break
				}
			}
		}

	}

switch ($vmxtoolkit_type)
    {
    "osx"
        {
        $Global:vmxdir = split-path $PSScriptRoot
        $VMWAREpath = "/Applications/VMware Fusion.app"
        $Global:vmwarepath = $VMWAREpath
        #$Global:vmware = "$VMWAREpath\vmware.exe"
        $Global:vmrun = "/Applications/VMware Fusion.app/Contents/Library/vmrun"
        }
    "win_x86_64"
        {
        write-verbose "getting VMware Path from Registry"
        if (!(Test-Path "HKCR:\")) { $NewPSDrive = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT }
        if (!($VMWAREpath = Get-ItemProperty HKCR:\Applications\vmware.exe\shell\open\command -ErrorAction SilentlyContinue))
            {
	        Write-Error "VMware Binaries not found from registry"
            Break
            }
        $Global:vmxdir = split-path $PSScriptRoot
        $VMWAREpath = Split-Path $VMWAREpath.'(default)' -Parent
        $VMWAREpath = $VMWAREpath -replace '"', ''
        $Global:vmwarepath = $VMWAREpath
        $Global:vmware = "$VMWAREpath\vmware.exe"
        $Global:vmrun = "$VMWAREpath\vmrun.exe"
        $vmwarefileinfo = Get-ChildItem $Global:vmware
        # if (Test-Path "$env:appdata\vmware\inventory.vmls")
        #{
        $Global:vmxinventory = "$env:appdata\vmware\inventory.vmls"
        #}
        # End VMWare Path
        $Global:VMrunErrorCondition = @(
          "Waiting for Command execution Available",
          "Error",
          "Unable to connect to host.",
          "Error: Unable to connect to host.",
          "Error: The operation is not supported for the specified parameters",
          "Unable to connect to host. Error: The operation is not supported for the specified parameters",
          "Error: The operation is not supported for the specified parameters",
          "Error: vmrun was unable to start. Please make sure that vmrun is installed correctly and that you have enough resources available on your system.",
          "Error: The specified guest user must be logged in interactively to perform this operation",
          "Error: A file was not found",
          "Error: VMware Tools are not running in the guest",
          "Error: The VMware Tools are not running in the virtual machine" )
        $Global:vmwareversion = New-Object System.Version($vmwarefileinfo.VersionInfo.ProductMajorPart,$vmwarefileinfo.VersionInfo.ProductMinorPart,$vmwarefileinfo.VersionInfo.ProductBuildPart,$vmwarefileinfo.VersionInfo.ProductVersion.Split("-")[1])
        # $Global:vmwareMajor = $vmwarefileinfo.VersionInfo.ProductMajorPart
        # $Global:vmwareMinor = $vmwarefileinfo.VersionInfo.ProductMinorPart
        # $Global:vmwareBuild = $vmwarefileinfo.VersionInfo.ProductBuildPart
        # $Global:vmwareversion = $vmwarefileinfo.VersionInfo.ProductVersion
    }

    }

