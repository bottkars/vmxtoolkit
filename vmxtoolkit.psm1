<#	
	.SYNOPSIS
	Get-VMwareversion
	.DESCRIPTION
		Displays version Information on installed VMware version
	.EXAMPLE
		PS C:\> Get-VMwareversion
	.NOTES
		requires VMXtoolkit loaded
#>


function Get-yesno
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://labbuildr.com/',
                  ConfirmImpact='Medium')]
    Param
    (
$title = "Delete Files",
$message = "Do you want to delete the remaining files in the folder?",
$Yestext = "Yestext",
$Notext = "notext"
    )
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","$Yestext"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","$Notext"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
return ($result)
}



function Get-VMwareVersion
{
	[CmdletBinding(HelpUri = "http://labbuildr.bottnet.de/modules/get-vmwareversion/")]
	param ()
begin {}
process {
    }
end {
    Write-Output $vmwareversion
    }
} 

function Get-yesnoabort
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://labbuildr.com/',
                  ConfirmImpact='Medium')]
Param
    (
    $title = "Delete Files",
    $message = "Do you want to delete the remaining files in the folder?",
    $Yestext = "Yes",
    $Notext = "No",
    $AbortText = "Abort"
    )
$yes = New-Object System.Management.Automation.Host.ChoiceDescription ("&Yes","$Yestext")
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","$Notext"
$abort = New-Object System.Management.Automation.Host.ChoiceDescription "&Abort","$Aborttext"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $Abort )
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
return ($result)
}

<#	
	.SYNOPSIS
	Get-VMXProcessesInGuest
	
	.DESCRIPTION
		Displays version Information on installed VMware version
	
	.EXAMPLE
		PS C:\> Get-VMwareversion
	
	.NOTES
		requires VMXtoolkit loaded
#>
function Get-VMXProcessesInGuest
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
    [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
    [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword
    )
begin {
    }
process {
    
    $Processlist = .$vmrun -gu $Guestuser -gp $Guestpassword listprocessesinguest  $config
    $Processlist = $Processlist -notmatch "Process list:"
    foreach ($Process in $Processlist)
        {
        $Process = $Process.replace("pid=","")
        $Process = $Process.replace("owner=","")
        $Process = $Process.replace("cmd=","")
        $Process = $Process.split(', ')
        $Object = New-Object -TypeName psobject
        $Object | Add-Member -MemberType NoteProperty -Name PID -Value $Process[0]
        $Object | Add-Member -MemberType NoteProperty -Name USER -Value $Process[2]
        $Object | Add-Member -MemberType NoteProperty -Name Process -Value $Process[4]
        Write-Output $Object
        }


    }
end {
    
    }
}

function Get-VMXHWVersion
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/get-VMXHWVersion/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "HWversion"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = "virtualHW.version"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value "HWVersion" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.HWVersion
		Write-Output $Object
	}
	end { }

}


function Set-VMXDisconnectIDE
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$config

	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{}
			"2"
			{}
		}
		$VMXConfig = Get-VMXConfig -config $config
        $VMXConfig = $VMXConfig | where {$_ -NotMatch "ide0:0.startConnected"}
        Write-Verbose -Message "Disabling IDE0"
		$VMXConfig += 'ide0:0.startConnected = "FALSE"'
        $VMXConfig | Set-Content -Path $config
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name IDE0:0 -Value disabled

		Write-Output $Object
	}
	end { }

}#Set-VMXDisconnectIDE


function Set-VMXIDECDrom
{
	[CmdletBinding(DefaultParametersetName = "file",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
	[Parameter(ParameterSetName = "file", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]
	[Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "file", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
	$config,
	[Parameter(ParameterSetName = "file", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
	[ValidateSet('0','1')]$IDEcontroller,
	[Parameter(ParameterSetName = "file", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
	[ValidateSet('0','1')]$IDElun,
	[Parameter(ParameterSetName = "file", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
	$ISOfile
	)
	begin
	{
	}
	process
		{
		$VMXConfig = Get-VMXConfig -config $config
		$IDEdevice = "ide$($IDEcontroller):$($IDElun)"
        $VMXConfig = $VMXConfig | where {$_ -NotMatch $IDEdevice}
        Write-Host -ForegroundColor Gray " ==>configuring $IDEdevice"		
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		switch ($PsCmdlet.ParameterSetName)
		{
			"file"
			{
			$VMXConfig += $IDEdevice +'.startConnected = "TRUE"'
			$VMXConfig += $IDEdevice +'.present = "TRUE"'
			$VMXConfig += $IDEdevice +'.fileName = "'+$ISOfile+'"'
			$VMXConfig += $IDEdevice +'.deviceType = "cdrom-image"'
			$object | Add-Member -MemberType NoteProperty -Name "$($IDEdevice).present" -Value True
			$object | Add-Member -MemberType NoteProperty -Name "$($IDEdevice).startconnected" -Value True
			$object | Add-Member -MemberType NoteProperty -Name "$($IDEdevice).type" -Value file
			$object | Add-Member -MemberType NoteProperty -Name "$($IDEdevice).file" -Value $ISOfile
			}
			"raw"
			{}
		}

        $VMXConfig | Set-Content -Path $config
		Write-Output $Object
	}
	end { }

}#Set-VMXDisconnectIDE


#$Addcontent += 'annotation = "This is node '+$Nodename+' for domain '+$Domainname+'|0D|0A built on '+(Get-Date -Format "MM-dd-yyyy_hh-mm")+'|0D|0A using labbuildr by @Hyperv_Guy|0D|0A Adminpasswords: Password123! |0D|0A Userpasswords: Welcome1"'

function Set-VMXAnnotation
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "2", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$Line1,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$Line2,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$Line3,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$Line4,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$Line5,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][switch]$builddate
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{}
			"2"
			{}
		}

        if ((get-vmx -Path $config).state -eq "stopped" )
            {
		    $VMXConfig = Get-VMXConfig -config $config
            $VMXConfig = $VMXConfig | where {$_ -NotMatch "annotation"}
            Write-Verbose -Message "setting Annotation"
            $date = get-date
            if ($builddate.IsPresent)
                {
                $Line0 = "Builddate: $date"
                }
            else
                {
                $Line0 ="EditDate: $date"
                }
		    $VMXConfig += 'annotation = "'+"$Line0|0D|0A"+"$Line1|0D|0A"+"$Line2|0D|0A"+"$Line3|0D|0A"+"$Line4|0D|0A"+"$Line5|0D|0A"+'"'
            $VMXConfig | Set-Content -Path $config
		    $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		    $object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		    $object | Add-Member -MemberType NoteProperty -Name Line0 -Value $Line0
		    $object | Add-Member -MemberType NoteProperty -Name Line1 -Value $Line1
		    $object | Add-Member -MemberType NoteProperty -Name Line2 -Value $Line2
		    $object | Add-Member -MemberType NoteProperty -Name Line3 -Value $Line3
		    $object | Add-Member -MemberType NoteProperty -Name Line4 -Value $Line4
		    $object | Add-Member -MemberType NoteProperty -Name Line5 -Value $Line5
		    Write-Output $Object
                }
            else
                {
            Write-Warning "VM must be in stopped state"
            }
	    }
	    end 
        {
        }

}#Set-annotatio


function Get-VMXToolsState
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$config

	)
	begin
	{

	}
	process
	{
		
        if ($vmwareversion.major -gt 9)
        {

        switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{}
			"2"
			{}
		}
		Write-Verbose -Message "getting Toolsstate from $config"
		$cmdresult = .$vmrun checkToolsState $config
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name State -Value $cmdresult

		Write-Output $Object
        }
        else
            {
             Write-Warning "VMware Workstation 9 or less does not support the check of Tools State. Recommended Action: Upgrade to VMware 10 greater"
             }
	}
	end { }

}#end get-VMXToolState

function Get-VMXConfigVersion
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXConfigVersion/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "ConfigVersion"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = "config.version"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value "Config" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.config
		Write-Output $Object
	}
	end { }

}#end get-vmxConfigVersion

<#	
	.SYNOPSIS
	Resize-VMXDiskfile
	
	.DESCRIPTION
		Shrinks the VMS Disk File
	
	.EXAMPLE
		get-vmx test | get-vmxscsidisk | Resize-VMXDiskfile
	
	.NOTES
		requires VMXtoolkit loaded
