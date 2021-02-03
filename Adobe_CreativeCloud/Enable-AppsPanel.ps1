function Enable-AppsPanel {
    <#
    .SYNOPSIS
    Quickly resolve the Adobe Creative Cloud Desktop app displaying a "You don't have access to manage apps" message

    .DESCRIPTION
    Script automates the process of updating the configuration XML file to resolve the apps list issue. This is accomplished
    with some simple string manipulation and content get/set methods. 

    .EXAMPLE
    An example

    .LINK
    https://kb.wisc.edu/page.php?id=99743

    .NOTES
    Script written by Paul B 10-16-2020
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [Switch]
        $Disable
    )

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

Enable-AppsPanel
