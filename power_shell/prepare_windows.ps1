<##################################################################
 PREPARE HOST FOR SSH CONNECT #####################################
##################################################################>

# WINDOWS 2016 #####################################
# WINDOWS 2016 #####################################
# WINDOWS 2016 #####################################
# Install the OpenSSH Server manually
<#
0) Copy URL  to destination server for latest version, run from bash on your laptop
    curl -s https://api.github.com/repos/PowerShell/Win32-OpenSSH/releases/latest | jq '.assets[] | .browser_download_url | select(test(".OpenSSH-Win64.*.msi"))'
or check URL on target server via browser
    https://github.com/PowerShell/Win32-OpenSSH/releases

1) Download OpenSSH.msi from URL

2) Run in Powershell as admin
    msiexec.exe /i C:\Users\$env:username\Downloads\<download file name> ADDLOCAL=Server

3) Add to PATH environment
    [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::Machine) + ';' + ${Env:ProgramFiles} + '\OpenSSH', [System.EnvironmentVariableTarget]::Machine)

4) Start and autorun the sshd service
    Get-Service -Name ssh*
    Start-Service sshd -Verbose
    Set-Service -Name sshd -StartupType 'Automatic' -Verbose
#>
# WINDOWS 2016 #####################################
# WINDOWS 2016 #####################################
# WINDOWS 2016 #####################################


#Check if current user have administrator permissions
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
    echo "Installing the OpenSSH Server"
    # Enable Windows update
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

    # dism /online /Remove-Capability /CapabilityName:OpenSSH.Client~~~~0.0.1.0 #Delete
    }

    # Start and autorun the sshd service
    Start-Service sshd -Verbose
    Set-Service -Name sshd -StartupType 'Automatic' -Verbose

    # Configuring the default ssh shell
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

<##################################################################
 FIREWALL RULE FOR SSH ACCESS #####################################
##################################################################>

    # Confirm the Firewall rule is configured. It should be created automatically by setup.
    Import-Module NetSecurity
    $name = "sshd"
    $description = "OpenSSH Server Inbound via TCP"
    $protocol = "TCP"
    $port = 22
    [Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetSecurity.Profile] $profile = "any"
    [Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetSecurity.Direction] $direction = "Inbound"
    $ip_list = "any"
    if (Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue)
    {
        echo "${direction} rule ${name}/${description}: Found!"
    } else {
        echo "${direction} rule ${name}/${description}: Not found, adding!"
        New-NetFirewallRule -DisplayName $name -Description $description -LocalPort $port -Profile $profile -Direction $direction -Protocol $protocol -RemoteAddress $ip_list
    }

<##################################################################
 CREATE USER AND GROUP ############################################
##################################################################>

#User to search for and create, for send list use >> ('Netwrix',’Netwrix Users')
$USERNAME = "CI-user"
$AuthorizedKey = "<SSH PUBLIC KEY>"
$AuthorizedKey_Path = "C:\ProgramData\ssh\administrators_authorized_keys"
$SSHD_CONFIG="C:\ProgramData\ssh\sshd_config"

#Group to search for and create
$GROUPNAME = "ssh-access"

# Base64 string with ssh_config
$base64_ssh_conf = "UGVybWl0Um9vdExvZ2luIG5vClN0cmljdE1vZGVzIG5vClB1YmtleUF1dGhlbnRpY2F0aW9uIHllcwpBdXRob3JpemVkS2V5c0ZpbGUJLnNzaC9hdXRob3JpemVkX2tleXMKUGFzc3dvcmRBdXRoZW50aWNhdGlvbiBubwpQZXJtaXRFbXB0eVBhc3N3b3JkcyBubwpTdWJzeXN0ZW0Jc2Z0cAlzZnRwLXNlcnZlci5leGUKTWF0Y2ggZ3JvdXAgc3NoLWFjY2VzcyBVc2VyICoKICAgIEF1dGhvcml6ZWRLZXlzRmlsZSBDOlxQcm9ncmFtRGF0YVxzc2hcYWRtaW5pc3RyYXRvcnNfYXV0aG9yaXplZF9rZXlzCg=="

