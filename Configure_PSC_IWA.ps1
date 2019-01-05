
<#
NAME:      Configure_PSC.ps1
AUTHOR:     Chris Danielewski 
DATE  :      2/20/2018 
PURPOSE:     This script will join AD and configure IWA on VMware PSC v6.0,6.5 (not tested on 6.7)
             EDIT you AD OU  Line 34
					                                                                                         
OUTPUT:      N/A
REQUIRED UTILITIES: PowerCLI, SSHSessions Utils dir with nested sh scripts
                             
                        
==========================================================================
CHANGE HISTORY:
GE HISTORY:
v1.0                       2/20/2018          CD                  New script!
#>

param(
[Parameter(Mandatory=$true)][String]$psc,
[Parameter(Mandatory=$true)][String]$domain,
[Parameter(Mandatory=$true)][String]$ad_username,
[Parameter(Mandatory=$true)][String]$ad_password,
[Parameter(Mandatory=$true)][String]$psc_root_password
) 

$secpasswd = ConvertTo-SecureString $root_password -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("root", $secpasswd)

### JOIN PSC TO DOMAIN 
$session = $(New-SSHSession -ComputerName $psc -Username "root" -Password $mycreds)
					    if ($session -match "Successfully connected") {
                            write-Output "Join AD domain"
                            ########## EDIT OU! ###########
                            Invoke-SshCommand -ComputerName $psc -Command "/opt/likewise/bin/domainjoin-cli join --assumeDefaultDomain --ou `'<ENTER YOUR OU HERE>`' `'$domain`' `'$ad_username`' `'$ad_password`'"                                                    
                            Invoke-SshCommand -ComputerName $psc -Command "reboot"
    }
    Else {
    Write-Output "Connection to " $psc "failed"
    exit
    }
Remove-sshSession -ComputerName $psc
### Random sleep I know... (more than enough)! :P
Start-Sleep -Seconds 120

Write-Host "Copying PSC configuration files"
#### PATH to import.sh located in UTILS
#### PATH to sso-add-native-ad-idp.sh located in UTILS
$scriptA = ./Utils/sso_import.sh
$scriptB = ./Utils/sso-add-native-ad-idp.sh
Copy-VMGuestFile -Source $scriptA -Destination "/home/" -force -VM $($psc_vm) -LocalToGuest -GuestUser "root" -GuestPassword $mycreds
Copy-VMGuestFile -Source $scriptB -Destination "/home/" -force -VM $($psc_vm) -LocalToGuest -GuestUser "root" -GuestPassword $mycreds

Start-Sleep -Seconds 60
$session = $(New-SSHSession -ComputerName $psc -Username "root" -Password $mycreds)
					    #write-host "session - $session"
					    if ($session -match "Successfully connected") {
                            #chmod files                          
                            Invoke-SshCommand -ComputerName $psc -Command "chmod +x /home/sso-add-native-ad-idp.sh" 
                            Invoke-SshCommand -ComputerName $psc -Command "chmod +x /home//sso_import.sh"
                            Invoke-SshCommand -ComputerName $psc -Command "cp /home/sso_import.sh /usr/lib/vmidentity/tools/scripts/."
                            #set identity source
                            Invoke-SshCommand -ComputerName $psc -Command "/home//sso-add-native-ad-idp.sh $domain" 
                            #Set domain as DEFAULT IDENTITY SOURCE
                            Start-Sleep -s 10
                            Invoke-SshCommand -ComputerName $psc -Command "touch /tmp/ad.ldif"
                            Invoke-SshCommand -ComputerName $psc -Command "echo 'dn: cn=vsphere.local,cn=Tenants,cn=IdentityManager,cn=Services,dc=vsphere,dc=local' > /tmp/ad.ldif"
                            Invoke-SshCommand -ComputerName $psc -Command "echo 'changetype: modify' >> /tmp/ad.ldif"
                            Invoke-SshCommand -ComputerName $psc -Command "echo 'replace: vmwSTSDefaultIdentityProvider' >> /tmp/ad.ldif"
                            Invoke-SshCommand -ComputerName $psc -Command "echo 'vmwSTSDefaultIdentityProvider: $domain' >> /tmp/ad.ldif"
                            Invoke-SshCommand -ComputerName $psc -Command "echo '-' >> /tmp/ad.ldif"
                            Invoke-SshCommand -ComputerName $psc -Command "/opt/likewise/bin/ldapmodify -f /tmp/ad.ldif -h localhost -p 11711 -D `"cn=Administrator,cn=Users,dc=vsphere,dc=local`" -w $creds_erpm"                
    }
    Else {
    Write-Output "Connection to " $psc "failed"
    exit
    }
Remove-sshSession -ComputerName $psc