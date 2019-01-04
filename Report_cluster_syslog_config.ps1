<#
NAME:        Report_cluster_syslog_config.ps1
AUTHOR:      Chris Danielewski 
DATE  :      10/24/2017 
PURPOSE:     This script will display syslog config, firewall & service settings.

           		                                                                                          
OUTPUT:      N/A
REQUIRED UTILITIES: PowerCLI
                             
                        
==========================================================================
CHANGE HISTORY:
GE HISTORY:
v1.0                       10/25/2017          CD                  New Script.
#>
param(
[Parameter(Mandatory=$true)][String]$cluster
)


        $vmhosts = Get-Cluster $cluster | Get-VMHost| sort Name
        foreach ($vmh in $vmhosts) 
        {
        $sys = $vmh | Get-AdvancedSetting Syslog.global.logHost 
        $fw = $vmh | Get-VMHostFirewallException | where {$_.Name.StartsWith('syslog')}
        $serv = $vmh | Get-VMHostService | Where-Object {$_.key -eq "vmsyslogd"}
        Write-Output "$($vmh.Name) Syslog: $($sys.Value)"
        Write-Output "Firewall Enabled?: $($fw.Enabled)"
        Write-Output "Service Running?: $($serv.Running)"
        }