#>
function Resize-VMXDiskfile
{
	[CmdletBinding(DefaultParametersetName = "1",HelpUri = "http://labbuildr.bottnet.de/modules")]
	param (

	[Parameter(ParameterSetName = "1", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$DiskPath,
    [Parameter(ParameterSetName = "1", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$Disk,
    [Parameter(ParameterSetName = "2", Mandatory = $True, ValueFromPipelineByPropertyName = $false)]$Diskfile

	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{
            $Diskfile = Join-Path $DiskPath $Disk
            }
            default
            {}

		}
        Write-Warning "Shrinking $Diskfile"
	    & $Global:vmware_vdiskmanager -k $Diskfile
        Write-Verbose "Exitcode: $LASTEXITCODE"
		
	}
	end { }
}

<#	
	.SYNOPSIS
	Optimize-VMXDisk
	
	.DESCRIPTION
		Shrinks the VMS Disk File
	
	.EXAMPLE
		get-vmx test | get-vmxscsidisk | Optimize-VMXDisk
	
	.NOTES
		requires VMXtoolkit loaded
#>
function Optimize-VMXDisk
{
	[CmdletBinding(DefaultParametersetName = "1",HelpUri = "http://labbuildr.bottnet.de/modules")]
	param (

	[Parameter(ParameterSetName = "1", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$DiskPath,
    [Parameter(ParameterSetName = "1", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$Disk,
    [Parameter(ParameterSetName = "2", Mandatory = $True, ValueFromPipelineByPropertyName = $false)]$Diskfile

	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{
            $Diskfile = Join-Path $DiskPath $Disk
            }
            default
            {}

		}
        Write-Warning "Defragmenting $Diskfile"
	    & $Global:vmware_vdiskmanager -d $Diskfile
        Write-Verbose "Exitcode: $LASTEXITCODE"
		
	}
	end { }
}

function Repair-VMXDisk
{
	[CmdletBinding(DefaultParametersetName = "1",HelpUri = "http://labbuildr.bottnet.de/modules")]
	param (

	[Parameter(ParameterSetName = "1", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$DiskPath,
    [Parameter(ParameterSetName = "1", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$Disk,
    [Parameter(ParameterSetName = "2", Mandatory = $True, ValueFromPipelineByPropertyName = $false)]$Diskfile

	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{
            $Diskfile = Join-Path $DiskPath $Disk
            }
            default
            {}

		}
        Write-Warning "Repairing $Diskfile"
	    $repair =  & $Global:vmware_vdiskmanager -R $Diskfile
        Write-Verbose "Exitcode: $LASTEXITCODE"
		
	}
	end { }

}#end get-vmxConfigVersion




function Import-VMXOVATemplate
{
 [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
    HelpUri = "https://github.com/bottkars/LABbuildr/wiki/LABtools#Import-VMXOVATemplate")]
	param (
        [string]$OVA,
        [string]$destination=$vmxdir,
        [string]$Name,
        [switch]$acceptAllEulas,
        [Switch]$AllowExtraConfig,
        [Switch]$Quiet

        )
	$Origin = $MyInvocation.MyCommand
    
	if (test-path($OVA))
	    {
        $OVAPath = Get-ChildItem -Path $OVA -Recurse -include "*.ova","*.ovf" |Sort-Object -Descending
        $OVAPath = $OVApath[0]
        if (!$Name)
        {
            $Name = $($ovaPath.Basename)
        }
        $ovfparam = "--skipManifestCheck"
        Write-Host -ForegroundColor Gray " ==>Importing from OVA $($ovaPath.Basename), may take a while" # -NoNewline
        if ($Quiet.IsPresent)
            {
            $ovfparam = "$ovfparam --quiet"
            }
        if ($acceptAllEulas.IsPresent)
            {
            $ovfparam = "$ovfparam --acceptAllEulas"
            }
        if ($AllowExtraConfig.IsPresent)
            {
            $ovfparam = "$ovfparam --allowExtraConfig"
            }
        Start-Process -FilePath  $Global:VMware_OVFTool -ArgumentList "--lax $ovfparam --name=$Name $($ovaPath.FullName) `"$destination" -NoNewWindow -Wait
        switch ($LASTEXITCODE)
            {
            0
                {
				Write-Host -ForegroundColor Green "[success]"
		        $object = New-Object -TypeName psobject
		        $Object | Add-Member -MemberType NoteProperty -Name OVA -Value $OVAPath.BaseName
		        $object | Add-Member -MemberType NoteProperty -Name VMname -Value $Name
                $object | Add-Member -MemberType NoteProperty -Name Success -Value $true
                }
            default
                {
				Write-Host -ForegroundColor Red "[failed]"
                Write-Warning "Error $LASTEXITCODE when importing $OVAPath"
                $object = New-Object -TypeName psobject
		        $Object | Add-Member -MemberType NoteProperty -Name OVA -Value $OVAPath.BaseName
		        $object | Add-Member -MemberType NoteProperty -Name VMname -Value $Name
                $object | Add-Member -MemberType NoteProperty -Name Success -Value $false
                }
            }
            Write-Output $object
        }
        Else
            {
            Write-Host "$OVA not found"
            }
	}

<#	
	.SYNOPSIS
	    Get-VMXInfo
	
	.DESCRIPTION
		Displays Information on Virtual machines
        Memory Consumption
        Memory: the Amount of Memory configured in .vmx for the Virtual Machine
        PhysicalMemory(WorkingSet) :The amount of physical memory, in bytes, allocated for the associated process
        VirtualMemory: The amount of virtual memory, in bytes, allocated for the associated process
        Privatememory: The amount of memory, in bytes, allocated for the associated process that cannot be shared with other processes
        NonpagedMemory: (perfmon: Nonpaged Bytes )The amount of system memory, in bytes, allocated for the associated process that cannot be written to the virtual memory paging file
        Pagedmemory: The amount of memory, in bytes, allocated in the virtual memory paging file for the associated process
        Privatememory: The amount of memory, in bytes, allocated for the associated process that cannot be shared with other processes
        PagedsystemMemory: The amount of system memory, in bytes, allocated for the associated process that can be written to the virtual memory paging file

	
	.EXAMPLE
		PS C:\> Get-VMXinfo
    .EXAMPLE
	.NOTES
		requires VMXtoolkit loaded
#>
function Get-VMXInfo {
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXInfo/")]
	param (
		
		[Parameter(ParameterSetName = "2", Mandatory = $true,ValueFromPipelineByPropertyName = $true)][Alias('NAME','CloneName')]$VMXName,
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({ Test-Path -Path $_ })]$Path,
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config
	)
	Begin
	{

	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
		"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname -Path $Path }
		
		"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		if ($vmxconfig)
		{
		$ErrorActionPreference ="silentlyContinue"
		write-verbose "processing $vmxname"
        write-verbose $config
        $Processes = ""
		[bool]$ismyvmx = $false
		[uint64]$SizeOnDiskinMB = ""
		$Processes = get-process -id (Get-WmiObject -Class win32_process | where commandline -match $config.replace('\','\\')).handle
			foreach ($Process in $Processes)
			{
				if ($Process.ProcessName -ne "vmware")
				{
					write-verbose "processing objects for $vmxname"
					$vmxconfig = Get-VMXConfig -config $config
					$object = New-Object psobject
					$object.pstypenames.insert(0,'virtualmachineinfo')
					$object | Add-Member VMXName ([string]$vmxname)
					$object | Add-Member DisplayName (Get-VMXDisplayName -vmxconfig $vmxconfig).DisplayName
					$object | Add-Member GuestOS (Get-VMXGuestOS -vmxconfig $vmxconfig).GuestOs
					$object | Add-Member Processor (Get-VMXProcessor -vmxconfig $vmxconfig).Processor
					$object | Add-Member Memory (Get-VMXmemory -vmxconfig $vmxconfig).Memory
					if ($Processes)
					{
						$object | Add-Member ProcessName ([string]$Process.ProcessName)
						$object | Add-Member VirtualMemory ([uint64]($Process.VirtualMemorySize64 / 1MB))
                        $object | Add-Member PhysicalMemory ([uint64]($Process.WorkingSet64 / 1MB))
						$object | Add-Member PrivateMemory ([uint64]($Process.PrivateMemorySize64 / 1MB))
                        $object | Add-Member PagedMemory ([uint64]($Process.PagedMemorySize64 / 1MB))
                        $object | Add-Member PagedsystemMemory ([uint64]($Process.PagedSystemMemorySize64 / 1MB))
                        $object | Add-Member PeakPagedMemory ([uint64]($Process.PeakPagedMemorySize64 / 1MB))
                        $object | Add-Member PeakPhysicalMemory ([uint64]($Process.PeakWorkingSet64 / 1MB))
                        $object | Add-Member NonPagedMemory ([uint64]($Process.NonpagedSystemMemorySize64 / 1MB))
                        $object | Add-Member CPUtime ($Process.CPU)
					}
					$object | Add-Member NetWork (Get-VMXNetwork -vmxconfig $vmxconfig | select Adapter, Network)
					$object | Add-Member Adapter (Get-VMXNetworkAdapter -vmxconfig $vmxconfig | select Adapter,Type )
					$object | Add-Member Connection (Get-VMXNetworkConnection -vmxconfig $vmxconfig | select Adapter,ConnectionType)
					
					$object | Add-Member Configfile $config
					$object | Add-Member -MemberType NoteProperty -Name SCSIController -Value (Get-VMXScsiController -vmxconfig $vmxconfig | select SCSIController, Type)
					$object | Add-Member -MemberType NoteProperty -Name ScsiDisk -Value (Get-VMXScsiDisk -vmxconfig $vmxconfig | select SCSIAddress, Disk)
					Write-Output $object
					
				} #end if $Process.ProcessName -ne "vmware"
			} #  end foreach process
		}# end if $VMXconfig
	} # endprocess
	# 
} # end get-VMXinfo


<#	
	.SYNOPSIS
		A brief description of the Get-VMXmemory function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXmemory function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXmemory -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXmemory {
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXMemory/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "Memory"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		#$vmxconfig = Get-VMXConfig -VMXName $VMXname
		$patterntype = "memsize"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value "Memory" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.memory
		Write-Output $Object
	}
	end { }
} #end get-vmxmemory

<#	
	.SYNOPSIS
		A brief description of the Get-VMXProcessor function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXProcessor function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXProcessor -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXProcessor {
	
	#
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXProcessor/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}	$ErrorActionPreference = "silentlyContinue"
		$Objecttype = "Processor"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = "numvcpus"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value $patterntype -patterntype $patterntype
		# $vmxconfig = Get-VMXConfig -VMXName $VMXname
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.numvcpus
		Write-Output $Object
	}
	end { }
	
} #end Get-VMXProcessor

<#	
	.SYNOPSIS
		A brief description of the Get-VMXScsiDisk function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXScsiDisk function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXScsiDisk -config $value1 -Name $value2
	.EXAMPLE
        $VMX = Get-VMX .\ISINode1
        $Disks = $VMX | Get-VMXScsiDisk
        $Disks | ForEach-Object {[System.Math]::Round((Get-ChildItem "$($VM.Path)\$($_.Disk)").Length/1MB,2)}
        511,19
        269,44
        233,06
        230,06
        259,31
	.NOTES
		Additional information about the function.
#>
function Get-VMXScsiDisk{
	
	#
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXScsiDisk/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			    { 
                $vmxconfig = Get-VMXConfig -VMXName $VMXname
                $config = $vmxconfig.config
                }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		

		$Patterntype = ".fileName"
		$ObjectType = "SCSIDisk"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message $ObjectType
		$Value = Search-VMXPattern -Pattern "scsi\d{1,2}:\d{1,2}.fileName" -vmxconfig $vmxconfig -name "SCSIAddress" -value "Disk" -patterntype $Patterntype
		foreach ($Disk in $value)
		{
			$object = New-Object -TypeName psobject
			$object.pstypenames.insert(0,'vmxscsidisk')
		$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
			$object | Add-Member -MemberType NoteProperty -Name SCSIAddress -Value $Disk.ScsiAddress
            $object | Add-Member -MemberType NoteProperty -Name Controller -Value ($Disk.ScsiAddress.Split(":")[0]).replace("scsi","")
            $object | Add-Member -MemberType NoteProperty -Name LUN -Value $Disk.ScsiAddress.Split(":")[1]
			$object | Add-Member -MemberType NoteProperty -Name Disk -Value $Disk.disk
            If ($PsCmdlet.ParameterSetName -eq 2)
                {
                $Diskpath = split-path -Parent $config
                $Diskfile = Join-Path $Diskpath $Disk.disk
                $object | Add-Member -MemberType NoteProperty -Name SizeonDiskMB -Value ([System.Math]::Round((get-item $Diskfile).length/1MB,2))
                $object | Add-Member -MemberType NoteProperty -Name DiskPath -Value $Diskpath
                }
            $object | Add-Member -MemberType NoteProperty -Name Config -Value $config
			Write-Output $Object
		}
	}
	end { }
} #end Get-VMXScsiDisk

<#	
	.SYNOPSIS
		A brief description of the Get-VMXScsiController function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXScsiController function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXScsiController -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXScsiController {

	#
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXScsiController/")]
param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
		{
			switch ($PsCmdlet.ParameterSetName)
			{
				"1"
				{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
				"2"
				{ $vmxconfig = Get-VMXConfig -config $config }
			}
		
		$ObjectType = "SCSIController"
		$patterntype = ".virtualDev"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "scsi\d{1,2}$patterntype" -vmxconfig $vmxconfig -name "Controller" -value "Type" -patterntype $patterntype
		foreach ($controller in $Value)
            {
            $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXname
		    $object | Add-Member -MemberType NoteProperty -Name SCSIController -Value $Controller.Controller
		    $object | Add-Member -MemberType NoteProperty -Name Type -Value $Controller.Type
		    Write-Output $Object
            }
	}
	end
	{
	}
}#end Get-VMXScsiController

<#	
	.SYNOPSIS
		A brief description of the Get-VMXideDisk function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXideDisk function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXideDisk -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXIdeDisk{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXIdeDisk/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "IDEDisk"
		$Patterntype = ".fileName"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "ide\d{1,2}:\d{1,2}$Patterntype" -vmxconfig $vmxconfig -name "IDEAddress" -value "Disk" -patterntype $Patterntype
	    foreach ($IDEDisk in $Value)
            {
            $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		    $object | Add-Member -MemberType NoteProperty -Name IDEAddress -Value $IDEDisk.IDEAddress
		    $object | Add-Member -MemberType NoteProperty -Name Disk -Value $IDEDisk.Disk

		    Write-Output $Object
            }
	}
	end { }

}

####
#scsi0.virtualDev = "pvscsi"
function Set-VMXScsiController {

	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Set-VMXScsiController/")]
param (

	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$config,
    [Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]
	[ValidateRange(0,3)]$SCSIController=0,
    [Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]
	[ValidateSet('pvscsi','lsisas1068')]$Type="pvscsi"
	)
	begin
	{
	}
	process
		{
        if ((get-vmx -Path $config).state -eq "stopped")

            { 
            $content = Get-VMXConfig -config $config
            $Content = $content -notmatch "scsi$SCSIController.present"
            $Content = $Content -notmatch "scsi$SCSIController.virtualDev"
		    $Content = $Content += 'scsi'+$SCSIController+'.virtualDev = "'+$Type+'"'
		    $Content = $Content += 'scsi'+$SCSIController+'.present = "TRUE"'
            $Content | Set-Content -Path $config
            $object = New-Object -TypeName psobject
            $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXname
            $object | Add-Member -MemberType NoteProperty -Name SCSIController -Value $SCSIController
            $object | Add-Member -MemberType NoteProperty -Name Config -Value $config
            $object | Add-Member -MemberType NoteProperty -Name Type -Value $Type
            Write-Output $Object
            }
		else
            {
            Write-Warning "VM must be in stopped state"
            }
	}
	end
	{
	}

}#end Get-VMXIDEDisk

<#	
	.SYNOPSIS
		A brief description of the Search-VMXPattern function.
	
	.DESCRIPTION
		A detailed description of the Search-VMXPattern function.
	
	.PARAMETER name
		A description of the VMXname parameter.
	
	.PARAMETER pattern
		A description of the pattern parameter.
	
	.PARAMETER patterntype
		A description of the patterntype parameter.
	
	.PARAMETER value
		A description of the value parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Search-VMXPattern -name $value1 -pattern $value2
	
	.NOTES
		Additional information about the function.
#>
function Search-VMXPattern  {
param($pattern,$vmxconfig,$name,$value,$patterntype,[switch]$nospace)
#[array]$mypattern
$getpattern = $vmxconfig| where {$_ -match $pattern}
Write-Verbose "Patterncount : $getpattern.count"
Write-Verbose "Patterntype : $patterntype"
	foreach ($returnpattern in $getpattern)
	{
		Write-Verbose "returnpattern : $returnpattern"
		$returnpattern = $returnpattern.Replace('"', '')
		if ($nospace.IsPresent)
		{
			Write-Verbose "Clearing Spaces"
			$returnpattern = $returnpattern.Replace(' ', '')#
			$returnpattern = $returnpattern.split("=")
		}
		else
		{
			$returnpattern = $returnpattern.split(" = ")
		}
		Write-Verbose "returnpattern: $returnpattern"
		Write-Verbose $returnpattern.count
$nameobject = $returnpattern[0]
Write-Verbose "nameobject fro returnpattern $nameobject "
$nameobject = $nameobject.Replace($patterntype,"")
$valueobject  = ($returnpattern[$returnpattern.count-1])
Write-Verbose "Search returned Nameobject: $nameobject"
Write-Verbose "Search returned Valueobject: $valueobject"
# If ($getpattern.count -gt 1) {
$object = New-Object psobject
if ($name) {$object | Add-Member -MemberType NoteProperty -Name $name -Value $nameobject}
$object | Add-Member -MemberType NoteProperty -Name $value -Value $valueobject
Write-Output $object
# }
# else
# { Write-Output $valueobject
# }
}#end foreach
# return $mypattern
}#end search-pattern

<#	
	.SYNOPSIS
		A brief description of the Get-VMXConfig function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXConfig function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXConfig -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXConfig{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXConfig/")]
param
(

	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
#	[Parameter(ParameterSetName = "2", Mandatory = $false, Position = 1,  ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({ Test-Path -Path $_ })]$Path,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config
#	[Parameter(ParameterSetName = "2", Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $True)]$config

)
	begin
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $config = "$path\$VMXname.vmx" }
		}
	}
	process
{
$vmxconfig = Get-Content $config
Write-Output $vmxconfig
}
end{}
}#end get-vmxconfig

<#	
	.SYNOPSIS
		A brief description of the Get-VMXNetworkAdapter function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXNetworkAdapter function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXNetworkAdapter -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXNetworkAdapter{
	
	#
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXNetworkAdapter/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXName }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}	
		$ObjectType = "NetworkAdapter"
		$patterntype = ".virtualDev"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "ethernet\d{1,2}.virtualdev" -vmxconfig $vmxconfig -name "Adapter" -value "Type" -patterntype $patterntype
		foreach ($Adapter in $value)
		{
			$object = New-Object -TypeName psobject
			$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
			$object | Add-Member -MemberType NoteProperty -Name Adapter -Value $Adapter.Adapter
			$object | Add-Member -MemberType NoteProperty -Name Type -Value $Adapter.type
			Write-Output $Object
		}
	}
	end { }
}#end Get-VMXNetworkAdapter
function Get-VMXNetworkAddress{
	
	#
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXNetworkAdapter/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXName }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}	
		$ObjectType = "NetworkAdapter"
		$patterntype = ".generatedAddress"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "ethernet\d{1,2}$patterntype " -vmxconfig $vmxconfig -name "Adapter" -value "Address" -patterntype $patterntype
		foreach ($Adapter in $value)
		{
			$object = New-Object -TypeName psobject
			$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
			$object | Add-Member -MemberType NoteProperty -Name Adapter -Value $Adapter.Adapter
			$object | Add-Member -MemberType NoteProperty -Name Address -Value $Adapter.Address
			Write-Output $Object
		}
	}
	end { }
}#end Get-VMXNetworkAdapter
<#	
	.SYNOPSIS
		A brief description of the Get-VMXNetwork function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXNetwork function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXNetwork -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXNetwork
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXNetwork/")]
param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
)
begin
{
}
process
{
	switch ($PsCmdlet.ParameterSetName)
	{
		"1"
		{ $vmxconfig = Get-VMXConfig -VMXName $VMXName }
		"2"
		{ $vmxconfig = Get-VMXConfig -config $config }
	}
	$patterntype = ".vnet"
	$ObjectType = "Network"
	$ErrorActionPreference = "silentlyContinue"
	Write-Verbose -Message "getting Network Controller"
	$Networklist = Search-VMXPattern -Pattern "ethernet\d{1,2}$patterntype" -vmxconfig $vmxconfig -name "Adapter" -value "Network" -patterntype $patterntype
		foreach ($Value in $Networklist)
		{
			$object = New-Object -TypeName psobject
			$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
            $object | Add-Member -MemberType NoteProperty -Name Adapter -Value $Value.Adapter
			$object | Add-Member -MemberType NoteProperty -Name Network -Value $Value.Network
			
			
			Write-Output $Object
		}
	}
	end { }
}#end Get-VMXNetwork

function Get-VMXNetworkConnection{
	
	#
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXNetworkConnection")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "NetworkConnection"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = ".connectionType"
		$value = Search-VMXPattern -Pattern "ethernet\d{1,2}$patterntype" -vmxconfig $vmxconfig -name "Adapter" -value "ConnectionType" -patterntype $patterntype
		foreach ($Connection in $Value)
            {
            $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		    $object | Add-Member -MemberType NoteProperty -Name Adapter -Value $Connection.Adapter
		    $object | Add-Member -MemberType NoteProperty -Name ConnectionType -Value $Connection.ConnectionType

		    Write-Output $Object
            }
		
	}
	end { }
}#end Get-VMXNetwork

<#	
	.SYNOPSIS
		A brief description of the Get-VMXGuestOS function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXGuestOS function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXGuestOS -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXGuestOS{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXGuestOS/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$objectType = "GuestOS"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting GuestOS"
		$patterntype = "GuestOS"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value "GuestOS" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.Guestos
		Write-Output $Object
	}
	
	end { }
}#end Get-VMXGuestOS

<#	
	.SYNOPSIS
		A brief description of the Get-VMXVTBit function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXVTBit function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXVTBit -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXVTBit
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://github.com/bottkars/vmxtoolkit/wiki/Get-VMXVTBit")]
	param (
		[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "1", Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $True)]
		[Alias('NAME','CloneName')]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
		[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname  }
			"2"
			{ 
			$vmxconfig = Get-VMXConfig -config $config
			}
		}	
		$ObjectType = "vhv"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = ".enable"
		$Value = Search-VMXPattern -Pattern "$ObjectType$patterntype" -vmxconfig $vmxconfig -name "Type" -value $ObjectType -patterntype $patterntype
		#$Value = Search-VMXPattern  -Pattern "uuid.bios" -vmxconfig $vmxconfig -Name "Type" -value $ObjectType -patterntype $patterntype -nospace

		$object = New-Object -TypeName psobject
		# $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXName
		if (!$Value.vhv)
			{
			$object | Add-Member -MemberType NoteProperty -Name VTbit -Value False
			}
		else
			{
			$object | Add-Member -MemberType NoteProperty -Name VTbit -Value $($Value.vhv)
			}

		$object | Add-Member -MemberType NoteProperty -Name Config -Value (Get-ChildItem -Path $Config)
		Write-Output $Object
	}
	end { }
	}#end Get-VMXVTBit

