<#
NAME:        Configure_iSCSI_MTU.ps1

AUTHOR:      Chris Danielewski 

DATE  :      2/2/2016 

PURPOSE:     This script will display current MTU value for each vmk and vSwitches
             It can set MTU at either 1500 or 9000 for iscsi vmks (vmk1,2)
      		 It can set MTU on vSwitches		
                                                                                          
OUTPUT:      N/A


REQUIRED UTILITIES: PowerCLI
                             
                        
==========================================================================
CHANGE HISTORY:
GE HISTORY:
v1.0                       2/2/2016          CD                  New Script.
#>

$cluster = Read-Host "Enter Cluster name"

function setVMKmtu
{
    Get-Cluster $cluster | Get-VMHost | Get-VMHostNetworkAdapter -Name 'vmk1' | Set-VMHostNetworkAdapter -Mtu $MTU -Confirm:$false
    Get-Cluster $cluster | Get-VMHost | Get-VMHostNetworkAdapter -Name 'vmk2' | Set-VMHostNetworkAdapter -Mtu $MTU -Confirm:$false
}
function setvSSmtu
{
    $vswitches = Get-Cluster $cluster| Get-VMHost | Get-VirtualSwitch -Standard
	foreach($vswitch in $vswitches)
	{
		Set-VirtualSwitch $vswitch -Mtu $MTU -Confirm:$False
	}
}
do{
    Write-Host -ForegroundColor Green "iSCSI MTU configuration"
    Write-Host "1) Display cluster vmkernel port MTU values"
    Write-Host "2) Display cluster standard vSwitch MTU values "
    Write-Host "3) Enable cluster Jumbo frames on iSCSI vmkernel ports (MTU 9000)"
    Write-Host "4) Disable cluster Jumbo frames on iSCSI vmkernel ports (MTU 1500)"
    Write-Host "5) Enable cluster Jumbo frames on standard vSwitches (MTU 9000)"
    Write-Host "6) Disable cluster Jumbo frames on standard vSwitches (MTU 1500)"
    Write-Host "6) Exit"
    $Input = Read-Host "Please select 1-7?"
    Write-Host ""


    if ($Input -eq "1") {
    Get-Cluster $cluster | Get-VMHost | Get-VMHostNetworkAdapter | Where { $_.GetType().Name -eq "HostVMKernelVirtualNicImpl" } | Select VMHost, Name, MTU
    }
    elseif ($Input -eq "2") {
        $switches = Get-Cluster $cluster | Get-VMHost | Get-VirtualSwitch -Standard
        $switches
    }
    elseif ($Input -eq "3") {
        $MTU = 9000
        setVMKmtu
    }
    elseif ($Input -eq "4") {
        $MTU = 1500
        setVMKmtu
    }
    elseif ($Input -eq "5") {
        $MTU = 9000
        setvSSmtu
    }
    elseif ($Input -eq "6") {
        $MTU = 1500
        setvSSmtu
    }
}until($Input -eq "7")



