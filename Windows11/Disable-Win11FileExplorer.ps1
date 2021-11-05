function Disable-Win11FileExplorer {
     <#
    .SYNOPSIS
    Script to disable the Windows 11 file explorer and bring back the full Windows 10 file explorer.
    
    .DESCRIPTION
    PowerShell Script to disable the indows 11 file explorer by modifying the HKLM registry hive thus bringing back the full Windows 10  file explorer.

    .PARAMETER Enable
    If you want to enable the Windows 11 file explorer, use the -Enable switch.

    .LINK
    https://www.tomshardware.com/how-to/restore-windows-10-explorer-windows-11
    
    .NOTES
        Author: Paul Boyer
        Date: 11-05-2021
    #>
    param (
        [Parameter()]
        [switch]
        $Enable
    )

    # Variables
    [String]$REGISTRY_PATH = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions"
    [String]$REGISTRY_KEY = "Blocked"
    [String]$REGISTRY_VALUE = "{e2bf9676-5f8f-435c-97eb-11607a5bedf7}"

    # Check if the registry key already exists
    if (-not (Test-Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY")) {
        # Create the registry key if it does not already exist
        New-Item -Path "Registry::$REGISTRY_PATH" -Name "$REGISTRY_KEY" -Force
    }

    try{
        if ($Enable) {
            # Delete the registry value to enable the Windows 11 file explorer
            Remove-ItemProperty -Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY" -Name $REGISTRY_VALUE -Force
        }else{
            # Create a String value to disable the Windows 11 file explorer
            New-ItemProperty -Name "{e2bf9676-5f8f-435c-97eb-11607a5bedf7}" -Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY" -Value "" -PropertyType String
        }

        Write-Host "Restart your computer to finish applying changes." -ForegroundColor Yellow

    }catch [UnauthorizedAccessException],[System.Management.Automation.ItemNotFoundException]{
        Write-Error "Unable to modify the Registry`n`tError: $($_.Exception.Message)"
    }
}