function Get-VMXIPAddress
{
	[CmdletBinding(DefaultParametersetName = "1",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXIPAddress/")]
	param (
		[Parameter(ParameterSetName = "1", Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ }
			"2"
			{ 
            $vmx = Get-VMX -Path $config
            $Config = $vmx.config
            }
		}	
        $ObjectType = "IPAddress"
		 #$ErrorActionPreference = "silentlyContinue"
        $IPAddress = .$vmrun getguestipaddress $config
        If ($LASTEXITCODE -ne 0)
            {
            Write-Warning "$LASTEXITCODE , $IPAddress"
            }
        Else
            {
            Write-Verbose -Message "getting $ObjectType"
		    $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		    $object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $IPAddress
		    Write-Output $Object
            }
	}
	end { }
	}#end Get-VMXIPAddress



<#
	.SYNOPSIS
		A brief description of the Set-VMXDisplayName function.

	.DESCRIPTION
		Sets the VMX Friendly DisplayName

	.PARAMETER  config
		Please Specify Valid Config File

	.EXAMPLE
		PS C:\> Set-VMXDisplayName -config $value1
		'This is the output'
		This example shows how to call the Set-VMXDisplayName function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Set-VMXDisplayName
{
	[CmdletBinding(HelpUri = "http://labbuildr.bottnet.de/modules/Set-VMXDisplayName")]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'Please Specify Valid Config File')]$config,
		[Parameter(Mandatory = $false,
				   ValueFromPipelineByPropertyName = $False,
				   HelpMessage = 'Please Specify New Value for DisplayName')][Alias('Value')]$DisplayName
	)
	
	Begin
	{
		
		
	}
	Process
	{
        if ((get-vmx -Path $config).state -eq "stopped")
        {
        $Displayname = $DisplayName.replace(" ","_")
		$Content = Get-Content $config | where { $_ -ne "" }
		$Content = $content | where { $_ -NotMatch "DisplayName" }
		$content += 'DisplayName = "' + $DisplayName + '"'
		Set-Content -Path $config -Value $content -Force
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name DisplayName -Value $DisplayName
		Write-Output $Object
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	End
	{
		
	}
}

<#
	.SYNOPSIS
		A brief description of the Set-VMXguestos function.

	.DESCRIPTION
		Sets the VMX Friendly guestos

	.PARAMETER  config
		Please Specify Valid Config File

	.EXAMPLE
		PS C:\> Set-VMXguestos -config $value1
		'This is the output'
		This example shows how to call the Set-VMXguestos function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Set-VMXGuestOS
{
	[CmdletBinding(HelpUri = "http://labbuildr.bottnet.de/modules/Set-VMXguestos")]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'Please Specify Valid Config File')]$config,
		[Parameter(Mandatory = $false,
				   ValueFromPipelineByPropertyName = $False,
				   HelpMessage = 'Please Specify New Value for guestos')]
				   [ValidateSet(
				   'other-64','winhyperv','centos-64',
				   'vmkernel5','vmkernel6',
				   'winhyperv','windows8srv-64',
				   'other26xlinux','sles11-64')]
				   [Alias('Value')]$GuestOS,
		[Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $True)]
		[Alias('NAME','CloneName')]
		[string]$VMXName
	)
	
	Begin
	{
		
		
	}
	Process
	{
        if ((get-vmx -Path $config).state -eq "stopped")
        {
		Write-Host -ForegroundColor Gray " ==>setting GuestOS $GuestOS for " -NoNewline
		Write-Host -ForegroundColor Magenta $vmxname -NoNewline
		Write-Host -ForegroundColor Green "[success]"
		$Content = Get-Content $config | where { $_ -ne "" }
		$Content = $content | where { $_ -NotMatch "guestos" }
		$content += 'guestos = "' + $GuestOS + '"'
		Set-Content -Path $config -Value $content -Force
		$object = New-Object -TypeName psobject
		$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXName
		$Object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name GuestOS -Value $GuestOS
		Write-Output $Object
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	End
	{
		
	}
}

<#
	.SYNOPSIS
		A brief description of the Set-VMXVTBitfunction.

	.DESCRIPTION
		Sets the VMX VTBit

	.PARAMETER  config
		Please Specify Valid Config File

	.EXAMPLE
		PS C:\> Set-VMXVTBit -config $value1
		'This is the output'
		This example shows how to call the Set-VMXVTBit function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Set-VMXVTBit
{
	[CmdletBinding(HelpUri = "http://labbuildr.bottnet.de/modules/Set-VMXVTBit")]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'Please Specify Valid Config File')]$config,
		[Parameter(Mandatory = $false,
				   ValueFromPipelineByPropertyName = $False)]
				   [switch]$VTBit,
		[Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $True)]
		[Alias('NAME','CloneName')]
		[string]$VMXName
	)
	
	Begin
	{
		
		
	}
	Process
	{
        if ((get-vmx -Path $config).state -eq "stopped")
        {
		Write-Host -ForegroundColor Gray " ==>setting Virtual VTbit to $($VTBit.IsPresent.ToString()) for " -NoNewline
		Write-Host -ForegroundColor Magenta $vmxname -NoNewline
		Write-Host -ForegroundColor Green "[success]"
		$Content = Get-Content $config | where { $_ -ne "" }
		$Content = $content | where { $_ -NotMatch "vhv.enable" }
		$content += 'vhv.enable = "' + $VTBit.IsPresent.ToString() + '"'
		Set-Content -Path $config -Value $content -Force
		$object = New-Object -TypeName psobject
		$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXName
		$Object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name "Virtual VTBit" -Value $VTBit.IsPresent.ToString()
		Write-Output $Object
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	End
	{
		
	}
}

function Set-VMXUUID
{
	[CmdletBinding(HelpUri = "http://labbuildr.bottnet.de/modules/Set-VMXUUID")]
	param
	(
		[Parameter(Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'Please Specify Valid Config File')]$config,
		[Parameter(Mandatory = $false,
				   ValueFromPipelineByPropertyName = $False,
				   HelpMessage = 'Please Specify New Value for UUID')] [ValidatePattern('^[0-9a-f]{16}-[0-9a-f]{16}$')][Alias('Value')]$UUID
	)
	
	Begin
	{
		
		
	}
	Process
	{
        if ((get-vmx -Path $config).state -eq "stopped")
        {
		$Content = Get-Content $config | where { $_ -ne "" }
		$Content = $content | where { $_ -NotMatch "uuid.bios" }
		$content += 'uuid.bios = "' + $UUID + '"'
		Set-Content -Path $config -Value $content -Force
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name UUID -Value $UUID
		Write-Output $Object
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	End
	{
		
	}
}

<#
	.SYNOPSIS
		

	.DESCRIPTION
		Sets the VMX Shared fOLDER State

	.PARAMETER  config
		Please Specify Valid Config File

	.EXAMPLE
		
	.NOTES
		Additional information about the function or script.

#>
function Set-VMXSharedFolderState
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
		[Parameter(Mandatory = $false, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(Mandatory = $true, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$config,
		[Parameter(Mandatory = $True, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)][switch]$enabled,
		[Parameter(Mandatory = $True, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][switch]$disabled
	)
	Begin
	{
		
	}
	Process
	{
	    
		$object = New-Object psobject
		$object | Add-Member -MemberType 'NoteProperty' -Name VMXname -Value $VMXname
        $object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config

		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			   {
				Write-Host -ForegroundColor Gray " ==>enabling shared folders (hgfs) for " -NoNewline
				Write-Host -ForegroundColor Magenta $VMXName -NoNewline
                Write-Verbose "enabling Shared Folder State for $config"
                do 
                    { 
                    $cmdresult = &$vmrun enableSharedFolders $config
                    }
                until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
                $object | Add-Member -MemberType 'NoteProperty' -Name State -Value "enabled"
                }
			"2"
			{
			Write-Host -ForegroundColor Gray " ==>disabling shared folders (hgfs) for " -NoNewline
			Write-Host -ForegroundColor Magenta $VMXName -NoNewline
            Write-Verbose "Disabling Shared Folder State for $config"
            do 
                { 
                $cmdresult = &$vmrun disableSharedFolders $config
                }
            until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
		    $object | Add-Member -MemberType 'NoteProperty' -Name State -Value "disabled"
			}
		}
        if ($LASTEXITCODE -eq 0)
            {
			Write-Host -ForegroundColor Green "[success]"
            Write-Output $Object
			}
        else
            {
			Write-Host -ForegroundColor Red "[failed]"
            Write-Warning "exit with status $LASTEXITCODE $cmdresult"
            }
	}
	End
    {
		
	}
}




<#

addSharedFolder          Path to vmx file     Add a Host-Guest shared folder
                         Share name
                         New host path


#>
<#
	.SYNOPSIS
		

	.DESCRIPTION
		Sets the VMX Shared fOLDER State

	.PARAMETER  config
		Please Specify Valid Config File

	.EXAMPLE
		
	.NOTES
		Additional information about the function or script.

#>
function Set-VMXSharedFolder
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
		[Parameter(Mandatory = $false, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(Mandatory = $true, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$config,
        [Parameter(Mandatory = $True, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)][switch]$add,
		[Parameter(Mandatory = $True, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][switch]$remove,
        [Parameter(Mandatory = $True, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(Mandatory = $True, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][ValidateLength(3,10)][ValidatePattern("^[a-zA-Z\s]+$")]$Sharename,
        [Parameter(Mandatory = $True, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		#[ValidateScript({ Test-Path -Path $_ })]
		$Folder


	)
	Begin
	{
		
	}
	Process
	{
	    
		$object = New-Object psobject
		$object | Add-Member -MemberType 'NoteProperty' -Name VMXname -Value $VMXname
        $object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config

		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			   {
				Write-Host -ForegroundColor Gray " ==>adding Share $Sharename for Folder $Folder to " -NoNewline
				Write-Host -ForegroundColor Magenta $VMXName -NoNewline                
				Write-Verbose "adding Share $Sharename for Folder $Folder for $config"
                do 
                    { 
                    $cmdresult = &$vmrun addSharedFolder $config $Sharename $Folder
                    }
                until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
                $object | Add-Member -MemberType 'NoteProperty' -Name Share -Value $Sharename
                $object | Add-Member -MemberType 'NoteProperty' -Name Folder -Value $Folder
                }
			"2"
				{
				Write-Host -ForegroundColor Gray " ==>removing Share $Sharename for Folder $Folder to " -NoNewline
				Write-Host -ForegroundColor Magenta $VMXName -NoNewline                
				Write-Verbose "removing Shared Folder for $config"
                do 
                    { 
                    $cmdresult = &$vmrun removeSharedFolder $config $Sharename
                    }
                until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
		        $object | Add-Member -MemberType 'NoteProperty' -Name Sharename -Value "removed"
			}
		}
        if ($LASTEXITCODE -eq 0)
            {
			Write-Host -ForegroundColor Green "[success]"
            Write-Output $Object
			}
        else
            {
			Write-Host -ForegroundColor Red "[failed]"
            Write-Error "exit with status $LASTEXITCODE $cmdresult"
			Break
            }
	}
	End
    {
		
	}
}


function Get-VMXUUID
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
		[Parameter(ParameterSetName = "1", Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
		[Parameter(ParameterSetName = "3", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "UUID"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = ".bios"
		$Value = Search-VMXPattern  -Pattern "uuid.bios" -vmxconfig $vmxconfig -Name "Type" -value $ObjectType -patterntype $patterntype -nospace
		# $Value = Search-VMXPattern -Pattern "ethernet\d{1,2}.virtualdev" -vmxconfig $vmxconfig -name "Adapter" -value "Type" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.uuid
		Write-Output $Object
	}
	end { }
}#end Get-UUID
<#	
	.SYNOPSIS
		A brief description of the Get-VMXRun function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXRun function.
	
	.EXAMPLE
		PS C:\> Get-VMXRun
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXRun{
	$runvms = @()
	# param ($Name)
	
	$Origin = $MyInvocation.MyCommand
	do
	{
		(($cmdresult = &$vmrun List) 2>&1 | Out-Null)
		write-verbose "$origin $cmdresult"
	}
	until ($VMrunErrorCondition -notcontains $cmdresult)
	write-verbose "$origin $cmdresult"
	foreach ($runvm in $cmdresult)
	{
		if ($runvm -notmatch "Total running VMs")
			{
			[System.IO.FileInfo]$runvm = $runvm
			# $runvm = $runvm.TrimEnd(".vmx")
			$object = New-Object -TypeName psobject
			#$object.pstypenames.insert(0,'virtualmachine')
			$object | Add-Member -MemberType NoteProperty -Name VMXName -Value ([string]($runvm.BaseName))
			$object | Add-Member -MemberType NoteProperty -Name config -Value $runvm.FullName
			$object | Add-Member -MemberType NoteProperty -Name Status -Value running
			Write-Output $object
			# Shell opject will be cretaed in next version containing name, vmpath , status
		}# end if
	}#end foreach
} #end get-vmxrun


<#	
	.SYNOPSIS
		A brief description of the get-VMX function.
	
	.DESCRIPTION
		A detailed description of the get-VMX function.
	
	.PARAMETER Name
		Please specify an optional VM Name
	
	.PARAMETER Path
		Please enter an optional root Path to you VMs (default is vmxdir)
	
	.EXAMPLE
		PS C:\> Get-VMX -VMXName $value1 -Path $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMX 
{
	[CmdletBinding(HelpUri = "http://labbuildr.bottnet.de/modules/get-vmx/")]
	param (
		[Parameter(ParameterSetName = "1", Position = 1,HelpMessage = "Please specify an optional VM Name",Mandatory = $false)]
        [Parameter(ParameterSetName = "2",Mandatory = $false)]$VMXName,
		[Parameter(ParameterSetName = "1", HelpMessage = "Please enter an optional root Path to you VMs (default is vmxdir)",Mandatory = $false)]
		$Path = $vmxdir,
		[Parameter(ParameterSetName = "1",Mandatory = $false)]$UUID,
        [Parameter(ParameterSetName = "2", Position = 2,HelpMessage = "Please specify a config to vmx",Mandatory = $true)][System.IO.FileInfo]$config

)

begin
    {}
process
		{
        $vmxrun = (Get-VMXRun).config
		$Configfiles = @()
		switch ($PsCmdlet.ParameterSetName)
			{
			"1"
				{ 
                Write-Verbose "Getting vmxname from parameterset 1"
                if ($VMXName)
                    {
                    $VMXName = $VMXName.TrimStart(".\")
                    $VMXName = $VMXName.TrimEnd("\")
					$VMXName = $VMXName.TrimStart("./")
                    $VMXName = $VMXName.TrimEnd("/")
                    Write-Verbose $VMXName
                    }
                else
                    { 
                    $VMXName = "*"
                    }
                Write-Verbose $MyInvocation.MyCommand
                if (!(Test-path $Path))
                    {
                    Write-Warning "VM Path $Path does currently not exist"
                    # break
                    }
                if (!($Configfiles = Get-ChildItem -Path $path -Recurse -File -Filter "$VMXName.vmx" -Exclude "*.vmxf" -ErrorAction SilentlyContinue ))
                {
                 Write-Warning "$($MyInvocation.MyCommand) : VM $VMXName does currently not exist"
                # break
                }

            	}
				
				"2"
				{
                $VMXname = $config.Basename
				#$VMXName = (Split-Path -Leaf $config) -replace ".vmx",""
                if (!($Configfiles = Get-Item -Path $config -ErrorAction SilentlyContinue ))
                    {
                    Write-Warning "$($MyInvocation.MyCommand) : VM Config for $config does currently not exist"
                    # break
                    }
                }
				
			}
        $VMX = @()
	    foreach ($Config in $Configfiles)
	        {
		    Write-Verbose "getting Configfile: $($config.FullName) from parameterset 2"
		    if ($Config.Extension -eq ".vmx")
                {
			if ($UUID)
			{
				Write-Verbose $UUID
				$VMXUUID = Get-VMXUUID -config $Config.fullname
				If ($VMXUUID.uuid -eq $UUID) {
					$object = New-Object -TypeName psobject
					$object.pstypenames.insert(0,'virtualmachine')
					$object | Add-Member -MemberType NoteProperty -Name VMXName -Value ([string]($Config.BaseName))

                    if ($vmxrun -contains $config.FullName)
					{
						$object | Add-Member State ("running")
					}
					elseif (Get-ChildItem -Filter *.vmss -Path ($config.DirectoryName))
					{
						$object | Add-Member State ("suspended")
					}
					else
					{
						$object | Add-Member State ("stopped")
					}
					$object | Add-Member -MemberType NoteProperty -Name Template -Value (Get-VMXTemplate -config $Config).template
                    $object | Add-Member -MemberType NoteProperty -Name ActivationPreference -Value (Get-VMXActivationPreference -config $Config -VMXName $Config.BaseName).ActivationPreference
					$object | Add-Member -MemberType NoteProperty -Name Scenario -Value (Get-VMXscenario -config $Config -VMXName $Config.BaseName) #.Scenario
					$object | Add-Member -MemberType NoteProperty -Name UUID -Value (Get-VMXUUID -config $Config.FullName).uuid
					$object | Add-Member -MemberType NoteProperty -Name Config -Value ([string]($Config.FullName))
					$object | Add-Member -MemberType NoteProperty -Name Path -Value ([string]($Config.Directory))
                    $object | Add-Member -MemberType NoteProperty -Name VMXSnapConfig -Value ([string](Get-ChildItem -Path $Config.Directory -Filter "*.vmsd").Fullname)
                    Write-Verbose "Config Fullname $($Config.Fullname)"
					Write-Output $object
				}# end if
				
			}#end-if uuid
			if (!($UUID))
			{				
				$object = New-Object -TypeName psobject
				$object.pstypenames.insert(0,'virtualmachine')
				$object | Add-Member -MemberType NoteProperty -Name VMXName -Value ([string]($Config.BaseName))
				if ($vmxrun -contains $config.fullname)
				{
					$object | Add-Member State ("running")
				}
				elseif (Get-ChildItem -Filter *.vmss -Path ($config.DirectoryName))
				{
					$object | Add-Member State ("suspended")
				}
				else
				{
					$object | Add-Member State ("stopped")
				}
				$object | Add-Member -MemberType NoteProperty -Name Template -Value (Get-VMXTemplate -Config $Config).template
                $object | Add-Member -MemberType NoteProperty -Name ActivationPreference -Value (Get-VMXActivationPreference -config $Config -VMXName $Config.BaseName).ActivationPreference
                $object | Add-Member -MemberType NoteProperty -Name Scenario -Value (Get-VMXscenario -config $Config -VMXName $Config.BaseName | Select-Object scenario, scenarioname)# .Scenario
				$object | Add-Member -MemberType NoteProperty -Name UUID -Value (Get-VMXUUID -config $Config.FullName).uuid
			    $object | Add-Member -MemberType NoteProperty -Name Config -Value ([string]($Config.FullName))
				$object | Add-Member -MemberType NoteProperty -Name Path -Value ([string]($Config.Directory))
                $object | Add-Member -MemberType NoteProperty -Name VMXSnapConfig -Value ([string](Get-ChildItem -Path $Config.Directory -Filter "*.vmsd").Fullname)
				Write-Output $object
			}
			#}#end template
		}#end if
            
		     
	}
}

end {}
}
# end get-vmx
<#
	.SYNOPSIS
		A brief description of the New-VMXSnapshot function.

	.DESCRIPTION
		Creates a new Snapshot for the Specified VM(s)

	.PARAMETER  Name
		VM name for Snapshot

	.PARAMETER  SnapshotName
		Name of the Snapshot

	.EXAMPLE
		PS C:\> New-VMXSnapshot -Name 'Value1' -SnapshotName 'Value2'
		'This is the output'
		This example shows how to call the New-VMXSnapshot function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function New-VMXSnapshot
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
		#[Parameter(Mandatory = $true, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('TemplateName')][string]$VMXName,
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$Path = "$Global:vmxdir",
		[Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$config,
		[Parameter(Mandatory = $false)][string]$SnapshotName = (Get-Date -Format "MM-dd-yyyy_HH-mm-ss")
	)
	Begin
	{
		
	}
	Process
	{

		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $config = Get-VMX -VMXName $VMXname -Path $Path }
			"2"
			{
		
			}
		}
	    Write-Verbose "creating Snapshot $Snapshotname for $vmxname"
		Write-Host -ForegroundColor Gray " ==>creating new Snapshot $Snapshotname for " -NoNewline
		Write-Host -ForegroundColor Magenta $VMXName -NoNewline
        do
            {
	        ($cmdresult = &$vmrun snapshot $config $SnapshotName) # 2>&1 | Out-Null
			}
		until ($VMrunErrorCondition -notcontains $cmdresult)
        if ($LASTEXITCODE -eq 0)
            {
			Write-Host -ForegroundColor Green "[success]"
		    $object = New-Object psobject
		    $object | Add-Member -MemberType 'NoteProperty' -Name VMXname -Value $VMXname
		    $object | Add-Member -MemberType 'NoteProperty' -Name Snapshot -Value $SnapshotName
            $object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config
            $object | Add-Member -MemberType 'NoteProperty' -Name Path -Value $Path
            Write-Output $Object
			}
        else
            {
			Write-Host -ForegroundColor Red "[failed]"
            Write-Error "exit with status $LASTEXITCODE $cmdresult"
			Break
            }
    }
	End
    {
		
	}
}



<#
	.SYNOPSIS
		A brief description of the Restore-VMXSnapshot function.

	.DESCRIPTION
		Restores a new Snapshot for the Specified VM(s)

	.PARAMETER  SnapshotName
		Name of the Snapshot

	.EXAMPLE


	.NOTES
		Additional information about the function or script. bsed upon revertToSnapshot


#>
function Restore-VMXSnapshot
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
		#[Parameter(Mandatory = $true, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$Path = "$Global:vmxdir",
		[Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$config,
		[Parameter(Mandatory = $True, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('Snapshotname')][string]$Snapshot
	)
	Begin
	{
		
	}
	Process
	{

		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $config = Get-VMX -VMXName $VMXname -Path $Path }
			"2"
			{
		
			}
		}
	    Write-Verbose "Restoring Snapshot $Snapshot for $vmxname"
        do
            {
	        ($cmdresult = &$vmrun revertToSnapshot $config $Snapshot) # 2>&1 | Out-Null
			}
		until ($VMrunErrorCondition -notcontains $cmdresult)
        if ($LASTEXITCODE -eq 0)
            {
            Write-Verbose "Sapshot $Snapshot restored"
		    $object = New-Object psobject
		    $object | Add-Member -MemberType 'NoteProperty' -Name VMXname -Value $VMXname
		    $object | Add-Member -MemberType 'NoteProperty' -Name Snapshot -Value $Snapshot
            $object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config
            $object | Add-Member -MemberType 'NoteProperty' -Name Path -Value $Path
            $object | Add-Member -MemberType 'NoteProperty' -Name State -Value "restored"

            Write-Output $Object
			}
        else
            {
            Write-Warning "exit with status $LASTEXITCODE $cmdresult"
            }
	}
	End
    {
		
	}
}


<#
	.SYNOPSIS
		Synopsis

	.DESCRIPTION
		Create a linked Clone from a Snapshot

	.PARAMETER  BaseSnapshot
		Based Snapshot to Link from

	.PARAMETER  CloneName
		A description of the CloneName parameter.

	.EXAMPLE
		PS C:\> New-VMXLinkedClone -BaseSnapshot $value1 -CloneName $value2
		'This is the output'
		This example shows how to call the New-VMXLinkedClone function with named parameters.

	.OUTPUTS
		psobject

	.NOTES
		Additional information about the function or script.

#>
function New-VMXLinkedClone
{
	[CmdletBinding(DefaultParameterSetName = '1',HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Snapshot')]
		$BaseSnapshot,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$Config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$CloneName,
		[Parameter(Mandatory = $false)][ValidateScript({ Test-Path -Path $_ })]$Clonepath,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$Path
	)

	Begin
	{
		
	}
	Process
	{
		#foreach ($config in $getconfig)
		if (!$Clonepath) { $Clonepath = $global:vmxdir } #Split-Path -Path $Path -Parent }
		Write-Verbose "clonepath is $ClonePath"
		$cmdresult = ""
		$Targetpath = Join-Path $Clonepath $CloneName 
		$CloneConfig = Join-path "$Targetpath" "$CloneName.vmx"
		$TemplateVM = Split-Path -Leaf $config
		$Templatevm = $TemplateVM -replace ".vmx",""
		Write-Verbose "creating Linked Clone $Clonename from $TemplateVM $Basesnapshot in $Cloneconfig"
		Write-Host -ForegroundColor Gray " ==>creating Linked Clone from $TemplateVM $Basesnapshot for " -NoNewline
		Write-Host -ForegroundColor Magenta $Clonename -NoNewline
		do
			{
			$snapcommand = "clone '$config' $Cloneconfig linked -snapshot=$($BaseSnapshot) -cloneName=$($Clonename)" # 2>&1 | Out-Null
			Write-Verbose "Trying $snapcommand"
			$cmdresult = Start-Process $Global:vmrun -ArgumentList "$snapcommand" 
			}
		until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
        if ($LASTEXITCODE -eq 0)
            {
			Write-Host -ForegroundColor Green "[success]"
			sleep 2
			$Addcontent = @()
			$Addcontent += 'guestinfo.buildDate = "'+$BuildDate+'"'
			Add-Content -Path "$Cloneconfig" -Value $Addcontent
			$object = New-Object psobject
			$object | Add-Member -MemberType 'NoteProperty' -Name CloneName -Value $Clonename
			$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $Cloneconfig
			$object | Add-Member -MemberType 'NoteProperty' -Name Path -Value $Targetpath
			Write-Output $Object
            }
        else
            {
			Write-Host -ForegroundColor Red "[failed]"
            Write-Warning "could not create clone with $cmdresult"
            break
            }
		}	
	End
	{
		
	}
}


function New-VMXClone
{
	[CmdletBinding(DefaultParameterSetName = '1',HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Snapshot')]
		$BaseSnapshot,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$Config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$CloneName,
		[Parameter(Mandatory = $false)][ValidateScript({ Test-Path -Path $_ })]$Clonepath,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$Path
	)
	Begin
	{
	}
	Process
	{
		#foreach ($config in $getconfig)
		if (!$Clonepath) { $Clonepath = Split-Path -Path $Path -Parent }
		Write-Verbose $ClonePath
		$CloneConfig =  Join-Path "$Clonepath" (Join-Path $Clonename "$CloneName.vmx")
		$TemplateVM = Split-Path -Leaf $config
		$Templatevm = $TemplateVM -replace ".vmx",""
		Write-Verbose $CloneConfig
		Write-Host -ForegroundColor Gray " ==>creating Fullclone from $TemplateVM $Basesnapshot for " -NoNewline
		Write-Host -ForegroundColor Magenta $Clonename -NoNewline
		Write-Verbose "creating Full Clone  $Clonename for $Basesnapshot in $Cloneconfig"
		do
			{
			($cmdresult = &$vmrun clone $config $Cloneconfig full $BaseSnapshot $Clonename) #  2>&1 | Out-Null
			}
		until ($VMrunErrorCondition -notcontains $cmdresult)
        if ($LASTEXITCODE -eq 0)
            {
			Write-Host -ForegroundColor Green "[success]"
			$object = New-Object psobject
			$object | Add-Member -MemberType 'NoteProperty' -Name CloneName -Value $Clonename
			$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $Cloneconfig
			$object | Add-Member -MemberType 'NoteProperty' -Name Path -Value "$Clonepath\$Clonename"
			Write-Output $Object
			}
        else
            {
			Write-Host -ForegroundColor Red "[failed]"
            Write-Warning "could not create clone with $cmdresult"
            break
            }

		}	
	End
	{
		
	}
}

function Get-VMXSnapshot
{
	[CmdletBinding(DefaultParametersetName = "2",
    HelpUri = "http://labbuildr.bottnet.de/modules/get-vmxsnapshot/" )]
	param
	(
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('TemplateName')][string]$VMXName,
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$Path = "$Global:vmxdir",
		[Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$config,
        [Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][switch]$Tree

	)
	
	
	Begin
	{
		
		
	}
	Process
	{
		
		
		
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $config = Get-VMX -VMXName $VMXname -Path $Path }
			"2"
			{
				#$snapconfig = $config
				}
		}
		
		if ($Tree.IsPresent)
            {
            $parameter = "showTree"
            }
		if ($config)
		{
			do
				{
				($cmdresult = &$vmrun listsnapshots $config $parameter) 2>&1 | Out-Null
				}
				
			until ($VMrunErrorCondition -notcontains $cmdresult)
			Write-Verbose $cmdresult[0]
			Write-Verbose $cmdresult[1]
			Write-Verbose $cmdresult.count
			If ($cmdresult.count -gt 1)
				{
				$Snaphots = $cmdresult[1..($cmdresult.count)]
				foreach ($Snap in $Snaphots)
					{
					$object = New-Object psobject
					$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value (Get-ChildItem -Path $Config).Basename
					$object | Add-Member -Type 'NoteProperty' -Name Snapshot -Value $Snap
				    $object | Add-Member -Type 'NoteProperty' -Name Config -Value $Config
				    $object | Add-Member -MemberType NoteProperty -Name Path -Value (Get-ChildItem -Path $Config).Directory
				    Write-Output $object
					}
				}
            else
                {
                    Write-Warning "No Snapshot found for VMX $VMXName"
                }
		}
	}
	End
	{
		
	}
}

<#
	.SYNOPSIS
		A brief description of the Remove-VMXSnaphot function.

	.DESCRIPTION
		deleteSnapshot           Path to vmx file     Remove a snapshot from a VM
		                         Snapshot name
		                         [andDeleteChildren]

	.PARAMETER  Snaphot
		A description of the Snaphot parameter.

	.PARAMETER  VMXName
		A description of the VMXName parameter.

	.PARAMETER  Children
		A description of the Children parameter.

	.EXAMPLE
		PS C:\> Remove-VMXSnaphot -Snaphot $value1 -VMXName $value2
		'This is the output'
		This example shows how to call the Remove-VMXSnaphot function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Remove-VMXSnapshot
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$Path = "$Global:vmxdir",
		[Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$config,
		[Parameter(Mandatory = $True, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('Snapshotname')][string]$Snapshot,
		[Parameter(Mandatory = $false)][switch]$Children
	)
	
	Begin
	{
	}
	Process
	{
		Write-Verbose "Snapshot in Process: $Snapshotname"
		Write-Verbose "VMXName in Process: $VMXName"
		if ($Children.IsPresent)
            {
            $parameter = "andDeleteChildren"
            }
			do
			    {
				Write-Verbose $config
				Write-Verbose $Snapshot
				($cmdresult = &$vmrun deleteSnapshot $config $Snapshot $parameter) # 2>&1 | Out-Null
				#write-log "$origin snapshot  $cmdresult"
			    }
			until ($VMrunErrorCondition -notcontains $cmdresult)
            if ($LASTEXITCODE -eq 0)
                {
			    $object = New-Object psobject
			    $object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMXname
			    $object | Add-Member -Type 'NoteProperty' -Name Snapshot -Value $Snapshot  
			    $object | Add-Member -Type 'NoteProperty' -Name SnapshotState -Value "removed$parameter"
			    Write-Output $object
                }
            else
                {
                Write-Warning "exit with status $LASTEXITCODE $cmdresult"
                }
		
	}
	End
	{
		
	}
}

<#	
	.SYNOPSIS
		A brief description of the start-vmx function.
	
	.DESCRIPTION
		A detailed description of the start-vmx function.
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.EXAMPLE
		PS C:\> start-vmx -Name 'vmname'
	
	.NOTES
		Additional information about the function.
#>
function Start-VMX
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
		[Parameter(ParameterSetName = "1", Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		#[Parameter(ParameterSetName = "2",Position = 2,Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "3", Mandatory = $false)]		
        [Alias('Clonename')][string]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
		[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('VMXUUID')][string]$UUID,
       # [Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]
        [Parameter(ParameterSetName = "3", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
        [Parameter(Mandatory=$false)]$Path,
        [Parameter(Mandatory=$false)][Switch]$nowait,
        [Parameter(Mandatory=$false)][Switch]$nogui
	)
	begin
	{
	
	}
	
	process
	{
		
			switch ($PsCmdlet.ParameterSetName)
			{
				"1"
				{
                Write-Verbose $_
                if ($VMXName -match "\*")
                    {
                    Write-Warning "Wildcard names are not allowed, use get-vmx $VMXName | start-vmx instead"
                    break
                    }
                $vmx = Get-VMX -VMXName $VMXname -UUID $UUID
                }
				
				"2"
				{
                Write-Verbose $_ 
                $vmx = Get-VMX -Path $path
                }
				"3"
				{
                Write-Verbose " by config with $_ "
                $vmx = Get-VMX -config $config
                }

				
			}
		
		if ($VMX)
		{
		Write-Verbose "Testing VM $VMXname Exists and stopped or suspended"
		if (($vmx) -and ($vmx.state -ne "running"))
		{
            [int]$vmxhwversion = (Get-VMXHWVersion -config $vmx.config).hwversion
            if ($vmxHWversion -le $vmwareversion.major)
            {
                Write-Verbose "Checking State for $vmxname : $($vmx.vmxname)  : $($vmx.state)"
                Write-Verbose "creating Backup of $($vmx.config)"
                Copy-Item -Path $vmx.config -Destination "$($vmx.config).bak" 
	    		Write-Verbose -Message "setting Startparameters for $vmxname"
	    		$VMXStarttime = Get-Date -Format "MM.dd.yyyy hh:mm:ss"
	    		$content = Get-Content $vmx.config | where { $_ -ne "" }
	    		$content = $content | where { $_ -NotMatch "guestinfo.hypervisor" }
	    		$content += 'guestinfo.hypervisor = "' + $env:COMPUTERNAME + '"'
	    		$content = $content | where { $_ -NotMatch "guestinfo.powerontime" }
	    		$content += 'guestinfo.powerontime = "' + $VMXStarttime + '"'
                $content = $content |where { $_ -NotMatch "guestinfo.vmwareversion" }
                $content += 'guestinfo.vmwareversion = "' + $Global:vmwareversion + '"'
	    		set-Content -Path $vmx.config -Value $content -Force
		    	Write-Verbose "starting VM $vmxname"
				Write-Host -ForegroundColor Gray " ==>starting Virtual Machine " -NoNewline
				Write-Host -ForegroundColor Magenta $VMX.vmxname -NoNewline
		    	if ($nowait.IsPresent)
                    {
                    if ($nogui.IsPresent)
                        {
                        Start-Process -FilePath $vmrun -ArgumentList "start $($vmx.config) nogui" -NoNewWindow
                        }
                    else
                        {
                        Start-Process -FilePath $vmrun -ArgumentList "start $($vmx.config) " -NoNewWindow
                        }
                    }
                else
                    {
                    do
		    	        {
		    		    if ($nogui.IsPresent)
                            {
                            $cmdresult = &$vmrun start $vmx.config nogui #  2>&1 | Out-Null
                            }
                        else
                            {
		    		        $cmdresult = &$vmrun start $vmx.config #  2>&1 | Out-Null
                            }
		    	        }
    			    until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
                    }
                if ($LASTEXITCODE -eq 0) 
	                {
					Write-Host -ForegroundColor Green "[success]"
	    		    $object = New-Object psobject
	    		    $object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMX.VMXname
	    		    $object | Add-Member -Type 'NoteProperty' -Name Status -Value "Started"
                    $object | Add-Member -Type 'NoteProperty' -Name Starttime -Value $VMXStarttime
	    		    Write-Output $object 
                }
                else
                    {
                    Write-Warning "There was an error starting the VM: $cmdresult"
                    }
		    }
            else { Write-Error "Vmware version does not match, need version $vmxhwversion "	}
		}
		elseif ($vmx.state -eq "running") { Write-Verbose "VM $VMXname already running" } # end elseif
		
		else { Write-Verbose "VM $VMXname not found" } # end if-vmx
	}	
	}# end process
	end { }
}#end start-vmx

<#	
	.SYNOPSIS
		A brief description of the Stop-VMX function.
	
	.DESCRIPTION
		A detailed description of the Stop-VMX function.
	
	.PARAMETER Mode
		Valid modes are Soft ( shutdown ) or Stop (Poweroff)
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.EXAMPLE
		PS C:\> Stop-VMX -Mode $value1 -Name 'Value2'
	
	.NOTES
		Additional information about the function.
#>
function Stop-VMX{
	[CmdletBinding(DefaultParameterSetName = '2',HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)]
        [Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)]
        [Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $false,ValueFromPipelineByPropertyName = $True)]
        [Alias('VMXUUID')][string]$UUID,
		[Parameter(ParameterSetName = "2", Mandatory = $true,ValueFromPipelineByPropertyName = $True)]$config,
		[Parameter(HelpMessage = "Valid modes are Soft ( shutdown ) or Stop (Poweroff)", Mandatory = $false)]
		[ValidateSet('Soft', 'Hard')]$Mode
		)
		begin
		{
			
		}
		
		process
		{
			
			switch ($PsCmdlet.ParameterSetName)
			{
				"1"
				{ 
                Write-Verbose "Getting vmx by Config and UUID"
                $vmx = Get-VMX -VMXName $VMXname -UUID $UUID  -Path $config
				$state = $VMX.state
            	}
				
				"2"
				{
                Write-Verbose "Parameter Set 2"
                Write-Verbose "Config: $config"
                $state = (get-vmx -config $config).state
                }
				
			}
			
    Write-Verbose "State for $($VMXname) : $State"

	if ($state -eq "running")
	{
    $Origin = $MyInvocation.MyCommand
	do
        {
	
		($cmdresult = &$vmrun stop $config $Mode) # 2>&1 | Out-Null
		Write-Verbose "$Origin $vmxname $cmdresult"
	    }
	until ($VMrunErrorCondition -notcontains $cmdresult)
	$object = New-Object psobject
	$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMXname
	$object | Add-Member -Type 'NoteProperty' -Name Status -Value "Stopped $Mode"
	Write-Output $object

    } # end if-vmx
    else 
        {
        Write-Warning "VM $vmxname not running"
        } # end if-vmx
#}#end foreach
} # end process
}

<#
	.SYNOPSIS
		A brief description of the Suspend-VMX function.

	.DESCRIPTION
		A detailed description of the Suspend-VMX function.

	.PARAMETER  name
		Name of the VM

	.EXAMPLE
		PS C:\> Suspend-VMX -name 'Value1'
		'This is the output'
		This example shows how to call the Suspend-VMX function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Suspend-VMX
{
	[CmdletBinding(DefaultParameterSetName = '2',HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(


		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('VMXUUID')][string]$UUID,
		[Parameter(ParameterSetName = "3", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$Path



<#

		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'Specify name for the VM to Suspend',
				   ParameterSetName = '1')]
		[Alias('NAME','CloneName')]
		[string]$VMXname
#>
	)
	
	Begin
	{
			
	}
	Process
	{
			if (($vmx = Get-VMX -Path $Path ) -and ($vmx.state -eq "running"))
			{
				Write-Verbose "Checking State for $($vmx.vmxname)  : $($vmx.state)"
				$Origin = $MyInvocation.MyCommand
				do
				{
					$cmdresult = &$vmrun suspend $vmx.config # 2>&1 | Out-Null
					write-verbose "$Origin suspend $VMXname $cmdresult"
				}
				until ($VMrunErrorCondition -notcontains $cmdresult)
	    		$VMXSuspendtime = Get-Date -Format "MM.dd.yyyy hh:mm:ss"
				$object = New-Object psobject
				$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMX.VMXname
				$object | Add-Member -Type 'NoteProperty' -Name Status -Value "Suspended"
                $object | Add-Member -Type 'NoteProperty' -Name Suspendtime -Value $VMXSuspendtime
                Write-Output $object
                $content = Get-Content $vmx.config | where { $_ -ne "" }
	    		$content = $content | where { $_ -NotMatch "guestinfo.suspendtime" }
	    		$content += 'guestinfo.suspendtime = "' + $VMXSuspendtime + '"'
                sleep 2
	    		set-Content -Path $vmx.config -Value $content -Force
			}
		

		
	}#end process
}#end function


<#
	.SYNOPSIS
		A brief description of the Set-vmxtemplate function.

	.DESCRIPTION
		A detailed description of the Set-vmxtemplate function.

	.PARAMETER  vmxname
		A description of the vmxname parameter.

	.PARAMETER  config
		A description of the config parameter.

	.EXAMPLE
		PS C:\> Set-vmxtemplate -vmxname $value1 -config $value2
		'This is the output'
		This example shows how to call the Set-vmxtemplate function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Set-VMXTemplate
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
		[Parameter( Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('vmxconfig')]$config,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
        [Parameter(Mandatory = $false)][switch]$unprotect
		# [Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config
	)
	begin
	{	 }
	
	process
	
		{
			if ((get-vmx -Path $config).state -eq "stopped")
            {
			if (Test-Path $config)
			{
			


            Write-verbose $config
			$content = Get-Content -Path $config | where { $_ -ne "" }
		    $content = $content | where { $_ -NotMatch "templateVM" }
		    $object = New-Object psobject
			$object | Add-Member -Type 'NoteProperty' -Name VMXName -Value $VMXName	
			$object | Add-Member -Type 'NoteProperty' -Name VMXconfig -Value $config			
            if ($unprotect.IsPresent)
                {
				Write-Host -ForegroundColor Gray " ==>releasing Template mode for " -NoNewline
				Write-Host -ForegroundColor Magenta $VMXName -NoNewline
                $content += 'templateVM = "FALSE"'
                $object | Add-Member -Type 'NoteProperty' -Name Template -Value $False
                }
            else
                {
				Write-Host -ForegroundColor Gray " ==>setting Template mode for " -NoNewline
				Write-Host -ForegroundColor Magenta $VMXName -NoNewline
                $content += 'templateVM = "TRUE"'
			    $object | Add-Member -Type 'NoteProperty' -Name Template -Value $True
                }
            set-Content -Path $config -Value $content -Force
			Write-Host -ForegroundColor Green "[success]"
			Write-Output $object
			}
            }
            else
            {
            Write-Warning "VM must be in stopped state"
            }

	}
		
		
	
	End
	{
		
	}
}

<#
	.SYNOPSIS
		A brief description of the Get-VMXTemplate function.

	.DESCRIPTION
		Gets Template VM(s) for Rapid Cloning

	.PARAMETER  TemplateName
		Please Specify Template Name

	.PARAMETER  VMXUUID
		A description of the VMXUUID parameter.

	.PARAMETER  ConfigPath
		A description of the ConfigPath parameter.

	.EXAMPLE
		PS C:\> Get-VMXTemplate -TemplateName $value1 -VMXUUID $value2
		'This is the output'
		This example shows how to call the Get-VMXTemplate function with named parameters.

	.OUTPUTS
		psobject

	.NOTES
		Additional information about the function or script.

#>
function Get-VMXTemplate
{
	[CmdletBinding(DefaultParameterSetName = '1',HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config
	)
	begin
{	
		
	}
	process
	{

		$Content = Get-Content $config | where { $_ -ne '' }
		if ($content -match 'templateVM = "TRUE"')
		{
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name TemplateName -Value (Get-ChildItem $config).basename
		$object | Add-Member -MemberType NoteProperty -Name GuestOS -Value (Get-VMXGuestOS -config $config).GuestOS
		$object | Add-Member -MemberType NoteProperty -Name UUID -Value (Get-VMXUUID -config $config).uuid
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name Template -Value $true
		}
	
	Write-Output $object

	}
	end { }
	
	
}

<#
	.SYNOPSIS
		synopsis

	.DESCRIPTION
		description

	.PARAMETER  config
		A description of the config parameter.

	.EXAMPLE
		PS C:\> Set-VMXNetworkAdapter -config $value1
		'This is the output'
		This example shows how to call the Set-VMXNetworkAdapter function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Set-VMXNetworkAdapter
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateRange(0,9)][int]$Adapter,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet('nat', 'bridged','custom','hostonly')]$ConnectionType,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet('e1000e','vmxnet3','e1000')]$AdapterType,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][int]$PCISlot
	)
	
	Begin
	{
		
	}
	Process
	{
        if ((get-vmx -Path $config).state -eq "stopped")
        {
		if (!$PCISlot)
            {
            $PCISlot = ((1+$Adapter) * 64)
            }
		$Content = Get-Content -Path $config
		Write-verbose "ethernet$Adapter.present"
		if (!($Content -match "ethernet$Adapter.present")) { Write-Warning "Adapter not present, will be added" }
		Write-Host -ForegroundColor Gray " ==>configuring Ethernet$Adapter as $AdapterType with $ConnectionType for " -NoNewline
		write-host -ForegroundColor Magenta $VMXName -NoNewline
		Write-Host -ForegroundColor Green "[success]"
		$Content = $Content -notmatch "ethernet$Adapter"
        $Addnic = @('ethernet'+$Adapter+'.present = "TRUE"')
        $Addnic += @('ethernet'+$Adapter+'.connectionType = "'+$ConnectionType+'"')
        $Addnic += @('ethernet'+$Adapter+'.wakeOnPcktRcv = "FALSE"')
        $Addnic += @('ethernet'+$Adapter+'.pciSlotNumber = "'+$PCISlot+'"')
        $Addnic += @('ethernet'+$Adapter+'.virtualDev = "'+$AdapterType+'"')
        $Content += $Addnic
        $Content | Set-Content -Path $config
        $object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name Adapter -Value "Ethernet$Adapter"
		$object | Add-Member -MemberType NoteProperty -Name AdapterType -Value $AdapterType
		$object | Add-Member -MemberType NoteProperty -Name ConnectionType -Value $ConnectionType
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config

        Write-Output $object
		if ($ConnectionType -eq 'custom')
            {
            Write-Warning "Using Custom Network for Ethernet$($Adapter), make sure it is connect to the right VMNet (Set-VMXVNet)" 
            }
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }

	}
	End
	{
		
	}
}

<#
	.SYNOPSIS
		synopsis

	.DESCRIPTION
		description

	.PARAMETER  config
		A description of the config parameter.

	.EXAMPLE
		PS C:\> Connect-VMXNetworkAdapter -config $value1
		'This is the output'
		This example shows how to call the Set-VMXNetworkAdapter function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Connect-VMXNetworkAdapter
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateRange(0,9)][int]$Adapter
	)
	
	Begin
	{
		
	}
	Process
	{
        if ((get-vmx -Path $config).state -eq "stopped")
        {
		$Content = Get-Content -Path $config
		Write-verbose "ethernet$Adapter.present"
		if (!($Content -match "ethernet$Adapter.present")) { Write-Warning "Adapter not present" }
        else
            {
		    $Content = $Content -notmatch "ethernet$Adapter.StartConnected"
            $Content += 'ethernet'+$Adapter+'.StartConnected = "True"'
            $Content | Set-Content -Path $config
            $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		    $object | Add-Member -MemberType NoteProperty -Name Adapter -Value "Ethernet$Adapter"
		    $object | Add-Member -MemberType NoteProperty -Name Connected -Value True
            Write-Output $object
            }
        }
        
		else
        {
        Write-Warning "VM must be in stopped state"
        }

	}
	End
	{
		
	}
}


