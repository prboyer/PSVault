function Disable-Win11ContextMenu {
    <#
    .SYNOPSIS
    Script to disable the Windows 11 context menu and bring back the full Windows 10 context menu.
    
    .DESCRIPTION
    PowerShell Script to disable the Windows 11 context menu by modifying the HKCU registry hive thus bringing back the full Windows 10 context menu.

    .LINK
    https://www.tomshardware.com/how-to/windows-11-classic-context-menus
    
    .NOTES
        Author: Paul Boyer
        Date: 11-02-2021
    #>
    [String]$REGISTRY_PATH = "HKEY_CURRENT_USER\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
    [String]$REGISTRY_KEY = "InprocServer32"

    # Check if the registry key already exists
    if (-not (Test-Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY")) {
        # Create the registry key if it does not already exist
        New-Item -Path "Registry::$REGISTRY_PATH" -Name "$REGISTRY_KEY" -Force
    }

    # Clear the value for the default key
    Set-ItemProperty -Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY" -Name "(default)" -Value ""
}