<#
    Author:  Graham Foral
    Date:    September 17, 2023
    Purpose: Remove Chrome Web Apps and Folder from user's start menu.
        
    Instructions:    Run script, without parameters. No need for elevation.
    Desired Context: Run in user context.


#>


$WshShell  = New-Object -ComObject  WScript.Shell

$StartApps = Join-Path -Path $env:APPDATA -ChildPath "\Microsoft\Windows\Start Menu\Programs\Chrome Apps"
$LocalApps = Join-Path -Path $env:USERPROFILE -ChildPath "\AppData\Local\Google\Chrome\User Data\Default\Web Applications"

Write-Output "Removing Start Menu Items -"
Write-Output "===`n"

If(Test-Path -Path $StartApps) {
    $Shortcuts       = Get-ChildItem -Path $StartApps
    $ShortcutPartent = $Shortcuts

    ForEach($Shortcut in $Shortcuts) {
        Write-Output "Removing Folder:`t$StartApps"
        Write-Output "Removing Shortcut:`t$($Shortcut.FullName)`n"

        $lnk = $WshShell.CreateShortcut($Shortcut.FullName)
        $lnk | Select-Object -Property *

        [System.IO.File]::Delete($Shortcut.FullName)
        Write-Output "-----`n`n"
    }
    
    [System.IO.Directory]::Delete($StartApps, $True)
}

Write-Output "Removing Unused Resources -"
Write-Output "===`n"


If(Test-Path -Path $LocalApps) {
    $crxdirs = Get-ChildItem -Path $LocalApps -Filter "_crx_*"

    ForEach($crxdir in $crxdirs) {

        Write-Output "Removing Folder:`t$($crxdir.FullName) ($((Get-ChildItem -Path $crxdir.FullName -Include *.ico -Recurse -ErrorAction SilentlyContinue).BaseName))"
        [System.IO.Directory]::Delete($crxdir.FullName, $True)

    }
}

$UserUninstall = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

$UserInstallChildren = (Get-ChildItem -Path $UserUninstall).PSChildName
$ChromeApps = @()

ForEach($UserInstallChild in $UserInstallChildren) {
    $KeyPath = Join-Path -Path $UserUninstall -ChildPath $UserInstallChild
    $ChromeApps += Get-ItemProperty -Path $KeyPath | Where-Object { $_.Publisher -eq "Google\Chrome" }
}
$ChromeApps | Remove-Item -Force