<#
full version sshd_config
$base64_ssh_conf = "GlzIHRoZSBzc2hkIHNlcnZlciBzeXN0ZW0td2lkZSBjb25maWd1cmF0aW9uIGZpbGUuICBTZWUKIyBzc2hkX2NvbmZpZyg1KSBmb3IgbW9yZSBpbmZvcm1hdGlvbi4KCiMgVGhlIHN0cmF0ZWd5IHVzZWQgZm9yIG9wdGlvbnMgaW4gdGhlIGRlZmF1bHQgc3NoZF9jb25maWcgc2hpcHBlZCB3aXRoCiMgT3BlblNTSCBpcyB0byBzcGVjaWZ5IG9wdGlvbnMgd2l0aCB0aGVpciBkZWZhdWx0IHZhbHVlIHdoZXJlCiMgcG9zc2libGUsIGJ1dCBsZWF2ZSB0aGVtIGNvbW1lbnRlZC4gIFVuY29tbWVudGVkIG9wdGlvbnMgb3ZlcnJpZGUgdGhlCiMgZGVmYXVsdCB2YWx1ZS4KCiNQb3J0IDIyCiNBZGRyZXNzRmFtaWx5IGFueQojTGlzdGVuQWRkcmVzcyAwLjAuMC4wCiNMaXN0ZW5BZGRyZXNzIDo6CgojSG9zdEtleSBfX1BST0dSQU1EQVRBX18vc3NoL3NzaF9ob3N0X3JzYV9rZXkKI0hvc3RLZXkgX19QUk9HUkFNREFUQV9fL3NzaC9zc2hfaG9zdF9kc2Ffa2V5CiNIb3N0S2V5IF9fUFJPR1JBTURBVEFfXy9zc2gvc3NoX2hvc3RfZWNkc2Ffa2V5CiNIb3N0S2V5IF9fUFJPR1JBTURBVEFfXy9zc2gvc3NoX2hvc3RfZWQyNTUxOV9rZXkKCiMgQ2lwaGVycyBhbmQga2V5aW5nCiNSZWtleUxpbWl0IGRlZmF1bHQgbm9uZQoKIyBMb2dnaW5nCiNTeXNsb2dGYWNpbGl0eSBBVVRICiNMb2dMZXZlbCBJTkZPCgojIEF1dGhlbnRpY2F0aW9uOgoKI0xvZ2luR3JhY2VUaW1lIDJtClBlcm1pdFJvb3RMb2dpbiBubwpTdHJpY3RNb2RlcyBubwojTWF4QXV0aFRyaWVzIDYKI01heFNlc3Npb25zIDEwCgpQdWJrZXlBdXRoZW50aWNhdGlvbiB5ZXMKCiMgVGhlIGRlZmF1bHQgaXMgdG8gY2hlY2sgYm90aCAuc3NoL2F1dGhvcml6ZWRfa2V5cyBhbmQgLnNzaC9hdXRob3JpemVkX2tleXMyCiMgYnV0IHRoaXMgaXMgb3ZlcnJpZGRlbiBzbyBpbnN0YWxsYXRpb25zIHdpbGwgb25seSBjaGVjayAuc3NoL2F1dGhvcml6ZWRfa2V5cwpBdXRob3JpemVkS2V5c0ZpbGUJLnNzaC9hdXRob3JpemVkX2tleXMKCiNBdXRob3JpemVkUHJpbmNpcGFsc0ZpbGUgbm9uZQoKIyBGb3IgdGhpcyB0byB3b3JrIHlvdSB3aWxsIGFsc28gbmVlZCBob3N0IGtleXMgaW4gJXByb2dyYW1EYXRhJS9zc2gvc3NoX2tub3duX2hvc3RzCiNIb3N0YmFzZWRBdXRoZW50aWNhdGlvbiBubwojIENoYW5nZSB0byB5ZXMgaWYgeW91IGRvbid0IHRydXN0IH4vLnNzaC9rbm93bl9ob3N0cyBmb3IKIyBIb3N0YmFzZWRBdXRoZW50aWNhdGlvbgojSWdub3JlVXNlcktub3duSG9zdHMgbm8KIyBEb24ndCByZWFkIHRoZSB1c2VyJ3Mgfi8ucmhvc3RzIGFuZCB+Ly5zaG9zdHMgZmlsZXMKI0lnbm9yZVJob3N0cyB5ZXMKCiMgVG8gZGlzYWJsZSB0dW5uZWxlZCBjbGVhciB0ZXh0IHBhc3N3b3JkcywgY2hhbmdlIHRvIG5vIGhlcmUhClBhc3N3b3JkQXV0aGVudGljYXRpb24gbm8KUGVybWl0RW1wdHlQYXNzd29yZHMgbm8KCiNBbGxvd0FnZW50Rm9yd2FyZGluZyB5ZXMKI0FsbG93VGNwRm9yd2FyZGluZyB5ZXMKI0dhdGV3YXlQb3J0cyBubwojUGVybWl0VFRZIHllcwojUHJpbnRNb3RkIHllcwojUHJpbnRMYXN0TG9nIHllcwojVENQS2VlcEFsaXZlIHllcwojVXNlTG9naW4gbm8KI1Blcm1pdFVzZXJFbnZpcm9ubWVudCBubwojQ2xpZW50QWxpdmVJbnRlcnZhbCAwCiNDbGllbnRBbGl2ZUNvdW50TWF4IDMKI1VzZUROUyBubwojUGlkRmlsZSAvdmFyL3J1bi9zc2hkLnBpZAojTWF4U3RhcnR1cHMgMTA6MzA6MTAwCiNQZXJtaXRUdW5uZWwgbm8KI0Nocm9vdERpcmVjdG9yeSBub25lCiNWZXJzaW9uQWRkZW5kdW0gbm9uZQoKIyBubyBkZWZhdWx0IGJhbm5lciBwYXRoCiNCYW5uZXIgbm9uZQoKIyBvdmVycmlkZSBkZWZhdWx0IG9mIG5vIHN1YnN5c3RlbXMKU3Vic3lzdGVtCXNmdHAJc2Z0cC1zZXJ2ZXIuZXhlCgojIEV4YW1wbGUgb2Ygb3ZlcnJpZGluZyBzZXR0aW5ncyBvbiBhIHBlci11c2VyIGJhc2lzCiNNYXRjaCBVc2VyIGFub25jdnMKIwlBbGxvd1RjcEZvcndhcmRpbmcgbm8KIwlQZXJtaXRUVFkgbm8KIwlGb3JjZUNvbW1hbmQgY3ZzIHNlcnZlcgoKI01hdGNoIEdyb3VwIGFkbWluaXN0cmF0b3JzCiMgICAgICAgQXV0aG9yaXplZEtleXNGaWxlIF9fUFJPR1JBTURBVEFfXy9zc2gvYWRtaW5pc3RyYXRvcnNfYXV0aG9yaXplZF9rZXlzCgpNYXRjaCBncm91cCBzc2gtYWNjZXNzIFVzZXIgKgogICAgQXV0aG9yaXplZEtleXNGaWxlIEM6XFByb2dyYW1EYXRhXHNzaFxhZG1pbmlzdHJhdG9yc19hdXRob3JpemVkX2tleXMK"
#>

