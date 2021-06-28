function Set-Win11TaskbarPosition {
    <#
    .SYNOPSIS
    Script that sets the position of the Windows 11 taskbar.
    
    .DESCRIPTION
    Manipulate the position of the Windows 11 taskbar by modifying the registry key in HKCU. 
    
    .PARAMETER Left
    Parameter that causes the script to position the taskbar aligned to the left
    
    .PARAMETER Center
    Parameter that causes the script to position the taskbar aligned center.
    
    .EXAMPLE
    PS C:> Set-Win11TaskbarPosition -Left

    Sets the taskbar to be aligned to the left.

    .LINK
    https://www.bleepingcomputer.com/news/microsoft/new-windows-11-registry-hacks-to-customize-your-device/
    
    .NOTES
        Author: Paul Boyer
        Date: 6-28-2021
    #>
    param (
        [Parameter()]
        [switch]
        $Left,
        [Parameter()]
        [switch]
        $Center
    )
    
    [String]$REGISTRY_PATH = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\"
    [String]$REGISTRY_KEY = "TaskbarAl"

    # Check if the registry key already exists
    if (-not (Test-Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY")) {
        # Create the registry key if it does not already exist
        New-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -PropertyType DWORD -Value 1
    }

    # Set taskbar alignment to the left if the -Left parameter is passed
    if($Left){
        Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 0
    }

    # Set taskbar alignment to the center if the -Center parameter is passed
    if($Center){
        Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 1
    }

    # Restart Windows Explorer to apply the change
    Stop-Process -Name explorer
}