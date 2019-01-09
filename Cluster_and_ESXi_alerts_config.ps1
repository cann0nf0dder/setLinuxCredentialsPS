<#
NAME:      Cluster_and_ESXi_alerts_config.ps1

AUTHOR:       Chris Danielewski

DATE  :      08/31/2016

PURPOSE:     This script enables or disables alerts for a given cluster
             to enable - enable 1
			 to disable - enable 0
                                                                                          
OUTPUT:      N/A


REQUIRED UTILITIES: PowerCLI
                             
                        
==========================================================================
CHANGE HISTORY:
    Version                 DATE               Initials             Description of Change
    v1.0                    08/31/2016          CD                  New Script

                
#>
param(
[Parameter(Mandatory=$true)][String]$mycluster,
[Parameter(Mandatory=$true)][int]$enable
)

#vMotion configuration
if ($enable -eq 1){
$alarmMgr = Get-View AlarmManager 
$cluster = Get-Cluster $mycluster
$alarmMgr.EnableAlarmActions($cluster.Extensiondata.MoRef,$true)
$alarmMgr2 = Get-View AlarmManager 
$esx = Get-Cluster $cluster | Get-VMHost
Foreach ($server in $esx)
{
$alarmMgr2.EnableAlarmActions($server.Extensiondata.MoRef,$true)
}
}
if ($enable -eq 0){
$alarmMgr = Get-View AlarmManager 
$cluster = Get-Cluster $mycluster 
$alarmMgr.EnableAlarmActions($cluster.Extensiondata.MoRef,$false)
$alarmMgr2 = Get-View AlarmManager 
$esx = Get-Cluster $cluster | Get-VMHost
Foreach ($server in $esx)
{
$alarmMgr2.EnableAlarmActions($server.Extensiondata.MoRef,$false)
}
}
Write-Host -foregroundcolor Blue " DONE!"

