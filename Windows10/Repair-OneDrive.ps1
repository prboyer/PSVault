function Repair-OneDrive{
<#
.SYNOPSIS
Script to repair Microsoft OneDrive if it is no longer working properly.

.DESCRIPTION
Script manipulates registry to fix key that is preventing normal functionality. Additionally, OneDrive can be removed using the -Uninstall parameter

.PARAMETER Uninstall
Causes the script to remove the OneDrive program from the PC

.EXAMPLE
Repair-OneDrive

.LINK
https://answers.microsoft.com/en-us/msoffice/forum/msoffice_onedrivefb-mso_win10-mso_o365b/onedrive-will-not-start/687028ae-2d32-4783-ba28-2cf050e32670

.LINK
https://www.winhelponline.com/blog/reset-onedrive-windows-10/

.NOTES
    Author: Paul Boyer
    Date: 3-24-21
#>
[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Uninstall
)

if ($Uninstall) {
    # [String]$Reg_Path2 = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe";
    # [String]$Reg_Property2 = "UninstallString"

    # # Proceed with the uninstall if the the Uninstall String is in the registry
    # if($null -ne (Get-Item -Path "Registry::$Reg_Path2").GetValue($Reg_Property2)){
    #     # Get the uninstall string from the registry key
    #     $R = (Get-ItemPropertyValue -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe" -Name UninstallString)

    #     # Perform the uninstall
    #     Start-Process -FilePath $R.Substring(0,$R.IndexOf('/')).Trim(' ') -ArgumentList $R.Substring($R.IndexOf('/')).Trim(' ') -PassThru -Wait

    # }

    <# This was a half-baked feature and decided to not implement for now #>
    Write-Error -Exception $([System.NotImplementedException]::new("Uninstall function not implemented"))

}
else{
    # Make registry change noted on Microsoft Forum.  https://answers.microsoft.com/en-us/msoffice/forum/msoffice_onedrivefb-mso_win10-mso_o365b/onedrive-will-not-start/687028ae-2d32-4783-ba28-2cf050e32670
        [String]$Reg_Path1 = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\OneDrive"
        [String]$Reg_Property1 = "DisableFileSyncNGSC"

        # Set the offending registry value = 0
        if(Test-Path "Registry::$Reg_Path1"){
            (Get-ItemProperty -Path "Registry::$Reg_Path1" -Name $Reg_Property1) -and (Set-ItemProperty -Path "Registry::$Reg_Path1" -Name $Reg_Property1 -Value 0 ) | Out-Null;
        }

    # Reset using the local executable with the /reset parameter. https://www.winhelponline.com/blog/reset-onedrive-windows-10/
        Start-Process -FilePath "$env:LOCALAPPDATA\Microsoft\OneDrive\onedrive.exe" -ArgumentList "/reset" -Wait
        Start-Sleep -Seconds 10
        if( (Get-Process -Name OneDrive -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0){
            Start-Process -FilePath "$env:LOCALAPPDATA\Microsoft\OneDrive\onedrive.exe"
        }
    }
}