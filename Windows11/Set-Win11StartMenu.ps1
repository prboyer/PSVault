function Set-Win11StartMenu {
<#
.SYNOPSIS
Script to modify the appearance of the Windows 11 Start Menu.

.DESCRIPTION
The script modifies a registry key in HKCU to change the appearance of the Start Menu.

.PARAMETER Win10Style
Passing the Win10Style parameter will revert the Start Menu to its previous style. Omitting the parameter on a subsequent run will reset it to the Windows 11 style

.EXAMPLE
PS C:> Set-Win11StartMenu -Win10Style

Sets the Start Menu to the Windows 10 style.

.EXAMPLE
PS C:> Set-Win11StartMenu

Restores the Start Menu back to the original Windows 11 style.

.LINK
https://www.pcworld.com/article/3622022/windows-11-start-menu-how-to-make-it-look-like-windows-10.html

.NOTES
    Author: Paul Boyer
    Date: 6-28-2021
#> 
    param (
        [Parameter()]
        [Switch]
        $Win10Style
    )

[String]$REGISTRY_PATH = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\"
[String]$REGISTRY_KEY = "Start_ShowClassicMode"

# Check if the -Win10Style switch was passed
if ($Win10Style) {
    # Check if the Start_ShowClassicMode key already exists
    if (Test-Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY") {
        # If the key already exists, set the value to 1 to enable Win10 style start menu
        Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 1
    }else{
        # Otherwise create the key
        New-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -PropertyType DWORD -Value 1
    }
}else{
    # Set the start menu back to the Windows 11 Style
    Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 0
}

Write-Host "The computer will need to restart to apply the changes to the Start Menu" -ForegroundColor Yellow
}