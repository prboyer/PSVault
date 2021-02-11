function Remove-UpdateAssistant {
<#
.SYNOPSIS
Script to remove the Windows 10 Upgrade Assistant

.DESCRIPTION
Script tries to uninstall the Windows 10 Upgrade Assistant if it is detected on the system. Then it removes the assistant's working files and optionally reboots to
complete the cleanup.

.PARAMETER Reboot
Switch parameter to indicate a reboot should be performed after the script finishes uninstalling and cleaning up the update assistant

.EXAMPLE
Remove-UpdateAssistant

.EXAMPLE
Remove-UpdateAssistant -Reboot

.NOTES
Paul Boyer 2-11-2021
#>
    param (
        [Parameter]
        [Switch]
        $Reboot
    )

    # Check to see if the Windows 10 upgrade folder exists on the system drive 
    if(Test-Path -Path "$env:SystemDrive\Windows10Upgrade"){
        try{
            # Try to remove the upgrade assistant application
            Start-Process -FilePath "$env:SystemDrive\Windows10Upgrade\Windows10UpgraderApp.exe" -ArgumentList "/ForceUninstall" -Wait -NoNewWindow
        }
        catch{
            Write-Error "Could not force uninstallation of Windows 10 Upgrade App" -ErrorAction Continue
        }
        finally{
            # Remove the directory(s) where the upgrade assistant is installed
            Remove-Item -Force -Recurse -Path "$env:SystemDrive\Windows10Upgrade"
            Remove-Item -Force -Recurse -Path "$env:windir\UpdateAssistant*"
        }
    }else {
        Write-Error "Upgrade app not installed, already removed, or not found."
    }
    
    # If the Reboot parameter is specified, then reboot the machine. 
    if($Reboot){
        & shutdown.exe /r /t 30 /C "Windows 10 Update Assistant Cleanup"
    }
    
}








