function Offboard-Asset {
    <#
    .SYNOPSIS
    Script to automate the removal of assets from Active Directory and SCCM

    .DESCRIPTION
    Script takes in a list of computer names and removes them from both Active Directory and SCCM. The default behavior is to confirm execution of the removal action, but this can be overridden with the -NoConfirm parameter

    .PARAMETER ComputerName
    String array of computer names

    .PARAMETER NoConfirm
    Switch parameter that tells the script to proceed with removing devices from AD and SCCM without user confirmation

    .PARAMETER SiteCode
    SCCM Site Code

    .PARAMETER SiteServer
    SCCM Site Server

    .EXAMPLE
    Offboard-Asset -ComputerName computer01.contoso.com

    .NOTES
        Author: Paul Boyer
        Date:   4-21-21
    #>
    param (
        [Parameter(mandatory=$true)]
        [String[]]
        $ComputerName,
        [Parameter()]
        [switch]
        $NoConfirm,
        [Parameter(ParameterSetName='SCCM',Mandatory=$true)]
        [String]
        $SiteCode,
        [Parameter(ParameterSetName='SCCM',Mandatory=$true)]
        [String]
        $SiteServer
    )
    #Requires -Module ActiveDirectory
    #Requires -Module ConfigurationManager

    ## Variables ##
        # SCCM site code. Required for connecting to SCCM.
        [String]$SCCM_SITECODE = "SSC"

        # SCCM server hostname. Required for connecting to SCCM
        [String]$SCCM_SERVER = "mendez.ads.ssc.wisc.edu"

        # Override the variables above if passed on the command line
        if (($SiteCode -ne "") -and ($SiteServer -ne "")) {
            $SCCM_SITECODE = $SiteCode;
            $SCCM_SERVER = $SiteServer;
        }

    ## CONNECT TO SCCM ##
        # Uncomment the line below if running in an environment where script signing is
        # required.
        #Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

        # Site configuration
        $SiteCode = $SCCM_SITECODE # Site code
        $ProviderMachineName = $SCCM_SERVER # SMS Provider machine name

        # Customizations
        $initParams = @{}
        #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
        #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

        # Import the ConfigurationManager.psd1 module
        if($null -eq (Get-Module ConfigurationManager)) {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
        }

        # Connect to the site's drive if it is not already present
        if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
        }

        # Get the current location
        [String]$currentWorkingDir = (Get-Location).Path

        # Set the current location to be the site code.
        Set-Location "$($SiteCode):\" @initParams

    foreach($Computer in $ComputerName){
        # Remove Device from Active Directory
        Write-Host "`nRemove Computer from Active Directory`n"
        try {
            if ($NoConfirm) {
                # Removed the computer after finding in AD, and don't ask user to confirm action
                Get-ADComputer -Identity $Computer | Remove-ADComputer
            }else{
                # Removed the computer after finding in AD, and confirm the action
                Get-ADComputer -Identity $Computer | Remove-ADComputer -Confirm
            }
            Write-Host ("{0} removed from Active Directory" -f $Computer.ToUpper()) -ForegroundColor Green
        }
        # Error handling will catch the thrown exception if the computer cannot be located in AD
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            Write-Error ("Unable to find computer {0} in Active Directory" -f $Computer.ToUpper())
        }

        # Remove Device from SCCM
        Write-Host "`nRemove Computer from SCCM`n"

        try {
            [Object]$device = Get-CMDevice -Name $Computer

            # Try to get the device from SCCM. If null, then throw an exception
            if ($null -eq $device) {
                throw [System.ArgumentNullException]::new($("Unable to find computer {0} in SCCM Database" -f $Computer.ToUpper()))
            }else{
                # Remove the device without confirming the action, only if -NoConfirm is passed
                if ($NoConfirm) {
                    Remove-CMDevice $Computer
                }else{
                    Remove-CMDevice $Computer -Confirm
                }

                Write-Host ("{0} removed from SCCM" -f $Computer.ToUpper()) -ForegroundColor Green
            }
        }
        catch [System.ArgumentNullException]{
            Write-Error $Error[0].Exception
        }
    }

    # Set the location back to the original location script was called from
    Set-Location $currentWorkingDir
}