function Connect-VMXcdromImage
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$ISOfile,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][ValidateSet('ide','sata')]$Contoller = 'sata',
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][ValidateSet('0:0','0:1','1:0','1:1')]$Port = '0:1',
        [Parameter(Mandatory = $false)][switch]$connect=$true
	)
	
	Begin
	{
		
	}
	Process
	{
        if ((get-vmx -Path $config).state -eq "stopped")
        {
		$Content = Get-Content -Path $config
		Write-verbose "Checking for $($Contoller)$($Port).present"
		if (!($Content -notmatch " $($Contoller)$($Port).present"))
             {
             Write-Warning "Controller $($Contoller)$($Port) not present"
             }
        else
            {
            $object = New-Object -TypeName psobject		    
            $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
	        $object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config
            $object | Add-Member -MemberType NoteProperty -Name Controller -Value "$($Contoller)$($Port)"
            $Content = $Content -notmatch "$($Contoller)$($Port)"
            $Content += "$($Contoller)$($Port)"+'.present = "TRUE"'
            $Content += "$($Contoller)$($Port)"+'.autodetect = "TRUE"'
            If ($connect.IsPresent -and $ISOfile)
                {
                $Content += "$($Contoller)$($Port)"+'.deviceType = "cdrom-image"'
                $Content += "$($Contoller)$($Port)"+'.startConnected = "TRUE"'
                $Content += "$($Contoller)$($Port)"+'.fileName = "'+$ISOfile+'"'
                $object | Add-Member -MemberType NoteProperty -Name ISO -Value $ISOfile
                
                }
            else
                {
                $Content += "$($Contoller)$($Port)"+'.deviceType = "cdrom-raw"'
                $Content += "$($Contoller)$($Port)"+'.startConnected = "FALSE"'
                }
            $Content | Set-Content -Path $config
	        $object | Add-Member -MemberType 'NoteProperty' -Name Connected -Value $connect
            Write-Output $object


            }
        }
        
		else
        {
        Write-Warning "VM must be in stopped state"
        }

	}
	End
	{
		
	}
}


