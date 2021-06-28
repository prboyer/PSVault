function Set-Win11TaskbarSize {
    <#
    .SYNOPSIS
    Script used to set the Windows 11 Taskbar Size
    
    .DESCRIPTION
    The script can be called with three different arguments (Small, Medium, Large). If no parameter is passed, the taskbar is reverted to the default Windows 11 size (Medium)
    
    .PARAMETER Small
    Parameter that causes the script to set the taskbar size to Small
    
    .PARAMETER Medium
    Parameter that causes the script to set the taskbar size to Medium
    
    .PARAMETER Large
    Parameter that causes the script to set the taskbar size to Large
    
    .EXAMPLE
    PS C:> Set-Win11TaskbarSize -Large

    Sets the Windows Taskbar size to large.

    .LINK
    https://www.bleepingcomputer.com/news/microsoft/new-windows-11-registry-hacks-to-customize-your-device/
    
    .NOTES
        Author: Paul Boyer
        Date: 6-28-2021
    #>
    param (
        [Parameter(ParameterSetName="Small")]
        [Switch]
        $Small,
        [Parameter(ParameterSetName="Medium")]
        [Switch]
        $Medium,
        [Parameter(ParameterSetName="Large")]
        [Switch]
        $Large
    )
    
    [String]$REGISTRY_PATH = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\"
    [String]$REGISTRY_KEY = "TaskbarSi"

    # Check if the registry key already exists
    if (-not (Test-Path "Registry::$REGISTRY_PATH\$REGISTRY_KEY")) {
        # Create the registry key if it does not already exist
        New-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -PropertyType DWORD -Value 1
    }

    # Set the taskbar to small
    if($Small){
        Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 0
    }else{
        # Set the taskbar to medium
        if($Medium){
            Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 1
        }else{
            # Set the taskbar to large
            if($Large){
                Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 2
            }
        }
    }else{
        # If no parameter is passed, the taskbar is set back to the default size
        Set-ItemProperty -Path "Registry::$REGISTRY_PATH" -Name $REGISTRY_KEY -Value 1
    }

    # Restart Windows Explorer to apply the change
    Stop-Process -Name explorer
}