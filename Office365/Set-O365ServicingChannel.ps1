function Set-O365ServicingChannel {
    <#
    .SYNOPSIS
    A quick and handy script for modifying the Windows Registry to switch the Office 365 servicing channel. 
    
    .DESCRIPTION
    The script switches Office 365 applications between monthly and semi-annual servicing channels by either using the Office C2R client or manipulating the 
    appropriate registry key in the HKLM hive. By default, the script will set the local machine to the semi-annual servicing channel.
    
    .PARAMETER Monthly
    Switch parameter that changes the default behavior of the script. Causes the servicing channel to be set to Monthly, rather than Semi Annual.
    
    .PARAMETER UseRegistry
    Switch parameter that forces the script to use the registry to update the servicing channel rather than the Office C2R client. 

    .EXAMPLE
    Change-O365ServicingChannel -Monthly
    
    .LINK
    https://docs.microsoft.com/en-us/deployoffice/overview-update-channels
    
    .LINK
    https://www.solver.com/switching-office-365-monthly-update-channel

    .LINK
    https://windowstechpro.com/switch-office-365-semi-channel-to-monthly-targeted-channel/

    .NOTES
    Author: Paul Boyer - 1-29-2021
    
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Monthly,
        [Parameter()]
        [switch]
        $UseRegistry
    )
    [String]$O365_PROGRAMFILES = "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\"

    # Only perform these steps if the -Registry parameter is passed. 
    if($UseRegistry){
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

        Write-Host "You need to reboot your computer to complete the requested changes."
        
        # show messagebox asking user to confirm instant reboot
        $Result = [System.Windows.MessageBox]::Show("Would you like to restart your computer now?",$Action,4,32);
        if($Result -eq 6){
            Restart-Computer -Force -Delay 0 
        }
        
    }else{
        # test that the path to the program files folder can be resolved
        if (Test-Path $O365_PROGRAMFILES) {
            
            # declare a variable for the servicing channel
            [String]$channel;
            if ($Monthly) {
                $channel = "Monthly";
            }else{
                $channel = "Annual";
            }

            # perform the servicing channel update
            Write-Host "Updating O365 Servicing Channel to $channel"
            
            Start-Process -FilePath "$O365_PROGRAMFILES\OfficeC2RClient.exe" -ArgumentList "/changesetting Channel=$channel" -NoNewWindow -Wait
            Start-Process -FilePath "$O365_PROGRAMFILES\OfficeC2RClient.exe" -ArgumentList "/update user" -Wait -NoNewWindow
            
            Write-Host "Update complete" -ForegroundColor Green
        }else{
            Write-Error "Unable to resolve path to Office 365 program files directory"
        }
    }   
}