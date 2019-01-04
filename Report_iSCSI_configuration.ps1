<#
NAME:        Report_iSCSI_configuration.ps1
AUTHOR:      Chris Danielewski 
DATE  :      10/19/2017 
PURPOSE:     This script will display current MTU value for each vmk and vSwitches as well as delayed ack settings

           		                                                                                          
OUTPUT:      N/A
REQUIRED UTILITIES: PowerCLI
                             
                        
==========================================================================
CHANGE HISTORY:
GE HISTORY:
v1.0                       2/2/2016          CD                  New Script.
#>

$cluster = Read-Host "Enter cluster name"
Write-Host -ForegroundColor Green "iSCSI MTU configuration"
Write-Host "1) Display cluster vmkernel port MTU values"
Write-Host "2) Display cluster standard vSwitch MTU values "
Write-Host "3) Display delayed ack settings"
Write-Host "4) Display iSCSI login timeout"

$Input = Read-Host "Please select 1-3?"
Write-Host ""
    if ($Input -eq "1") 
    {
        $vmk = Get-Cluster $cluster | Get-VMHost | Get-VMHostNetworkAdapter | Where { $_.GetType().Name -eq "HostVMKernelVirtualNicImpl" } | Select VMHost, Name, MTU
        echo $vmk
    }
    elseif ($Input -eq "2") 
    {
        $switches =  Get-Cluster $cluster | Get-VMHost | Get-VirtualSwitch -Standard | Select-Object VMHost,Name,Mtu
        echo $switches
    }

    elseif ($Input -eq "3") 
    {
        #Get Hosts
        $vmhosts = Get-Cluster $cluster | Get-VMHost| sort Name
        foreach ($vmh in $vmhosts) 
        {
                $delayedACKValue = $SWiSCSIhba = $SWiSCSIAdvancedSettings = $delayedACKSetting = $Null
                $SWiSCSIhba = $vmh | get-vmhosthba -type iscsi
                $SWiSCSIAdvancedSettings = $SWiSCSIhba.ExtensionData.AdvancedOptions
                foreach ($SWiSCSIsetting in $SWiSCSIAdvancedSettings)
                {
                    $delayedACKSetting = $SWiSCSIsetting | where {$_.key -eq "DelayedAck"}
                    $delayedACKValue = $delayedACKSetting.value  
                }
                Write-host "$($vmh.name) DelayedAck Setting: $($delayedACKValue)"
         }
    }
      elseif ($Input -eq "4") 
    {
        #Get Hosts
        $vmhosts = Get-Cluster $cluster | Get-VMHost| sort Name
        foreach ($vmh in $vmhosts) 
        {
                $delayedACKValue = $SWiSCSIhba = $SWiSCSIAdvancedSettings = $delayedACKSetting= $loginSetting = $Null
                $SWiSCSIhba = $vmh | get-vmhosthba -type iscsi
                $SWiSCSIAdvancedSettings = $SWiSCSIhba.ExtensionData.AdvancedOptions
                $loginSetting = $SWiSCSIAdvancedSettings | where {$_.key -eq "LoginTimeout"} | Select-Object LoginTimeout,Value
                $loginValue = $loginSetting.value  
                
                
                Write-host "$($vmh.name) LoginTimeout: $loginValue"
         }}