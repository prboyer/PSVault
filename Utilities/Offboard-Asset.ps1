function Offboard-Asset {
    param (
        [Parameter(mandatory=$true)]
        [String]
        $ComputerName
    )
    #Requires -Module ActiveDirectory
    #Requires -Module ConfigurationManager

    ## Variables ##
        # SCCM site code. Required for connecting to SCCM.
        [String]$SCCM_SITECODE = "SSC"

        # SCCM server hostname. Required for connecting to SCCM
        [String]$SCCM_HOSTNAME = "mendez.ads.ssc.wisc.edu"

    ## CONNECT TO SCCM ##
        # Uncomment the line below if running in an environment where script signing is 
        # required.
        #Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

        # Site configuration
        $SiteCode = $SCCM_SITECODE # Site code 
        $ProviderMachineName = $SCCM_HOSTNAME # SMS Provider machine name

        # Customizations
        $initParams = @{}
        #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
        #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

        # Import the ConfigurationManager.psd1 module 
        if((Get-Module ConfigurationManager) -eq $null) {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
        }

        # Connect to the site's drive if it is not already present
        if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
        }

        # Get the current location
        [String]$currentWorkingDir = (Get-Location).Path

        # Set the current location to be the site code.
        Set-Location "$($SiteCode):\" @initParams
    
    # Remove Device from Active Directory
        Write-Host "`nRemove Computer from Active Directory`n"
        try {
            Get-ADComputer -Identity $ComputerName | Remove-ADComputer -Confirm
            Write-Host ("{0} removed from Active Directory" -f $ComputerName.ToUpper()) -ForegroundColor Green
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            Write-Error ("Unable to find computer {0} in Active Directory" -f $ComputerName.ToUpper())
        }

    # Remove Device from SCCM






# Set the location back to the original location script was called from
Set-Location $currentWorkingDir

}


Offboard-Asset



#$$$$ CONFIGURATION MANAGER $$$$

# Write-Host "Remove from Configuration Manager"

# if($table.Rows[1].'Workstation Asset Tag' -eq $null){
#     try{
#     Remove-CMDevice -Name $table.Rows[1].'Laptop Asset Tag' -Confirm
#     }
#     catch{
#     Write-Host $table.Rows[1].'Laptop Asset Tag' "not removed. Not found or does not exist" -ForegroundColor Red
#     }
# }
# else{
#     try{
#     Remove-CMDevice -Name $table.Rows[1].'Workstation Asset Tag' -Confirm
#     }
#     catch{
#     Write-Host $table.Rows[1].'Workstation Asset Tag' "not removed. Not found or does not exist" -ForegroundColor Red
#     }
# }
# Write-Host "Remove from Configuration Manager ... Complete" -ForegroundColor Green