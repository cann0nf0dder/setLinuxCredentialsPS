<#
NAME:        Configure_vMotion_on_vmk.ps1

AUTHOR:      Chris Danielewski 

DATE  :      10/11/2017

PURPOSE:     This script will check for vMotion enabled on vmk0 accross all the hosts.
             If not enabled, this script will enable it.		
                                                                                          
OUTPUT:      N/A


REQUIRED UTILITIES: PowerCLI
                             
                        
==========================================================================
CHANGE HISTORY:
GE HISTORY:
v1.0                       10/11/2017          CD              SFMC    New Script.
#>

$Collection = @()

#Create a list of hosts, ignore Not Responding
$hosts = Get-VMHost | Where-Object {$_.ConnectionState -ne "NotResponding"} | Sort-Object Name

#Loop through the hosts and update VMKernel
foreach ($node in $hosts)
{
$details = New-Object PSObject
$node | Get-VMHostNetworkAdapter -Name 'vmk0' | Set-VMHostNetworkAdapter -VMotionEnabled $true -Confirm:$false 
$vmk0 = $node | Get-VMHostNetworkAdapter -name "vmk0" | select VMHost,DeviceName,VMotionEnabled
$details | Add-Member -Name VMHost -Value $vmk0.VMHost -MemberType NoteProperty
$details | Add-Member -Name DeviceName -Value $vmk0.DeviceName -MemberType NoteProperty
$details | Add-Member -Name VMotionEnabled -Value $vmk0.VMotionEnabled -MemberType NoteProperty
$Collection += $details
$vmk = $node | Get-VMHostNetworkAdapter -VMKernel
if($vmk.DeviceName -contains "vmk1")
    {
    $details = New-Object PSObject
    $node | Get-VMHostNetworkAdapter -Name 'vmk1' | Set-VMHostNetworkAdapter -VMotionEnabled $false -Confirm:$false 
    $vmk1 = $node | Get-VMHostNetworkAdapter -name "vmk1" | select VMHost,DeviceName,VMotionEnabled
    $details | Add-Member -Name VMHost -Value $vmk1.VMHost -MemberType NoteProperty
    $details | Add-Member -Name DeviceName -Value $vmk1.DeviceName -MemberType NoteProperty
    $details | Add-Member -Name VMotionEnabled -Value $vmk1.VMotionEnabled -MemberType NoteProperty
    $Collection += $details
    }
}
Write-Output "Current vMotion vmk status after the changes"
#Display report
$Collection | Sort-Object DeviceName,VMHost