#Check if group exist
if ($null -eq (Get-LocalGroup -Name $GROUPNAME -ErrorAction SilentlyContinue)) {

    #Create group if not exist
    Write-Host "Creating Group $($GROUPNAME)"
    New-LocalGroup -Name $GROUPNAME -Description "$($GROUPNAME) Group"
    } else {
    Write-Host "Group $($GROUPNAME) was found"
}

#Check if user exist
if ($null -eq (Get-LocalUser -Name $USERNAME -ErrorAction SilentlyContinue)) {

    #If user not exist create it
    Write-Host "Creating User $($USERNAME)"
    New-LocalUser -Name $USERNAME `
    -FullName "$($USERNAME) service user" `
    -Description "CI administrator of this Server" `
    -Password (ConvertTo-SecureString(("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | Get-Random -count 20) -join '') -AsPlainText -Force) `
    -PasswordNeverExpires `
    -AccountNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $USERNAME -Verbose
    Add-LocalGroupMember -Group $GROUPNAME -Member $USERNAME -Verbose

    Write-Host "Add ssh key for $($USERNAME) in  file $($AuthorizedKey_Path)"
    Add-Content -Force -Path "$($AuthorizedKey_Path)" -Value "$($AuthorizedKey)"
    icacls.exe ""$($AuthorizedKey_Path)"" /inheritance:r /grant ""Administrators:F"" /grant ""SYSTEM:F""

    } else {
    Write-Host "User $($USERNAME) was found"
}

<##################################################################
 RECONFIG SSHD SERVICE ############################################
##################################################################>

#Create default config
Rename-Item -Path $SSHD_CONFIG -NewName "$SSHD_CONFIG.default" -Verbose
#Create actual config
Write-Host "Configurations in sshd_config with access only for $($GROUPNAME) group"
[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($base64_ssh_conf)) | Out-File -Encoding "ASCII" $SSHD_CONFIG -Verbose

# Partially modify the configuration file
# (Get-Content $SSHD_CONFIG) -replace '#PermitRootLogin prohibit-password', 'PermitRootLogin no' | Out-File -encoding ASCII $SSHD_CONFIG
# (Get-Content $SSHD_CONFIG) -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' | Out-File -encoding ASCII $SSHD_CONFIG
# (Get-Content $SSHD_CONFIG) -replace '#PasswordAuthentication yes', 'PasswordAuthentication no' | Out-File -encoding ASCII $SSHD_CONFIG
# (Get-Content $SSHD_CONFIG) -replace '#PermitEmptyPasswords no', 'PermitEmptyPasswords no' | Out-File -encoding ASCII $SSHD_CONFIG
# Add-Content -Path $SSHD_CONFIG 'Match group ssh-access User *'
# Add-Content -Path $SSHD_CONFIG "	AuthorizedKeysFile $($AuthorizedKey_Path)"

Write-Host "Show $($SSHD_CONFIG) file"
cat $SSHD_CONFIG
Write-Host "Show administrators_authorized_keys file"
cat "$($AuthorizedKey_Path)"

Restart-Service sshd -Verbose

if (!(Get-LocalUser sshd -ErrorAction SilentlyContinue)) {
    Write-Host "User sshd not exist"
} else {
    Disable-LocalUser -Name "sshd" -Verbose
}
