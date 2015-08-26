vmxtoolkit
==========

vmxtoolkit is the Powershell extension to VMware Workstation
vmxtoolkit is community-driven
vmxtoolkit is the Base for labbuildr, the automated lab building environment for vmware workstation on windows
you get support for labbuildr on http://labbuildr.com and https://community.emc.com/blogs/bottk/2014/06/16/announcement-labbuildr-released

simply follow @hyperv_guy on twitter for updates
===========
Installation   
Simply extract the toolkit into a folder where your VM´s reside.
Per Default, vmxtoolkit searches from that path
Otherwise, specifythe path to your vm when doing a get-vmx

current exposed commands
===========
 Get-VMwareVersion
 Get-VMX
 Get-VMXActivationPreference
 Get-VMXConfig
 Get-VMXConfigVersion
 Get-VMXDisplayName
 Get-VMXGuestOS
 Get-VMXHWVersion
 Get-VMXIdeDisk
 Get-VMXInfo
 Get-VMXIPAddress
 Get-VMXmemory
 Get-VMXNetwork
 Get-VMXNetworkAdapter
 Get-VMXNetworkConnection
 Get-VMXProcessor
 Get-VMXRun
 Get-VMXscenario
 Get-VMXScsiController
 Get-VMXScsiDisk
 Get-VMXSnapshot
 Get-VMXSnapshotconfig
 Get-VMXTemplate
 Get-VMXUUID
 Invoke-VMXPowerShell
 New-VMXClone
 New-VMXLinkedClone
 New-VMXScsiDisk
 New-VMXSnapshot
 remove-vmx
 Remove-VMXserial
 Remove-VMXSnapshot
 Restore-VMXSnapshot
 Search-VMXPattern
 Set-VMXActivationPreference
 Set-VMXDisplayName
 Set-VMXmemory
 Set-VMXNetworkAdapter
 Set-VMXprocessor
 Set-VMXscenario
 Set-VMXserialPipe
 Set-VMXSize
 Set-VMXTemplate
 Set-VMXVnet
 Start-VMX
 Stop-VMX
 Suspend-VMX

Help
==========
while commands are self explaining, there is an online help available get-help [command] -online
Contributing
==========
Please contribute in any way to the project. Specifically, normalizing differnet image sizes, locations, and intance types would be easy adds to enhance the usefulness of the project.

Licensing
==========
Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

Support
==========
Please file bugs and issues at the Github issues page. The code and documentation are released with no warranties or SLAs and are intended to be supported through a community driven process.
