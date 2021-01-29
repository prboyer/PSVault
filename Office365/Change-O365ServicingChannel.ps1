function Change-O365ServicingChannel {
    <#
    .SYNOPSIS
    A quick and handy script for modifying the Windows Registry to switch the Office 365 servicing channel. 
    
    .DESCRIPTION
    The script switches Office 365 applications between monthly and semi-annual servicing channels by manipulating the 
    appropriate registry key in the HKLM hive. By default, the script will set the local machine to the semi-annual servicing channel.
    By using the -Monthly parameter, the servicing channel will be updated. 
    
    .PARAMETER Monthly
    Switch parameter that changes the default behavior of the script. Causes the servicing channel to be set to Monthly, rather than Semi Annual.
    
    .EXAMPLE
    Change-O365ServicingChannel -Monthly
    
    .LINK
    https://www.solver.com/switching-office-365-monthly-update-channel

    .NOTES
    Author: Paul Boyer - 1-29-2021
    
    #>
    param (
        [switch]$Monthly
    )
    
    # Registry path to update
    [String]$REGISTRY = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Configuration";
    
    # CONSTATNS: O365 CDN URLs
    [String]$ANNUAL = "http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114";
    [String]$MONTHLY = "http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60";

    if ($Monthly) {
        Write-Host "Setting Servicing Channel to Monthly"
        Set-ItemProperty -Path "Registry::$REGISTRY" -Name CDNBaseURL -Value $MONTHLY
    }else{
        Write-Host "Setting Servicing Channel to Semi-Annual (Default)"
        Set-ItemProperty -Path "Registry::$REGISTRY" -Name CDNBaseURL -Value $ANNUAL
    }
}