param(
   [string]$hosta,
   [string]$credentials
)


if ( !$hosta  ) {
   Write-Host "Exiting: -host is required"
   exit
} 


if ( !$credentials ) {
   Write-Host "Exiting: -credentials is required"
   exit
} 


#SSH module for powershell has to be installed and imported.
#http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library

if (!(Get-module | where {$_.Name -eq "SSH-Sessions"})) {
	Import-Module SSH-Sessions
}

#Print the password on the screen
write-host "Password retrieved is equal to $credentials "
#SSH connection to host
$sessionA = $(New-SshSession -ComputerName $hosta -Username root -Password "oldpassword")
					#write-host "session - $session"
					if ($sessionA -match "Successfully connected") {
						write-host -foregroundcolor Green "Connected to $hosta"
						#Invoke change passwords command
						Invoke-SshCommand -ComputerName $hosta -Command "echo 'root:'$credentials | chpasswd" -Verbose
						write-host -foregroundcolor Green "Password change invoked."
						Remove-SshSession -ComputerName $hosta
						}
						Else
						{
						write-host "Old Password doesn't match, checking if it has already been set"
						}
						#checking if the password has been already changed
						$sessionA1  = $(New-SshSession -ComputerName $hosta -Username root -Password $credentials)
							if ($sessionA1 -match "Successfully connected") {
							write-host -foregroundcolor Green "Successfully logged in with the new password for $host"
							}
							Else
							{
							write-host -foregroundcolor Red "Unable to login to the host with the new password."
							write-host -foregroundcolor Red "Please change the password manually."
							}
Remove-SshSession -ComputerName $hosta