<#
	.SYNOPSIS
		synopsis

	.DESCRIPTION
		description

	.PARAMETER  config
		A description of the config parameter.

	.EXAMPLE
		PS C:\> Disconnect-VMXNetworkAdapter -config $value1
		'This is the output'
		This example shows how to call the Set-VMXNetworkAdapter function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Disconnect-VMXNetworkAdapter
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateRange(0,9)][int]$Adapter
	)
	
	Begin
	{
		
	}
	Process
	{
        if ((get-vmx -Path $config).state -eq "stopped")
        {
		$Content = Get-Content -Path $config
		Write-verbose "ethernet$Adapter.present"
		if (!($Content -match "ethernet$Adapter.present")) { Write-Warning "Adapter not present" }
        else
            {
		    $Content = $Content -notmatch "ethernet$Adapter.StartConnected"
            $Content += 'ethernet'+$Adapter+'.StartConnected = "False"'
            $Content | Set-Content -Path $config
            $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		    $object | Add-Member -MemberType NoteProperty -Name Adapter -Value "Ethernet$Adapter"
		    $object | Add-Member -MemberType NoteProperty -Name Connected -Value False
            Write-Output $object
            }
        }
        
		else
        {
        Write-Warning "VM must be in stopped state"
        }

	}
	End
	{
		
	}
}


function Set-VMXVnet
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$config,
		[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateRange(0, 19)][int]$Adapter,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet('vmnet1','vmnet2','vmnet3','vmnet4','vmnet5','vmnet6','vmnet7','vmnet9','vmnet10','vmnet11','vmnet12','vmnet13','vmnet14','vmnet15','vmnet16','vmnet17','vmnet18','vmnet19')][Alias('VMnet')]$Vnet
	)
	
	Begin
	{
		
	}
	Process
	{
		if ((get-vmx -Path $config).state -eq "stopped")
        {
        $Content = Get-Content -Path $config
		Write-verbose "ethernet$Adapter.present"
		if (!($Content -match "ethernet$Adapter.present")) { write-error "Adapter not present " }
		$Content = ($Content -notmatch "ethernet$Adapter.vnet")
		$Content = ($Content -notmatch "ethernet$Adapter.connectionType")
		Set-Content -Path $config -Value $Content
		$Addcontent = 'ethernet' + $Adapter + '.vnet = "' + $vnet + '"'
		#, 'ethernet' + $Adapter + '.connectionType = "custom"', 'ethernet' + $Adapter + '.wakeOnPcktRcv = "FALSE"', 'ethernet' + $Adapter + '.pciSlotNumber = "' + $PCISlot + '"', 'ethernet' + $Adapter + '.virtualDev = "e1000e"')
		Write-Verbose "setting $Addcontent"
		$Addcontent | Add-Content -Path $config
		$AddContent = 'Ethernet'+$Adapter+'.connectionType = "custom"'
		Write-Verbose "setting $Addcontent"
		$Addcontent | Add-Content -Path $config
		Write-Host -ForegroundColor Gray -NoNewline " ==>setting ethernet$Adapter to $Vnet for "
		Write-Host -ForegroundColor Magenta $VMXName -NoNewline
	    Write-Host -ForegroundColor Green "[success]"
		$object = New-Object psobject
		$object | Add-Member -MemberType 'NoteProperty' -Name VMXname -Value $VMXName
   		$object | Add-Member -MemberType 'NoteProperty' -Name Adapter -Value "ethernet$Adapter"
		$object | Add-Member -MemberType 'NoteProperty' -Name VirtualNet -Value $vnet
		$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config

		Write-Output $object
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }

	}
	End
	{
		
	}
}

<#
	.SYNOPSIS
		A brief description of the Set-VMXserial function.

	.DESCRIPTION
		A detailed description of the Set-VMXserial function.

	.PARAMETER  config
		A description of the config parameter.

	.PARAMETER  VMXname
		A description of the VMXname parameter.

	.EXAMPLE
		PS C:\> Set-VMXserial -config $value1 -VMXname $value2
		'This is the output'
		This example shows how to call the Set-VMXserial function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Remove-VMXserial
{
	[CmdletBinding()]
	param
	(
		[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		$config,
		[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		[Alias('Clonename')]
		$VMXname,
		[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		$Path
	)
	
	
	
	
	
	begin { }
	process
	{
		
		$content = Get-Content -Path $config | where { $_ -Notmatch "serial0" }
		#	$AddSerial = @('serial0.present = "True"', 'serial0.fileType = "pipe"', 'serial0.fileName = "\\.\pipe\\console"', 'serial0.tryNoRxLoss = "TRUE"')
		Set-Content -Path $config -Value $Content
		#	$AddSerial | Add-Content -Path $config
		$object = New-Object psobject
		$object | Add-Member -MemberType 'NoteProperty' -Name CloneName -Value $VMXname
		$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config
		$object | Add-Member -MemberType 'NoteProperty' -Name Path -Value $Path
		
		Write-Output $Object
	}
	end { }
}

function Set-VMXserialPipe
{
	[CmdletBinding()]
	param
	(
	[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
	$config,
	[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
	[Alias('Clonename')]
	$VMXname,
	[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
	$Path
	)

    begin {}
	process
	{
		if ((get-vmx -Path $config).state -eq "stopped")
        {
		$content = Get-Content -Path $config | where { $_ -Notmatch "serial0"}
		$AddSerial = @('serial0.present = "True"', 'serial0.fileType = "pipe"', 'serial0.fileName = "\\.\pipe\\console"', 'serial0.tryNoRxLoss = "TRUE"')
		Set-Content -Path $config -Value $Content
		$AddSerial | Add-Content -Path $config
		$object = New-Object psobject
		$object | Add-Member -MemberType 'NoteProperty' -Name CloneName -Value $VMXname
		$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config
		$object | Add-Member -MemberType 'NoteProperty' -Name Path -Value $Path
		
		Write-Output $Object
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }

	}
	end { }
}
function Remove-vmx {
	<#
		.SYNOPSIS
			A brief description of the function.

		.DESCRIPTION
			A detailed description of the function.

		.PARAMETER  ParameterA
			The description of the ParameterA parameter.

		.PARAMETER  ParameterB
			The description of the ParameterB parameter.

		.EXAMPLE
			PS C:\> Get-Something -ParameterA 'One value' -ParameterB 32

		.EXAMPLE
			PS C:\> Get-Something 'One value' 32

		.INPUTS
			System.String,System.Int32

		.OUTPUTS
			System.String

		.NOTES
			Additional information about the function go here.

		.LINK
			about_functions_advanced

		.LINK
			about_comment_based_help

	#>


	[CmdletBinding(DefaultParametersetName = "2",
                    SupportsShouldProcess=$true,
                    ConfirmImpact='high')]
	param (
#	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('VMNAME''NAME','CloneName')]$VMXName,	
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config
#	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$state
	)
	begin {

    $Origin = $MyInvocation.MyCommand
    Write-Verbose $Origin
 
    }
	process {
	##
    if (!($config)) { Write-Warning "$Origin : VM does not exist"}
    Write-Verbose $config
	switch ($PsCmdlet.ParameterSetName)
			{
				"1"
				{ $vmx = Get-VMX -VMXName $VMXname }# -UUID $UUID }
				
				"2"
				{$VMX = get-vmx -Path $config }
				
			}
		
		Write-Verbose "Testing VM $VMXname Exists and stopped or suspended"
		if ($vmx.state -eq "running")
		{
			Write-Verbose "Checking State for $vmxname : $state"
			Write-Verbose $config
			Write-Verbose -Message "Stopping vm $vmxname"
			stop-vmx -config $config -VMXName $VMXName  -mode hard #-state $vmx.state
		}
	#####

    $commit = 0
    if ($ConfirmPreference -match "none")
        { 
        $commit = 1 
        }
    else
        {
        $commit = Get-yesno -title "Confirm VMX Deletion" -message "This will remove the VM $VMXNAME Completely"
        }
    Switch ($commit)
        {
            1
                {
	            do
	                {
		            $cmdresult = &$vmrun deleteVM "$config" # 2>&1 | Out-Null
        		    write-verbose "$Origin deleteVM $vmname $cmdresult"
                    write-verbose $LASTEXITCODE
	                }
	            until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
                if ($cmdresult -match "Error: This VM is in use.")
                    {
                    write-warning "$cmdresult Please close VMX $VMXName in Vmware UI and try again"
                    }
        
                if ($LASTEXITCODE -ne 0)
                    {
                    Write-Warning $VMXname
                    Write-Warning $cmdresult
                    }
                else       
                    {
                    Remove-Item -Path $vmx.Path -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
	                $object = New-Object psobject
	                $object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMXname
	                $object | Add-Member -Type 'NoteProperty' -Name Status -Value "removed"
	                Write-Output $object
                    }
                }
            0
                {
                Write-Warning "VMX Deletion refused by user for VMX $VMXNAME"
                break
                }      
        }





######	


}#end process
	
	
	end{}
	} 




function New-VMXScsiDisk
{
[CmdletBinding()]
param (
	[Parameter(ParameterSetName = "1",
                HelpMessage = "Please specify a Size between 2GB and 2000GB",
                Mandatory = $true, ValueFromPipelineByPropertyName = $True)][validaterange(2MB,8192GB)][int64]$NewDiskSize,	
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][string]$NewDiskname,
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$Path,
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('Config','CloneConfig')]$vmxconfig

)
begin {
       }
process {
	Write-Host -ForegroundColor Gray " ==>creating new $($NewDiskSize/1GB)GB SCSI Disk $NewDiskName at $Path" -NoNewline
    if (!$NewDiskname.EndsWith(".vmdk")) { $NewDiskname = $NewDiskname+".vmdk" }
	$Diskpath = Join-Path $Path $NewDiskname    
    if ($PSCmdlet.MyInvocation.BoundParameters["debug"].IsPresent)
        {
        $returncommand = & $Global:VMware_vdiskmanager -c -s "$($NewDiskSize/1MB)MB" -t 0 -a lsilogic $Diskpath # 2>&1 
        write-host -ForegroundColor Cyan "Debug message start"
        Write-Host -ForegroundColor White "Command Returned: $returncommand"
        Write-Host -ForegroundColor White "Exitcode: $LASTEXITCODE"
        Write-Host -ForegroundColor White "Running $Global:vmwareversion"
        Write-Host -ForegroundColor White "Machines Dir $Global:vmxdir"
        Write-Host -ForegroundColor Cyan "Debug Message end"
        pause
        }
    else
        {
        $returncommand = &$Global:VMware_vdiskmanager -c -s "$($NewDiskSize/1MB)MB" -t 0 -a lsilogic $Diskpath  #2>&1 
        }

    if ($LASTEXITCODE -eq 0)
        {
	    Write-Host -ForegroundColor Green "[success]"
        $object = New-Object -TypeName psobject
        $object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
        $object | Add-Member -MemberType NoteProperty -Name Disktype -Value "lsilogic"
        $object | Add-Member -MemberType NoteProperty -Name Diskname -Value $NewDiskname
        $object | Add-Member -MemberType NoteProperty -Name Size -Value "$($NewDiskSize/1GB)GB"
        $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
        $object | Add-Member -MemberType NoteProperty -Name Config -Value $vmxconfig
        Write-Output $object
        if ($PSCmdlet.MyInvocation.BoundParameters["debug"].IsPresent)
            {
            Write-Host -ForegroundColor White $object
            }

        }
    else 
        {
        Write-Error "Error creating disk"
        Write-Host -ForegroundColor White "Command Returned: $returncommand"
        return
        }
    }
end {
    
    }
} 

###
function Remove-VMXScsiDisk
{
[CmdletBinding()]
param (
	#[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][string][Alias('Filenme')]$Diskname,
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('VMXconfig')]$config,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$LUN,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$Controller
)

###




begin {

    
       }
process 
    {
   if ((get-vmx -Path $config).state -eq "stopped")
        {
        $vmxConfig = Get-VMXConfig -config $config
        $vmxconfig = $vmxconfig | where {$_ -notmatch "scsi$($Controller):$($LUN)"}
        Write-Verbose "Removing Disk #$Disk lun $lun from controller $Controller"
        $vmxConfig | set-Content -Path $config
        $object = New-Object -TypeName psobject
        $object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
        $object | Add-Member -MemberType NoteProperty -Name Cotroller -Value $Controller
        $object | Add-Member -MemberType NoteProperty -Name LUN -Value $LUN
        $object | Add-Member -MemberType NoteProperty -Name Status -Value "removed"
        Write-Output $object
        }
    else
        {
        Write-Warning "VM must be in stopped state"
        }
    }
end {
    
    }
} 


###
function Add-VMXScsiDisk
{
[CmdletBinding()]
param (
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][string][Alias('Filenme')]$Diskname,
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('VMXconfig')]$config,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$LUN,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$Controller,
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][switch]$Shared
)
begin {

    
       }
process 
    {
    Write-Verbose "adding Disk #$Disk with $Diskname to $VMXName as lun $lun controller $Controller"
	Write-Host -ForegroundColor Gray " ==>adding Disk $Diskname at Controller $Controller LUN $LUN to " -NoNewline
	Write-Host -ForegroundColor Magenta $VMXName -NoNewline
    $vmxConfig = Get-VMXConfig -config $config
    $vmxconfig = $vmxconfig | where {$_ -notmatch "scsi$($Controller):$($LUN)"}
    $AddDrives  = @('scsi'+$Controller+':'+$LUN+'.present = "TRUE"')
    $AddDrives += @('scsi'+$Controller+':'+$LUN+'.deviceType = "disk"')
    $AddDrives += @('scsi'+$Controller+':'+$LUN+'.fileName = "'+$diskname+'"')
    $AddDrives += @('scsi'+$Controller+':'+$LUN+'.mode = "persistent"')
    $AddDrives += @('scsi'+$Controller+':'+$LUN+'.writeThrough = "false"')
    if ($Shared.IsPresent)
        {
        $vmxconfig = $vmxconfig | where {$_ -notmatch "disk.locking"}
        $AddDrives += @('disk.locking = "false"')
        $AddDrives += @('scsi'+$Controller+':'+$LUN+'.shared = "true"')
        }
    $vmxConfig += $AddDrives
    $vmxConfig | set-Content -Path $config
    Write-Host -ForegroundColor Green "[success]"
    $object = New-Object -TypeName psobject
    $object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
    $object | Add-Member -MemberType NoteProperty -Name Disktype -Value "lsilogic"
    $object | Add-Member -MemberType NoteProperty -Name Filename -Value $Diskname
    $object | Add-Member -MemberType NoteProperty -Name Cotroller -Value $Controller
    $object | Add-Member -MemberType NoteProperty -Name LUN -Value $LUN
    $object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
    $object | Add-Member -MemberType NoteProperty -Name Shared -Value $Shared.IsPresent
    Write-Output $object
    }
end {
    
    }
} 
###
function Set-VMXscenario
{
	[CmdletBinding()]
	param
	(   [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$path,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)][ValidateRange(1,9)][int]$Scenario,
		[Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $False)][Validatelength(1, 10)][string]$Scenarioname
		
	)
	
	Begin
	{

	}
	Process
	{
		if ((get-vmx -Path $config).state -eq "stopped")
        {
        Copy-Item -Path $config -Destination "$($config).bak"
        $Content = Get-Content -Path $config
		$Content = ($Content -notmatch "guestinfo.Scenario$Scenario")
        $content += 'guestinfo.scenario'+$Scenario+' = "'+$ScenarioName+'"'
		Set-Content -Path $config -Value $Content
        $object = New-Object -TypeName psobject
		$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMX.VMXname
        $object | Add-Member -MemberType NoteProperty -Name Scenario -Value $Scenario
		$object | Add-Member -MemberType NoteProperty -Name Scenarioname -Value $scenarioname
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
        $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
        Write-Output $object
		# $content
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }

	}
	End
	{}
}
		




