function Build-MECMComputerReport{
    <#
    .SYNOPSIS
    Script that extracts computer information and user information from all assets in a given MECM collection

    .DESCRIPTION
    Using both MECM and ActiveDirectory data mining, generate a report of computers in a given collection and correlate corresponding user information.

    .PARAMETER Path
    The path where a csv report should be saved

    .PARAMETER ComputerNames
    A list of computer names to run the report against

    .PARAMETER CollectionName
    The name of the device collection in MECM to report on. Accepts wildcards.

    .PARAMETER SiteCode
    The MECM site code which the script should be run against.

    .PARAMETER ProviderMachineName
    The MECM endpoint that the script should be run against, typically a DP or another MECM server.

    .INPUTS
    Either the name of an existing MECM device collection or a list of computer names.

    .OUTPUTS
    A CSV report with the date run appended. "MECM_Report-$(Get-Date -Format FileDate).csv"

    .EXAMPLE
    Build-MECMComputerReport -CollectionName "Windows 10" -Path "C:\Temp" -SiteCode "ABC" -ProviderMachineName "mecm-server.abc.com"

    .NOTES

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,
        [Parameter(ParameterSetName="Collection")]
        [ValidateNotNullOrEmpty()]
        [String]
        $CollectionName,
        [Parameter(ParameterSetName="Array")]
        [String[]]
        $ComputerNames,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SiteCode,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ProviderMachineName
    )
    #Requires -Module ActiveDirectory

    # Site configuration
    # $SiteCode = "SSC" # Site code
    # $ProviderMachineName = "mendez.ads.ssc.wisc.edu" # SMS Provider machine name

    # Customizations
    $initParams = @{}
    #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
    #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

    # Do not change anything below this line

    # Import the ConfigurationManager.psd1 module
    if($null -eq (Get-Module ConfigurationManager)) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
    }

    # Connect to the site's drive if it is not already present
    if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    # Path that script was called from. Return after running commands against MECM site
    [String]$Start = $PWD;

    # Set the current location to be the site code.
    Set-Location "$($SiteCode):\" @initParams

    ########## End Site Configuration ###########
    Import-Module ActiveDirectory

    # Declare an Object[] to store results
    [Object[]]$script:ObjectArray = @();

    <# ComputerNames List #>
    # generate a report from a list of computer names rather than an existing colleciton in MECM.
    if ($null -ne $ComputerNames) {
        $ComputerNames | ForEach-Object{
            Get-CMDevice -Name $_ | ForEach-Object{
                [PSCustomObject]$Object = [PSCustomObject]@{
                    Name = $_.name
                    Vendor = $(Get-ADComputer $_.name -Properties sSCCHardwareVendor -ErrorAction SilentlyContinue).sSCCHardwareVendor
                    Model = $(Get-ADComputer $_.name -Properties sSCCHardwareModel -ErrorAction SilentlyContinue).sSCCHardwareModel
                    Serial = $(Get-ADComputer $_.name -Properties serialnumber -ErrorAction SilentlyContinue).serialnumber[0]
                    PrimaryUser = $_.PrimaryUser
                    CurrentUser = $_.currentlogonuser
                    LastUser = $_.lastlogonuser
                    FirstName = $(Get-ADUser $_.lastlogonuser -ErrorAction SilentlyContinue).givenname
                    LastName = $(Get-ADUSer $_.lastlogonuser -ErrorAction SilentlyContinue).surname
                    Email = $(Get-ADUser $_.lastlogonuser -Properties emailaddress -ErrorAction SilentlyContinue).emailaddress
                }
                $ObjectArray += $Object;
            }
        }

    }else{
        <# MECM Collection #>
            # Try to get the CMCollection by name, error handle if not found
        try {
            $script:collection = (Get-CMCollection -Name $CollectionName -CollectionType Device)
        }
        catch {
            Write-Error -Message $("Unable to resolve CM Collection {0}" -f $CollectionName) -ErrorAction Stop -Category ObjectNotFound
        }

        # Make sure that $collection is populated first
        if($null -ne $collection){
            # Get the devices in the collection, then mine data to create report
            Get-CMDevice -Collection $collection | ForEach-Object {
                [PSCustomObject]$Object = [PSCustomObject]@{
                    Name = $_.name
                    Vendor = $(Get-ADComputer $_.name -Properties sSCCHardwareVendor -ErrorAction SilentlyContinue).sSCCHardwareVendor
                    Model = $(Get-ADComputer $_.name -Properties sSCCHardwareModel -ErrorAction SilentlyContinue).sSCCHardwareModel
                    Serial = $(Get-ADComputer $_.name -Properties serialnumber -ErrorAction SilentlyContinue).serialnumber[0]
                    PrimaryUser = $_.PrimaryUser
                    CurrentUser = $_.currentlogonuser
                    LastUser = $_.lastlogonuser
                    FirstName = $(Get-ADUser $_.lastlogonuser -ErrorAction SilentlyContinue).givenname
                    LastName = $(Get-ADUSer $_.lastlogonuser -ErrorAction SilentlyContinue).surname
                    Email = $(Get-ADUser $_.lastlogonuser -Properties emailaddress -ErrorAction SilentlyContinue).emailaddress
                }
                $ObjectArray += $Object;
            }
        }else{
            Write-Error -Message "Unable to proceed. Null value passed to -Collection parameter." -Category InvalidArgument -ErrorAction Stop
        }
    }

    # Export the results of the report to a CSV file and also display to the console
    $ObjectArray | Export-Csv -NoTypeInformation -Path "$Path\MECM_Report-$(Get-Date -Format FileDate).csv"
    $ObjectArray | Format-Table -AutoSize

    # Return to the original starting directory
    Set-Location $Start
}