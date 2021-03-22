function Get-O365ServicingChannel {
    <#
    .SYNOPSIS
    Script to quickly determine what Office 365 servicing channel a PC is subscribed to
    
    .DESCRIPTION
    Script checks the local machine's registry key for Office 365 CDNUrl against the strings for either the Annual or Monthly channels and returns feedback
    
    .PARAMETER Quiet
    Parameter suppresses the GUI message box and limits output to just the console
    
    .EXAMPLE
    Get-O365ServicingChannel 
    
    .NOTES
        Author: Paul Boyer
        Date: 3-22-21
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Quiet
    )
     # Registry path
     [String]$REGISTRY = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Configuration";

    # CONSTANT: O365 CDN URLs
    [String]$ANNUAL = "http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114";
    [String]$MONTHLY = "http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60";

    # String to hold the servicing channel
    [string]$servicing_channel;

    # Flag to either return information or an error
    [bool]$ReturnError = $true;

    # Evaluate if the registry key matches the CDNUrl for either the Monthly or Annual channel. 
    if ($(Get-ItemPropertyValue -Path Registry::$REGISTRY -Name CDNBaseURL) -eq $ANNUAL) {
        $servicing_channel = "Annual"
        $ReturnError = $false;
    }elseif ($(Get-ItemPropertyValue -Path Registry::$REGISTRY -Name CDNBaseURL) -eq $MONTHLY) {
        $servicing_channel = "Monthly"
        $ReturnError = $false;
    }else{
        Write-Error "Unable to determine servicing channel for Office installation on this machine." -Category NotSpecified
    }

    # Display a message box reporting the servicing channel, unless the -Quiet flag is supplied
    if (-not $Quiet) {    
        if(-not $ReturnError){
            [System.Windows.Forms.MessageBox]::Show($("This PC ({0}) is on the {1} Office 365 Servicing Channel" -f $env:COMPUTERNAME,$servicing_channel),$MyInvocation.ScriptName.Substring($MyInvocation.ScriptName.LastIndexOf('\')+1),0,64) | Out-Null
        }else{
            [System.Windows.Forms.MessageBox]::Show($("Unable to determine the Office 365 Servicing Channel for this PC ({0})" -f $env:COMPUTERNAME),$MyInvocation.ScriptName.Substring($MyInvocation.ScriptName.LastIndexOf('\')+1),0,16) | Out-Null
        }
    }

    # Return the servicing channel to the console
    return $servicing_channel;
}