function Get-VMXscenario
{
	[CmdletBinding(DefaultParameterSetName = '1')]
	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $False, ValueFromPipelineByPropertyName = $True)]$Path
	)
	begin
{	
		
	}
	process
	{
        
  	    $vmxconfig = Get-VMXConfig -config $config
		$ObjectType = "Scenario"
		$patterntype = ".scenario\d{1,9}"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "guestinfo.scenario\d{1,9}" -vmxconfig $vmxconfig -name "Scenario" -value "Scenarioname" -patterntype $patterntype
		foreach ($Scenarioset in $value)
		{
			$object = New-Object -TypeName psobject
			$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
            $object | Add-Member -MemberType NoteProperty -Name Scenario -Value $Scenarioset.Scenario.Trimstart("guestinfo.scenario")
			$object | Add-Member -MemberType NoteProperty -Name Scenarioname -Value $Scenarioset.scenarioname
			$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
            $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
			Write-Output $Object
		}
            
	}
	end { }
}

<#
		.SYNOPSIS
			

		.DESCRIPTION
			Set the Activation Preference Number

		.PARAMETER  VMXname
			Optional, name of the VMX

		.PARAMETER  Config
			requires, the Config File Path

        .PARAMETER activationpreference
            Activation numer from 0 to 9
		.EXAMPLE
			PS C:\> Get-VMX dcnode | set-vmxactivationpreference $activationpreference 0

		.EXAMPLE
			PS C:\> Get-Something 'One value' 32

		.INPUTS
			

		.OUTPUTS


	#>	
function Set-VMXActivationPreference
{
	[CmdletBinding(HelpUri = "http://labbuildr.bottnet.de/modules/Set-VMXActivationPreference/")]
	param
	(   [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')][string]$VMXName,
		[Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$path,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)][ValidateRange(0,99)][alias ('apr')][int]$activationpreference
		
	)
	
	Begin
	{

	}
	Process
	{
		if ((get-vmx -Path $config).state -eq "stopped")
        {
        Copy-Item -Path $config -Destination "$($config).bak"
        $Content = Get-Content -Path $config
		$Content = ($Content -notmatch "guestinfo.activationpreference")
        $content += 'guestinfo.activationpreference = "' + $activationpreference + '"'
		Set-Content -Path $config -Value $Content
        $object = New-Object -TypeName psobject
		$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
        $object | Add-Member -MemberType NoteProperty -Name ActivationPreference -Value $activationpreference
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
        $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
        Write-Output $object
        }
		else
        {
        Write-Warning "VM must be in stopped state"
        }

	}
	End
	{}
}

<#
		.SYNOPSIS
			

		.DESCRIPTION
			Get the Activation Preference Number

		.PARAMETER  VMXname
			Optional, name of the VMX

		.PARAMETER  Config
			requires, the Config File Path

		.EXAMPLE
			PS C:\> Get-VMX dcnode | get-vmxactivationpreference


		.INPUTS
			

		.OUTPUTS


	#>	
function Get-VMXActivationPreference
{
	[CmdletBinding(DefaultParameterSetName = 1,HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXActivationPreference/")]
	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('NAME','CloneName')][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$Path
	)
	begin
    {	

	}
	process
	{
        $vmxconfig = Get-VMXConfig -config $config	    
		$ObjectType = "ActivationPreference"
		$patterntype = "ActivationPreference"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern $patterntype -vmxconfig $vmxconfig  -value $patterntype -patterntype $patterntype
			$object = New-Object -TypeName psobject
			$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
            $object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.ActivationPreference
			$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
            $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
			Write-Output $Object
	}
	end { }
}


<#
		.SYNOPSIS
			

		.DESCRIPTION
			start a Powershell inside the vm

		.PARAMETER  VMXname
			Optional, name of the VMX

#>	
function Invoke-VMXPowerShell
{
	[CmdletBinding(
    DefaultParameterSetName = 1,
    SupportsShouldProcess=$true,
    ConfirmImpact="Medium")]
	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('NAME','CloneName')][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)]$ScriptPath,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)]$Script, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)]$Parameter = "", 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$nowait, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$interactive,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$activewindow, 
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)][Alias('gu')]$Guestuser, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][Alias('gp')]$Guestpassword
	)
	begin
    {	
    $Origin = $MyInvocation.MyCommand
	$nowait_parm = ""
	$interactive_parm = ""
	if ($nowait) { $nowait_parm = "-nowait" }
	if ($interactive) { $interactive_parm = "-interactive" }
	}


process
    {
    $myscript = ".'$ScriptPath\$Script'"
    Write-Host -ForegroundColor Gray " ==>starting '$Script $Parameter' on " -NoNewline
    Write-Host -ForegroundColor Magenta $VMXName -NoNewline
  #  Write-Host  -ForegroundColor Magenta (Split-Path -Leaf $config ).Replace(".vmx","") -NoNewline

    do
        {
        $Myresult = 1
        do
	        {
            Write-Verbose "c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe '$myscript' '$Parameter'"
	        $cmdresult = (&$vmrun  -gu $Guestuser -gp $Guestpassword  runPrograminGuest $config -activewindow "$nowait_parm" $interactive_parm c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Executionpolicy bypass "$myscript" "$Parameter")
            }
	    until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
        Write-Verbose "Exitcode : $Lastexitcode"
        if ($Lastexitcode -ne 0)
            {
			Write-Host -ForegroundColor Red "[failed]"
            Write-Warning "Script Failure for $Script with $cmdresult"
            Write-Verbose "Confirmpreference: $ConfirmPreference"
            if ($ConfirmPreference -notmatch "none")
                {
                $Myresult = Get-yesnoabort -title "Scriptfailure for $Script" -message "May be VPN Issue, retry ?"
                Write-Verbose "Question response: $Myresult"
                If ($Myresult -eq 2)
                    {
                    exit
                    }
                }
                else 
                    {
                    $Myresult = 0
                    }
            }
        }
    until ($Myresult -eq 1)
	Write-Host  -ForegroundColor Green "[success]"
    Write-Verbose "Myresult: $Myresult"
    $object = New-Object psobject
    $object | Add-Member -MemberType 'NoteProperty' -Name config -Value $config
    $object | Add-Member -MemberType 'NoteProperty' -Name Script -Value $Script
    $object | Add-Member -MemberType 'NoteProperty' -Name Exitcode -Value $Lastexitcode
    if ($cmdresult){ $object | Add-Member -MemberType 'NoteProperty' -Name Result -Value $cmdresult}
    else {$object | Add-Member -MemberType 'NoteProperty' -Name Result -Value success}
    Write-Output $Object
    }

end {}
}


<#
		.SYNOPSIS
			

		.DESCRIPTION
			start a Powershell inside the vm

		.PARAMETER  VMXname
			Optional, name of the VMX

#>	
function Invoke-VMXBash
{
	[CmdletBinding(DefaultParameterSetName = 1,
    SupportsShouldProcess=$true,
    ConfirmImpact="Medium")]

	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('NAME','CloneName')][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)]$Scriptblock, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$nowait, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$interactive,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$activewindow,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][Validaterange(0,300)][int]$SleepSec,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('log')]$logfile

	)
	begin
    {	
    $Origin = $MyInvocation.MyCommand
	$nowait_parm = ""
	$interactive_parm = ""
	if ($nowait) { $nowait_parm = "-nowait" }
	if ($interactive) { $interactive_parm = "-interactive" }
	}


process
{
if ($Logfile) 
    {
    $Scriptblock = "$Scriptblock >> $logfile 2>&1"
    }
	
Write-host -ForegroundColor Gray " ==>running $Scriptblock on: " -NoNewline
Write-Host -ForegroundColor Magenta $VMXName -NoNewline
do
	{
    $Myresult = 1
        do
	        {
	        $cmdresult = (&$vmrun  -gu $Guestuser -gp $Guestpassword  runScriptinGuest $config -activewindow "$nowait_parm" $interactive_parm /bin/bash $Scriptblock)
	        }
	    until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
        Write-Verbose "Exitcode : $Lastexitcode"
        if ($Lastexitcode -ne 0)
            {
            Write-Warning "Script Failure for $Scriptblock with $cmdresult"
            Write-Verbose "Confirmpreference: $ConfirmPreference"
            if ($ConfirmPreference -notmatch "none")
                {
                $Myresult = Get-yesnoabort -title "Scriptfailure for $Scriptblock" -message "May be VPN Issue, retry ?"
                Write-Verbose "Question response: $Myresult"
                If ($Myresult -eq 2)
                    {
                    Write-Host -ForegroundColor Red "[failed]"
                    exit
                    }
                }
            else 
                {
                $Myresult = 0
                If ($SleepSec)
                    { 
                    Write-Warning "Waiting $SleepSec Seconds"
                    sleep $SleepSec 
                    }
                }
            }
        }
    until ($Myresult -eq 1)
    Write-Host -ForegroundColor Green "[success]"
    Write-Verbose "Myresult: $Myresult"
    $object = New-Object psobject
    $object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
    $object | Add-Member -MemberType 'NoteProperty' -Name Scriptblock -Value $Scriptblock
    $object | Add-Member -MemberType 'NoteProperty' -Name config -Value $config
    $object | Add-Member -MemberType 'NoteProperty' -Name Exitcode -Value $Lastexitcode
    if ($cmdresult){ $object | Add-Member -MemberType 'NoteProperty' -Name Result -Value $cmdresult}
    else {$object | Add-Member -MemberType 'NoteProperty' -Name Result -Value success}
    Write-Output $Object
}

end {}
}

function Invoke-VMXScript
{
	[CmdletBinding(DefaultParameterSetName = 1,
    SupportsShouldProcess=$true,
    ConfirmImpact="Medium")]

	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('NAME','CloneName')][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)]$Scriptblock, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$nowait, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$interactive,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$activewindow,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][Validaterange(0,300)][int]$SleepSec,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('log')]$logfile

	)
	begin
    {	
    $Origin = $MyInvocation.MyCommand
	$nowait_parm = ""
	$interactive_parm = ""
	if ($nowait) { $nowait_parm = "-nowait" }
	if ($interactive) { $interactive_parm = "-interactive" }
	}


process
{
if ($Logfile) 
    {
    $Scriptblock = "$Scriptblock >> $logfile 2>&1"
    }
	
Write-host -ForegroundColor Gray " ==>running $Scriptblock on: " -NoNewline
Write-Host -ForegroundColor Magenta $VMXName -NoNewline
do
	{
    $Myresult = 1
        do
	        {
	        $cmdresult = (&$vmrun  -gu $Guestuser -gp $Guestpassword  runScriptinGuest $config -activewindow "$nowait_parm" $interactive_parm $Scriptblock)
	        }
	    until ($VMrunErrorCondition -notcontains $cmdresult -or !$cmdresult)
        Write-Verbose "Exitcode : $Lastexitcode"
        if ($Lastexitcode -ne 0)
            {
            Write-Warning "Script Failure for $Scriptblock with $cmdresult"
            Write-Verbose "Confirmpreference: $ConfirmPreference"
            if ($ConfirmPreference -notmatch "none")
                {
                $Myresult = Get-yesnoabort -title "Scriptfailure for $Scriptblock" -message "May be VPN Issue, retry ?"
                Write-Verbose "Question response: $Myresult"
                If ($Myresult -eq 2)
                    {
                    Write-Host -ForegroundColor Red "[failed]"
                    exit
                    }
                }
            else 
                {
                $Myresult = 0
                If ($SleepSec)
                    { 
                    Write-Warning "Waiting $SleepSec Seconds"
                    sleep $SleepSec 
                    }
                }
            }
        }
    until ($Myresult -eq 1)
    Write-Host -ForegroundColor Green "[success]"
    Write-Verbose "Myresult: $Myresult"
    $object = New-Object psobject
    $object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
    $object | Add-Member -MemberType 'NoteProperty' -Name Scriptblock -Value $Scriptblock
    $object | Add-Member -MemberType 'NoteProperty' -Name config -Value $config
    $object | Add-Member -MemberType 'NoteProperty' -Name Exitcode -Value $Lastexitcode
    if ($cmdresult){ $object | Add-Member -MemberType 'NoteProperty' -Name Result -Value $cmdresult}
    else {$object | Add-Member -MemberType 'NoteProperty' -Name Result -Value success}
    Write-Output $Object
}

