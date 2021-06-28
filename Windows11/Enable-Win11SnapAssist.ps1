function Enable-Win11SnapAssist {
    <#
    .SYNOPSIS
    Script to enable or disable Windows 11 Snap Assist functionality.
    
    .DESCRIPTION
    Enable or disable the Snap Assist functionality by modifying the registry key in HKCU. Running the script with no parameter re-enables Snap Assist
    
    .PARAMETER Disable
    Parameter that causes the script to disable the Snap Assist functionality
    
    .EXAMPLE
    PS C:> Enable-Win11SnapAssist -Disable

    Disable Snap Assist

    .LINK
    https://www.pcworld.com/article/3622022/windows-11-start-menu-how-to-make-it-look-like-windows-10.html
    
    .NOTES
        Author: Paul Boyer
        Date: 6-28-2021
    #>
    param (
        [Parameter()]
        [switch]
        $Disable
    )
    
    [String]$REGISTRY_PATH = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\"
    [String]$REGISTRY_KEY = "EnableSnapAssistFlyout"

    # Check if the registry key already exists
    if (-not (Test-Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY")) {
        # Create the registry key if it does not already exist
        New-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -PropertyType DWORD -Value 1
    }

    # If the -Disable parameter is specified, then disable Snap Assist
    if ($Disable) {
        Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 0
    }else{
        Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 1
    }

    # Restart Windows Explorer to apply the change
    Stop-Process -Name explorer
}