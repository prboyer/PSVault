function Repair-OneDrive{
[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Uninstall
)

# Make registry change noted on Microsoft Forum.  https://answers.microsoft.com/en-us/msoffice/forum/msoffice_onedrivefb-mso_win10-mso_o365b/onedrive-will-not-start/687028ae-2d32-4783-ba28-2cf050e32670
    [String]$Reg_Path1 = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\OneDrive"
    [String]$Reg_Property1 = "DisableFileSyncNGSC"

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