end {}
}


function Invoke-VMXexpect
{
	[CmdletBinding(DefaultParameterSetName = 1)]
	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('NAME','CloneName')][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)]$Scriptblock, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$nowait, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$interactive,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$activewindow, 
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword
	)
	begin
    {	
    $Origin = $MyInvocation.MyCommand
	$nowait_parm = ""
	$interactive_parm = ""
	if ($nowait) { $nowait_parm = "-nowait" }
	if ($interactive) { $interactive_parm = "-interactive" }
	}


process
{	
Write-Verbose "starting $Scriptblock"	
do
    
	{
	$cmdresult = (&$vmrun  -gu $Guestuser -gp $Guestpassword  runScriptinGuest $config -activewindow "$nowait_parm" $interactive_parm "/usr/bin/expect -c "  "$Scriptblock")
	}
	until ($VMrunErrorCondition -notcontains $cmdresult)
    $object = New-Object psobject
    $object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
    $object | Add-Member -MemberType 'NoteProperty' -Name Scriptblock -Value $Scriptblock
    $object | Add-Member -MemberType 'NoteProperty' -Name config -Value $config

    if ($cmdresult){ $object | Add-Member -MemberType 'NoteProperty' -Name Result -Value $cmdresult}
    Write-Output $Object
}

end {}
}


<#
		.SYNOPSIS
			

		.DESCRIPTION
			start a Powershell inside the vm

		.PARAMETER  VMXname
			Optional, name of the VMX

#>	
function Invoke-VMXexpect
{
	[CmdletBinding(DefaultParameterSetName = 1)]
	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('NAME','CloneName')][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)]$Scriptblock, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$nowait, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$interactive,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$activewindow, 
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword
	)
	begin
    {	
    $Origin = $MyInvocation.MyCommand
	$nowait_parm = ""
	$interactive_parm = ""
	if ($nowait) { $nowait_parm = "-nowait" }
	if ($interactive) { $interactive_parm = "-interactive" }
	}


process
{	
Write-Verbose "starting $Scriptblock"	
do
    
	{
	$cmdresult = (&$vmrun  -gu $Guestuser -gp $Guestpassword  runScriptinGuest $config -activewindow "$nowait_parm" $interactive_parm /usr/bin/expect  "$Scriptblock")
	}
	until ($VMrunErrorCondition -notcontains $cmdresult)
    $object = New-Object psobject
    $object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
    $object | Add-Member -MemberType 'NoteProperty' -Name Scriptblock -Value $Scriptblock
    $object | Add-Member -MemberType 'NoteProperty' -Name config -Value $config

    if ($cmdresult){ $object | Add-Member -MemberType 'NoteProperty' -Name Result -Value $cmdresult}
    Write-Output $Object
}

end {}
}



<#
	.SYNOPSIS
		A brief description of the get-vmxsnapshotconfig function.

	.DESCRIPTION
		gets detailed Information on the Snapshot Confguration
#>
function Get-VMXSnapshotconfig
{
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param
	(
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('TemplateName')][string]$VMXName,
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$Path = "$Global:vmxdir",
		[Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$VMXSnapconfig
	)
	Begin
	{
	}
	Process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $config = Get-VMX -VMXName $VMXname -Path $Path }
			"2"
			{
		
			}
		}
	    Write-Verbose "Getting Snapshot configuration for $VMXName form $VMXSnapconfig"
        $Snapcfg = Get-VMXConfig -config $VMXSnapconfig -VMXName $VMXName
        $Snaps = @()
        
        $Snaps += Search-VMXPattern -pattern "snapshot\d{1,2}.uid" -vmxconfig $Snapcfg -name SnapshotNumber -value UID -patterntype ".uid"
        $CurrentUID = Search-VMXPattern -pattern "snapshot.current" -vmxconfig $Snapcfg -name CurrentUID -value UID -patterntype ".uid"
        Write-Verbose "got $($Snaps.count) Snapshots"
        write-verbose "Processing Snapshots"
        foreach ($snap in $Snaps)
            { 
            [bool]$isCurrent = $false
            Write-Verbose "Snapnumber: $($Snap.SnapshotNumber)"
            Write-Verbose "UID $($Snap.UID)"
            Write-verbose "Current UID $($CurrentUID.UID)"
            If ($snap.uid -eq $CurrentUID.uid)
                {
                $isCurrent = $True
                }
            $Parent = Search-VMXPattern -pattern "$($Snap.Snapshotnumber).parent" -vmxconfig $Snapcfg -name Parent -value ParentUID -patterntype ".parent"
            $Filename = Search-VMXPattern -pattern "$($Snap.Snapshotnumber).disk\d{1,2}.filename" -vmxconfig $Snapcfg -name Disk -value File -patterntype ".fileName"
            $Diskname = Search-VMXPattern -pattern "$($Snap.Snapshotnumber).disk\d{1,2}.node" -vmxconfig $Snapcfg -name Disk -value ID -patterntype ".node"
            $Disknum = Search-VMXPattern -pattern "$($Snap.Snapshotnumber).numDisks" -vmxconfig $Snapcfg -name Disk -value Diskcount -patterntype ".numDisks"
            $Displayname = Search-VMXPattern -pattern "$($Snap.Snapshotnumber).Displayname" -vmxconfig $Snapcfg -Name Displayname -value UserFriendlyName -patterntype ".displayName"
		    $object = New-Object psobject
			$object | Add-Member -MemberType 'NoteProperty' -Name VMXname -Value $VMXname
		    $object | Add-Member -MemberType 'NoteProperty' -Name SnapShotnumber -Value $Snap.Snapshotnumber
		    $object | Add-Member -MemberType 'NoteProperty' -Name SnapUID -Value $Snap.UID
		    $object | Add-Member -MemberType 'NoteProperty' -Name IsCurrent -Value $isCurrent
            $object | Add-Member -MemberType 'NoteProperty' -Name ParentUID -Value $Parent.ParentUID
            $object | Add-Member -MemberType 'NoteProperty' -Name SnapshotName -Value $Displayname.UserFriendlyname
            $object | Add-Member -MemberType 'NoteProperty' -Name NumDisks -Value $Disknum.Diskcount
            $object | Add-Member -MemberType 'NoteProperty' -Name SnapFiles -Value $Filename
            $object | Add-Member -MemberType 'NoteProperty' -Name SnapDisks -Value $Diskname
            Write-Output $Object
            }
    }
	End
    {
		
	}
}



#mainMem.useNamedFile = "FALSE"#
<#
	.DESCRIPTION
		Sets the Memory in MB for a VM
#>
function Set-VMXMainMemory {
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/set-VMXMEMFile/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][switch]$usefile
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
        if ((get-vmx -Path $config).state -eq "stopped" )
        {
        Write-Verbose "We got to set mainMem.useNamedFile to $($usefile.IsPresent) "
        $vmxconfig = $vmxconfig | where {$_ -NotMatch "mainMem.useNamedFile"}
        If ($usefile.IsPresent)
            {
            $vmxconfig += 'mainMem.useNamedFile = "TRUE"'
            }
        else
            {
            $vmxconfig += 'mainMem.useNamedFile = "FALSE"'
            }

        $vmxconfig | Set-Content -Path $config
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name UseMemFile -Value $($usefile.IsPresent)
		Write-Output $Object
        }
        else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	end { }
} 


<#
	.DESCRIPTION
		Sets the Memory in MB for a VM
#>
function Set-VMXmemory {
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXMemory/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Validaterange(8,131072)][int]$MemoryMB
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
        if ((get-vmx -Path $config).state -eq "stopped" )
        {
        Write-Verbose "We got to set $MemoryMB MB"
        $vmxconfig = $vmxconfig | where {$_ -NotMatch "memsize"}
        $vmxconfig += 'memsize = "'+$MemoryMB+'"'
        $vmxconfig | Set-Content -Path $config
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name Memory -Value $MemoryMB
		Write-Output $Object
        }
        else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	end { }
} 



function Set-VMXHWversion {
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXMemory/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Validaterange(3,11)][int]$HWversion
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
        if ((get-vmx -Path $config).state -eq "stopped" )
        {
        Write-Verbose "We got to set $MemoryMB MB"
        $vmxconfig = $vmxconfig | where {$_ -NotMatch "virtualhw.version"}
        $vmxconfig += 'virtualhw.version = "'+$HWversion+'"'
        $vmxconfig | Set-Content -Path $config
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name HWVersion -Value $HWversion
		Write-Output $Object
        }
        else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	end { }
} 

<#
	.DESCRIPTION
		Sets the vcpu count for a VM
#>
function Set-VMXprocessor {
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXMemory/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Validaterange(1,32)][int]$Processorcount
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
        if ((get-vmx -Path $config).state -eq "stopped" )
        {
        Write-Verbose "We got to set $Processorcount CPUs"
        $vmxconfig = $vmxconfig | where {$_ -NotMatch "numvcpus"}
        $vmxconfig += 'numvcpus = "'+$Processorcount+'"'
        $vmxconfig | Set-Content -Path $config
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name Processor -Value $Processorcount
		Write-Output $Object
        }
        else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	end { }
} 

function Set-VMXToolsReminder {
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXMemory/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Switch]$enabled
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
        if ((get-vmx -Path $config).state -eq "stopped" )
        {
        Write-Verbose "We got to set Tools Reminder to $enabled"
        $vmxconfig = $vmxconfig | where {$_ -NotMatch "tools.remindInstall"}
        $vmxconfig += 'tools.remindInstall = "'+$enabled+'"'
        $vmxconfig | Set-Content -Path $config
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name ToolsReminder -Value $enabled
		Write-Output $Object
        }
        else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	end { }
} 

<#
	.DESCRIPTION
		A brief description of the set-vmxsize function
    .Synopsis
        Set-VMXSize -Size <Object> {XS | S | M | L | XL | TXL | XXL} [-VMXName <Object>] [-config <Object>]
        [<CommonParameters>]
#>
function Set-VMXSize {
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXMemory/")]
	param (
    <#name of the VMX #>
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
    [Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$Path,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
    <#
    Size
    'XS'  = 1vCPU, 512MB
    'S'   = 1vCPU, 768MB
    'M'   = 1vCPU, 1024MB
    'L'   = 2vCPU, 2048MB
    'XL'  = 2vCPU, 4096MB 
    'TXL' = 4vCPU, 6144MB
    'XXL' = 4vCPU, 8192MB
    #>
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $false)][ValidateSet('XS', 'S', 'M', 'L', 'XL','TXL','XXL')]$Size
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{
            }
		}
        if ((get-vmx -Path $config).state -eq "stopped" )
        {

        switch ($Size)
            { 
            "XS"{
            $Memory = 512
            $Processor = 1
            }
            "S"{
            $memory  = 768
            $Processor  = 1
            }
            "M"{
            $memory  = 1024
            $Processor  = 1
            }
            "L"{
            $memory  = 2048
            $Processor  = 2
            }
            "XL"{
            $memory  = 4096
            $Processor  = 2
            }
            "TXL"{
            $memory  = 6144
            $Processor  = 2
            }
            "XXL"{
            $memory  = 8192
            $Processor  = 4
            }
            }
        Write-Host -ForegroundColor Gray " ==>adjusting VM to size $Size with $Processor CPU and $Memory MB"
        $cpuout = (Set-VMXprocessor -VMXName $config -Processorcount $Processor -config $config).Processor
        $memout = (Set-VMXmemory -VMXName $config -MemoryMB $Memory -config $config).Memory 
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name Size -Value $Size
		$object | Add-Member -MemberType NoteProperty -Name Processor -Value $cpuout
		$object | Add-Member -MemberType NoteProperty -Name Memory -Value $Memout
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name Path -Value $Path

		Write-Output $Object
        }
        else
        {
        Write-Warning "VM must be in stopped state"
        }
	}
	end { }
}




function Convert-VMXdos2unix
{
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $true)]$Sourcefile
    )
    begin
	{
	}
	process
	{
	
    Get-ChildItem $Sourcefile | ForEach-Object {
    # get the contents and replace line breaks by U+000A
    $contents = [IO.File]::ReadAllText($_) -replace "`r`n?", "`n"
    # create UTF-8 encoding without signature
    $utf8 = New-Object System.Text.UTF8Encoding $false
    # write the text back
    [IO.File]::WriteAllText($_, $contents, $utf8)
    }


	}
    end
	{
	}
}



