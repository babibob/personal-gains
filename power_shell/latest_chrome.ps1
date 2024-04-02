
<##################################################################
 INSTALL LATEST Chrome ############################################
##################################################################>

$Install_chrome = Read-Host -Prompt 'Are you want to install latest Google Chrome (y/n)?'
if (($Install_chrome.ToLower() -eq 'y') -or ($Install_chrome.ToLower() -eq 'yes'))
{
    echo "Starting install"
    $LocalTempDir = $env:TEMP
    $ChromeInstaller = "ChromeInstaller.exe"
    $DownloadURL = "http://dl.google.com/chrome/install/latest/chrome_installer.exe"
    (new-object System.Net.WebClient).DownloadFile("$DownloadURL", "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install
    $Process2Monitor = "ChromeInstaller"
    Do {
        $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name
        If ($ProcessesFound) {
            "Still running: $($ProcessesFound -join ', ')" | Write-Host ; Start-Sleep -Seconds 2
        } else {
            rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose
    } }
    Until (!$ProcessesFound)
} else {
echo 'Ne ochen i hotelos'
}
