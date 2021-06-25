function Enable-AppsPanel {
<#
.SYNOPSIS
Quickly resolve the Adobe Creative Cloud Desktop app displaying a "You don't have access to manage apps" message

.DESCRIPTION
Script automates the process of updating the configuration XML file or DB file (version dependent) to resolve the apps list issue. This is accomplished
    with some simple string manipulation and content get/set methods (or forced regeneration of the database file).

.PARAMETER Disable
Parameter that is used to modify behavior of the XML file manipulaiton. When specified, the parameter will cause the script to disable the apps panel rather
than enable it.

.PARAMETER NoRevert
Changes the behavior of the DB file manipulation. Rather than appending a ".old" to the DB file in %LOCALAPPDATA%, the switch will cause the old DB file to be removed.

.EXAMPLE
Enable-AppsPanel -Disable

.EXAMPLE
Enable-AppsPanel -NoRevert

.LINK
https://helpx.adobe.com/uk/creative-cloud/kb/apps-panel-reflect-creative-cloud.html

.LINK
https://kb.wisc.edu/page.php?id=99743

.NOTES
Script written by Paul B 10-16-2020
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [Switch]
        $Disable,
        [Parameter()]
        [Switch]
        $NoRevert
    )

    # Check the version of CC installed.
    [double]$AdobeVersion = $((Get-Package -IncludeWindowsInstaller -Name "Adobe Creative Cloud").Version[0,1,2]) -join ""

    # If the version installed is <= 4.9 then proceed with modifying the XML config file.
    if ($AdobeVersion -le 4.9) {

        # Path to the Adobe CC launch pad / apps panel config file
        [String]$ADOBECC_CONFIG = "${env:CommonProgramFiles(x86)}\Adobe\OOBE\Configs\ServiceConfig.xml"

        #Test the path to confirm the XML file exists in the path provided
        if(Test-Path -Path $ADOBECC_CONFIG){

            # String constants for either enabling or disabling access to the apps panel.
            [String]$DISABLE = "<visible>false</visible>"
            [String]$ENABLE = "<visible>true</visible>"

            # Variable strings declared
            [String]$target;
            [String]$source;

            # If the -Disable parameter is supplied, reverse the behavior of the script and disable access to the apps panel
            if($Disable){
                $target = $ENABLE;
                $source = $DISABLE;
            }else{
                $target = $DISABLE;
                $source = $ENABLE;
            }

            # Read in the contents of the XML file, then replace 'target' with 'source' and write the file back out
            $content = Get-Content $ADOBECC_CONFIG -ErrorAction SilentlyContinue
            $content = $content -replace $target, $source
            Set-Content -Value $content -Path $ADOBECC_CONFIG

            # Error handling for if the path to the config file is not viable.
        }else{
                Write-Error -Message "Unable to locate the AdobeCC config file at the path provided." -ErrorAction Stop
                break;
        }
    }
    # If the version installed is newer than 4.9, the reset the apps panel by forcing generation of a new DB file.
    else{
        # Path to Adobe CC DB file on newer installations.
        [String]$ADOBECC_DB = "$env:LOCALAPPDATA\Adobe\OOBE\opm.db"

        # Close any running instances of Creative Cloud
        Get-Process -Name "*creative cloud*" -ErrorAction SilentlyContinue | ForEach-Object{Stop-Process -Id $_.ID -Force -ErrorAction SilentlyContinue}

        # Test path to DB file. If present, then rename (or delete) it.
        if (Test-Path -Path $ADOBECC_DB ) {
            if ($NoRevert) {
                Remove-Item -Path $ADOBECC_DB -Force
            }else{
                # Append ".old" to the DB file.
                Rename-Item -Path $ADOBECC_DB -NewName $(Get-Item -Path $ADOBECC_DB).Name.Insert($(Get-Item -Path $ADOBECC_DB).Name.Length,".old")
            }
        }
        # Error handling for if the path to the database file is not viable.
        else{
            Write-Error -Message "Unable to locate the AdobeCC database file at the path provided." -ErrorAction Stop
            break;
        }
    }
}