function Copy-VMXFile2Guest
{
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
    [Parameter(ParameterSetName = "2", Mandatory = $true)]$Sourcefile,
    [Parameter(ParameterSetName = "2", Mandatory = $true)]$targetfile,
    [Parameter(ParameterSetName = 2, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
    [Parameter(ParameterSetName = 2, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword
    )
    begin
	{
	}
	process
	{
	do
	    {
		($cmdresult = &$vmrun -gu $Guestuser -gp $Guestpassword copyfilefromhosttoguest $config $Sourcefile "$targetfile")  2>&1 | Out-Null
	    write-verbose "$cmdresult"
		}
		until ($VMrunErrorCondition -notcontains $cmdresult)
        if ($LASTEXITCODE -eq 0)
        {
        $object = New-Object -TypeName psobject
        $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
	    $object | Add-Member -MemberType NoteProperty -Name Sourcefile -Value $sourcefile
        $object | Add-Member -MemberType NoteProperty -Name Direction -Value "==>"
	    $object | Add-Member -MemberType NoteProperty -Name Target -Value $targetfile
        $object | Add-Member -MemberType NoteProperty -Name CreateTime -Value (Get-Date -Format "yyyy.MM.dd hh:mm")
        Write-Output $object
        }
        else 
            {Write-Warning $cmdresult}
        
	}
    end
	{
	}
}

function Copy-VMXFile2Host
{
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
    [Parameter(ParameterSetName = "2", Mandatory = $true)]$Sourcefile,
    [Parameter(ParameterSetName = "2", Mandatory = $true)]$targetfile,
    [Parameter(ParameterSetName = 2, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
    [Parameter(ParameterSetName = 2, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword
    )
    begin
	{
	}
	process
	{
	do
	    {
		($cmdresult = &$vmrun -gu $Guestuser -gp $Guestpassword copyfilefromguesttohost $config $Sourcefile "$targetfile")  2>&1 | Out-Null
	    write-verbose "$cmdresult"
		}
		until ($VMrunErrorCondition -notcontains $cmdresult)
        if ($LASTEXITCODE -eq 0)
        {
        $object = New-Object -TypeName psobject
        $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
	    $object | Add-Member -MemberType NoteProperty -Name Sourcefile -Value $sourcefile
        $object | Add-Member -MemberType NoteProperty -Name Direction -Value "==>"
	    $object | Add-Member -MemberType NoteProperty -Name Target -Value $targetfile
        $object | Add-Member -MemberType NoteProperty -Name CreateTime -Value (Get-Date -Format "yyyy.MM.dd hh:mm")
        Write-Output $object
        }
        else 
            {Write-Warning $cmdresult}
        
	}
    end
	{
	}
}


function Copy-VMXDirHost2Guest
{
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
    [Parameter(ParameterSetName = "2", Mandatory = $true)]$Sourcepath,
    [Parameter(ParameterSetName = "2", Mandatory = $true)]$targetpath,
    [Parameter(ParameterSetName = "2", Mandatory = $false)][switch]$recurse,
    [Parameter(ParameterSetName = "2", Mandatory = $false)][switch]$linux,
    [Parameter(ParameterSetName = 2, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
    [Parameter(ParameterSetName = 2, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword)


    if (!$VMXName)
        {
        $VMXName = (Split-Path -Leaf -Path $config).Replace(".vmx","") 
        }
    if ($recurse.IsPresent)
        {
        $files = (Get-ChildItem -Path $Sourcepath -file -Recurse)
        }
        else
        {
        $files = (Get-ChildItem -Path $Sourcepath -File )
        }
	$NoQSourcepath =Split-Path $Sourcepath -NoQualifier
    $Sourcebranch = (Split-Path $NoQSourcepath) -replace ("\\","\\")
    write-verbose "Source Branch Directory: $Sourcebranch"
    $incr = 1
    If ($Linux.IsPresent)
                {
                $targetpath =$targetpath.Replace("\","/")
                }
    $cmdresult = &$vmrun -gu $Guestuser -gp $Guestpassword directoryExistsInGuest $config $targetpath # 2>&1 | Out-Null
    if ($cmdresult -eq "The directory does not exist.")
        {
        Write-warning "$cmdresult : $targetpath, creating it"
        Write-verbose "we will create $targetpath"
        $newpath = New-VMXGuestPath -config $config -targetpath $targetpath -Guestuser $Guestuser -Guestpassword $Guestpassword
        }
    foreach ($file in $files)
	{
		Write-Progress -Activity "Copy Files to $VMXName" -Status $file.FullName -PercentComplete (100/$files.count * $incr)
		do
		{
            $Targetfile = Join-Path -Path $targetpath -ChildPath ((Split-Path -NoQualifier $file.FullName) -replace ("$Sourcebranch",""))
            If ($Linux.IsPresent)
                {
                $Targetfile = $Targetfile.Replace("\","/")
                }			
            write-verbose "Target File will be $Targetfile"

            $TargetDir = Split-Path -LiteralPath $Targetfile 
            Write-Verbose "Sourcefile: $($file.fullname)"
            Write-Verbose "Targetfile: $Targetfile"
            $cmdresult = &$vmrun -gu $Guestuser -gp $Guestpassword copyfilefromhosttoguest $config $file.FullName $Targetfile # 2>&1 | Out-Null
            if ($cmdresult -eq "Error: A file was not found")
                {
                    If ($Linux.IsPresent)
                    {            
                        $targetdir =$targetdir.Replace("\","/")
                    }

                    Write-verbose "we will create $TargetDir"
                    Write-Verbose $config
                    $newpath = New-VMXGuestPath -config $config -targetpath $TargetDir -Guestuser $Guestuser -Guestpassword $Guestpassword
		        }
        }
		until ($VMrunErrorCondition -notcontains $cmdresult)
        if ($LASTEXITCODE -ne 0)
            {
            
            Write-Warning "$cmdresult , does $Targetdir exist ? "

		    }
        else 
            {
            $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		    $object | Add-Member -MemberType NoteProperty -Name Source -Value $file.FullName
            $object | Add-Member -MemberType NoteProperty -Name Direction -Value "==>"
		    $object | Add-Member -MemberType NoteProperty -Name Target -Value $Targetfile
            $object | Add-Member -MemberType NoteProperty -Name CreateTime -Value (Get-Date -Format "yyyy.MM.dd hh:mm")
            Write-Output $object
            }
		$incr++

	}
}

function New-VMXGuestPath
{
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
    [Parameter(ParameterSetName = "2", Mandatory = $true)]$targetpath,
    [Parameter(ParameterSetName = 2, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
    [Parameter(ParameterSetName = 2, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword)

    if (!$VMXName)
        {
        $VMXName = (Split-Path -Leaf -Path $config).Replace(".vmx","") 
        }
    $cmdresult = &$vmrun -gu $Guestuser -gp $Guestpassword directoryExistsInGuest $config $targetpath # 2>&1 | Out-Null
    Write-Verbose $cmdresult
    if ($cmdresult -eq "The directory exists.")
        {
        Write-Warning "$cmdresult : $targetpath"
        }        
    else
        {
        Write-Verbose $targetpath
        do
            {
            $cmdresult = &$vmrun -gu $Guestuser -gp $Guestpassword createDirectoryInGuest $config $targetpath # 2>&1 | Out-Null
		    }
		until ($VMrunErrorCondition -notcontains $cmdresult)
        if ($LASTEXITCODE -ne 0)
            {
            Write-Warning "$cmdresult , does $targetpath already exist ? "
		    }
        else 
            {
            $object = New-Object -TypeName psobject
		    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		    $object | Add-Member -MemberType NoteProperty -Name Targetpath -Value $targetpath
            $object | Add-Member -MemberType NoteProperty -Name CreateTime -Value (Get-Date -Format "yyyy.MM.dd hh:mm")
            Write-Output $object
            }
        }

}


<#
	.DESCRIPTION
		The Function will configure Networking in a Linux VM using networking scripts ( redhat, centos, suse )
    .Example
        $vmx = get-vmx -path c:\centos

        $vmx | Set-VMXLinuxNetwork -ipaddress 192.168.2.110 -network 192.168.2.0 -netmask 255.255.255.0 -gateway 192.168.2.10 -device eth0 -Peerdns -DNS1 192.168.2.10 -DNSDOMAIN labbuildr.local -Hostname centos3 -rootuser root -rootpassword Password123!
        #>
function Set-VMXLinuxNetwork {
[CmdletBinding(DefaultParametersetName = "1",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]

param (
	    [Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
        [Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
        [Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
	    [Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
        [Parameter(Mandatory=$false)][ValidateScript({$_ -match [IPAddress]$_ })][ipaddress]$ipaddress = "192.168.2.100",
        [Parameter(Mandatory=$false)][ValidateScript({$_ -match [IPAddress]$_ })][ipaddress]$network = "192.168.2.0",
        [Parameter(Mandatory=$false)][ValidateScript({$_ -match [IPAddress]$_ })][ipaddress]$netmask = "255.255.255.0",
        [Parameter(Mandatory=$false)][ValidateScript({$_ -match [IPAddress]$_ })][ipaddress]$gateway = "192.168.2.103",
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$device = "eth0",
        [Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][switch]$Peerdns,
        [Parameter(ParameterSetName = "2", Mandatory = $true)][ValidateScript({$_ -match [IPAddress]$_ })][ipaddress]$DNS1 = "192.168.2.10",
        [Parameter(ParameterSetName = "2", Mandatory = $false)][ValidateScript({$_ -match [IPAddress]$_ })][ipaddress]$DNS2,
        [Parameter(ParameterSetName = "2", Mandatory = $true)]$DNSDOMAIN,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$Hostname,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$suse,
        #[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$systemd,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$rootuser, 
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$rootpassword
    )
begin {


      }
process {
        Write-Verbose $vmxname
        write-verbose $config
        if (!($vmx = get-vmx -Path $config))
        {
            Write-Warning "Could not find vm with Name $VMXName and Config $config"
            break
        }
        IF (!($VMX | Get-VMXToolsState) -match "running")
        {
            Write-Warning "VMwareTool must be installed and Running"
            break
        }
        Write-Verbose "configuring $device"
        if ($suse.IsPresent)
            {
            $File = "/etc/sysconfig/network/ifcfg-$device"
            }
        else
            {
            $File = "/etc/sysconfig/network-scripts/ifcfg-$device"
            }

    if ($suse.IsPresent)
        {
        $vmx | Invoke-VMXBash -Scriptblock "yast2 lan edit id=0 ip=$ipaddress netmask=$netmask prefix=24 verbose" -gu $rootuser -gp $rootpassword
        $vmx | Invoke-VMXBash -Scriptblock "hostname $Hostname" -Guestuser $rootuser -Guestpassword $rootpassword
        $Scriptblock = "echo 'default "+$gateway+" - -' > /etc/sysconfig/network/routes"
        $vmx | Invoke-VMXBash -Scriptblock $Scriptblock  -Guestuser $rootuser -Guestpassword $rootpassword
        $sed = "sed -i -- 's/NETCONFIG_DNS_STATIC_SEARCHLIST=\`"\`"/NETCONFIG_DNS_STATIC_SEARCHLIST=\`"$DNSDomain\`"/g' /etc/sysconfig/network/config" 
        $vmx | Invoke-VMXBash -Scriptblock $sed -Guestuser $rootuser -Guestpassword $rootpassword
        $sed = "sed -i -- 's/NETCONFIG_DNS_STATIC_SERVERS=\`"\`"/NETCONFIG_DNS_STATIC_SERVERS=\`"$DNS1\`"/g' /etc/sysconfig/network/config"
        $vmx | Invoke-VMXBash -Scriptblock $sed -Guestuser $rootuser -Guestpassword $rootpassword
        $vmx | Invoke-VMXBash -Scriptblock "/sbin/netconfig -f update" -Guestuser $rootuser -Guestpassword $rootpassword
        $Scriptblock = "echo '"+$Hostname+"."+$DNSDOMAIN+"'  > /etc/HOSTNAME"
        $vmx | Invoke-VMXBash -Scriptblock $Scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
        $vmx | Invoke-VMXBash -Scriptblock "/sbin/rcnetwork restart" -Guestuser $rootuser -Guestpassword $rootpassword

        <#
        if ($systemd.IsPresent)
            {
            $vmx | Invoke-VMXBash -Scriptblock "/sbin/rcnetwork restart" -Guestuser $rootuser -Guestpassword $rootpassword
            }
        else
            {
            $vmx | Invoke-VMXBash -Scriptblock "/etc/init.d/network restart" -Guestuser $rootuser -Guestpassword $rootpassword
            }
        #>
        }
    else
        {
        $Property = "DEVICE"
        $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=$device/' $file || echo '$Property=$device' >> $file"
        # $Scriptblock = "echo  'DEVICE=eth0' > /etc/sysconfig/network-scripts/ifcfg-$device"
        Write-Verbose "Invoking $Scriptblock"
        $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword

        $Property = "BOOTPROTO"
        $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=static/' $file || echo '$Property=static' >> $file"
        Write-Verbose "Invoking $Scriptblock"
        $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword

        $Property = "IPADDR"
        $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=$ipaddress/' $file || echo '$Property=$ipaddress' >> $file"
        #$Scriptblock = "echo  'IPADDR=$ipaddress' >> /etc/sysconfig/network-scripts/ifcfg-$device"
        Write-Verbose "Invoking $Scriptblock"
        $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword

        $Property = "NETWORK"
        $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=$network/' $file || echo '$Property=$network' >> $file"
        #$Scriptblock = "echo  'NETWORK=$network' >> /etc/sysconfig/network-scripts/ifcfg-$device"
        Write-Verbose "Invoking $Scriptblock"

        $Property = "ONBOOT"
        $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=yes/' $file || echo '$Property=yes' >> $file"
        #$Scriptblock = "echo  'NETWORK=$network' >> /etc/sysconfig/network-scripts/ifcfg-$device"
        Write-Verbose "Invoking $Scriptblock"


        $Property = "NETMASK"
        $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=$netmask/' $file || echo '$Property=$netmask' >> $file"
        #$Scriptblock = "echo  'NETMASK=$netmask' >> /etc/sysconfig/network-scripts/ifcfg-$device"
        Write-Verbose "Invoking $Scriptblock"
        $vmx | Invoke-VMXBash -Scriptblock $Scriptblock -Guestuser $rootuser -Guestpassword $rootpassword

        $Property = "GATEWAY"
        $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=$gateway/' $file || echo '$Property=$gateway' >> $file"
        #$Scriptblock = "echo  'GATEWAY=$gateway' >> /etc/sysconfig/network-scripts/ifcfg-$device"
        Write-Verbose "Invoking $Scriptblock"
        $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
        IF ($peerdns.IsPresent)
            {
            $Property = "PEERDNS"
            $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=yes/' $file || echo '$Property=yes' >> $file"
            Write-Verbose "Invoking $Scriptblock"
            $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
            
            $Property = "DOMAIN"
            $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=$DNSDOMAIN/' $file || echo '$Property=$DNSDOMAIN' >> $file"
            Write-Verbose "Invoking $Scriptblock"
            $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword


            $Property = "DNS1"
            $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=$DNS1/' $file || echo '$Property=$DNS1' >> $file"
            Write-Verbose "Invoking $Scriptblock"
            $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
            IF ($DNS2)
                {
            
                $Property = "DNS2"
                $Scriptblock = "grep -q '^$Property' $file && sed -i 's/^$Property.*/$Property=$DNS2/' $file || echo '$Property=$DNS2' >> $file"
                Write-Verbose "Invoking $Scriptblock"
                $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
                }
            }
        if ($Hostname)
            {
            Write-Verbose "setting Hostname $Hostname"
            $Scriptblock = "sed -i -- '/HOSTNAME/c\HOSTNAME=$Hostname' /etc/sysconfig/network"
            Write-Verbose "Invoking $Scriptblock"
            $vmx | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
            }

        
        $vmx | Invoke-VMXBash -Scriptblock "/sbin/service network restart" -Guestuser $rootuser -Guestpassword $Rootpassword
        $object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
        $Object | Add-Member -MemberType NoteProperty -Name IPAddress -Value $ipaddress
        $Object | Add-Member -MemberType NoteProperty -Name Gateway -Value $gateway
        $Object | Add-Member -MemberType NoteProperty -Name Network -Value $network
        $Object | Add-Member -MemberType NoteProperty -Name Netmask -Value $netmask
        $Object | Add-Member -MemberType NoteProperty -Name DNS -Value "$DNS1 $DNS2"
        Write-Output $object
        }
}
end {}
}


<#
	.DESCRIPTION
		The Script will configure DNS in a Linux VM Manually
    .Synopsis
        $vmx | Set-VMXLinuxDNS -rootuser root -rootpassword Password123! -Verbose -device eth0
#>
function Set-VMXLinuxDNS {
[CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
param (
	    [Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	    [Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
        [Parameter(Mandatory=$true)][ValidateScript({$_ -match [IPAddress]$_ })][ipaddress]$Nameserver1 = "192.168.2.10",
        [Parameter(Mandatory=$false)][ValidateScript({$_ -match [IPAddress]$_ })][ipaddress]$Nameserver2,
        [Parameter(Mandatory=$true)]$Domain = "labbuildr.local",
        [Parameter(Mandatory=$true)]$Search1 = "labbuildr.local",
        [Parameter(Mandatory=$false)]$Search2,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$rootuser, 
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$rootpassword
    )
begin {
    If ($Nameserver2)
        {
        $Nameserver = "$Nameserver1,$Nameserver2"
        }
    else
        {
        $Nameserver = $Nameserver1
        }
    If ($Search2)
        {
        $Search = "$Search1,$Search2"
        }
    else
        {
        $Search = $Search1
        }
      }
process {
        Write-Verbose $vmxname
        write-verbose $config
        if (!($vmx = get-vmx -Path $config))
        {
            Write-Warning "Could not find vm with Name $VMXName and Config $config"
            break
        }
        IF (!($VMX | Get-VMXToolsState) -match "running")
        {
            Write-Warning "VMwareTool must be installed and Running"
            break
        }
        $Scriptblock = "echo 'nameserver $Nameserver' > /etc/resolv.conf"
        Write-Verbose "Invoking $Scriptblock"
        $VMX | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
        $Scriptblock = "echo 'domain $Domain'  >> /etc/resolv.conf"
        Write-Verbose "Invoking $Scriptblock"
        $VMX | Invoke-VMXBash -Scriptblock $scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
        $Scriptblock = "echo 'search $Search'  >> /etc/resolv.conf"
        Write-Verbose "Invoking $Scriptblock"
        $VMX | Invoke-VMXBash -Scriptblock $Scriptblock -Guestuser $rootuser -Guestpassword $rootpassword
        $object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
        $Object | Add-Member -MemberType NoteProperty -Name Domain -Value $Domain
        $Object | Add-Member -MemberType NoteProperty -Name Search -Value $Search
        $Object | Add-Member -MemberType NoteProperty -Name Nameserver -Value $Nameserver
        Write-Output $object
}
end {}
}

<#	
	.SYNOPSIS
		A brief description of the Get-VMXAnnotation function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXAnnotation function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXAnnotation -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXAnnotation {
	
	#
	[CmdletBinding(DefaultParametersetName = "2",HelpUri = "http://labbuildr.bottnet.de/modules/Get-VMXAnnotation/")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}	$ErrorActionPreference = "silentlyContinue"
	    Write-Verbose -Message "getting annotation"
        $Annotation = $vmxconfig | where {$_ -match "annotation" }
        $annotation = $annotation -replace "annotation = "
        $annotation = $annotation -replace '"',''
        $Annotation = $annotation.replace("|0D|0A",'"')
        $Annotation = $Annotation.split('"')
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name Line0 -Value $Annotation[0]
		$object | Add-Member -MemberType NoteProperty -Name Line1 -Value $Annotation[1]
		$object | Add-Member -MemberType NoteProperty -Name Line2 -Value $Annotation[2]
		$object | Add-Member -MemberType NoteProperty -Name Line3 -Value $Annotation[3]
		$object | Add-Member -MemberType NoteProperty -Name Line4 -Value $Annotation[4]
		$object | Add-Member -MemberType NoteProperty -Name Line5 -Value $Annotation[5]
        Write-Output $object
	}
	end { }
	
} #end Get-VMXAnnotation



function New-VMX
{
    [CmdletBinding(DefaultParametersetName = "2",HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki/Commands/New-VMX")]
	param (
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
    [Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet('Server2016','Server2012','Hyper-V')]$Type,
    [Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $true)][ValidateSet('BIOS','EFI')][string]$Firmware = 'BIOS',
    [Parameter(ParameterSetName = "1", HelpMessage = "Please enter an optional root Path to you VMs (default is vmxdir)",Mandatory = $false)]
	$Path = $vmxdir
    )
    $VMXpath = Join-Path $Path $VMXName
    Write-Verbose $VMXpath
    if (get-vmx -Path $VMXpath | Out-Null)
        {
        Write-Warning "Vm Already Exists" 
        break
        }
    if (!(Test-Path $VMXpath))
        {
        New-Item -ItemType Directory -Path $VMXpath | Out-Null
        }
    $Firmware = $Firmware.ToLower()
    $VMXConfig =@('.encoding = "windows-1252"
config.version = "8"
virtualHW.version = "11"
numvcpus = "2"
vcpu.hotadd = "TRUE"
scsi0.present = "TRUE"
scsi0.virtualDev = "lsisas1068"
sata0.present = "TRUE"
memsize = "2048"
mem.hotadd = "TRUE"
sata0:1.present = "TRUE"
sata0:1.autodetect = "TRUE"
sata0:1.deviceType = "cdrom-raw"
sata0:1.startConnected = "FALSE"
usb.present = "TRUE"
ehci.present = "TRUE"
ehci.pciSlotNumber = "0"
usb_xhci.present = "TRUE"
serial0.present = "TRUE"
serial0.fileType = "thinprint"
pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
vmci0.present = "TRUE"
hpet0.present = "TRUE"
virtualHW.productCompatibility = "hosted"
powerType.powerOff = "soft"
powerType.powerOn = "soft"
powerType.suspend = "soft"
powerType.reset = "soft"
floppy0.present = "FALSE"
tools.remindInstall = "FALSE"')       
    switch ($Type)
    {
    "Server2016"
        {
        $guestOS = "windows9srv-64"
        Write-Verbose "creating new vm as $_ with $guestOS"
        $VMXConfig += 'guestOS = "'+$guestOS+'"'        
        }   
    
    "Server2012"
        {
        $guestOS = "windows8srv-64"
        Write-Verbose "creating new vm as $_ with $guestOS"
        $VMXConfig += 'guestOS = "'+$guestOS+'"'        
        }
    "Hyper-V"
        {
        $guestOS = "winhyperv"
        Write-Verbose "creating new vm as $_ with $guestOS"
        $VMXConfig += 'guestOS = "'+$guestOS+'"'        
        }
    "Default"
        {
        Write-Warning "No valid Type Specified"
        break
        }
    }# end switch
    $VMXConfig += 'extendedConfigFile = "'+$vmxname+'.vmxf"'        
    $VMXConfig += 'nvram = "'+$VMXName+'.nvram"'
    $VMXConfig += 'firmware = "'+$Firmware+'"'
    $Config = join-path $VMXpath "$VMXName.vmx"
    $VMXConfig | Set-Content -Path $Config
    $object = New-Object -TypeName psobject
    $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
    $object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
    $object | Add-Member -MemberType NoteProperty -Name Path -Value $VMXpath
    Write-Output $object
}



function Test-VMXFileInGuest
{
	[CmdletBinding(HelpUri = "https://github.com/bottkars/vmxtoolkit/wiki")]
	param (
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$Filename,
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME','CloneName')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
    [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gu')]$Guestuser, 
    [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)][Alias('gp')]$Guestpassword
    )
begin {
    }
process 
	{
    $fileok = .$vmrun -gu $Guestuser -gp $Guestpassword fileExistsInGuest  $config $Filename
	if ($fileok -match "exists")
	 {Write-Output $True}
	 else
	 {Write-Output $false}
    }
end 
	{
    
    }
}
