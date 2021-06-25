function Enable-Win10Feature {
    <#
    .SYNOPSIS
    Script to re-enable Windows 10 features that were removed due to / resulting from image capture issues.

    .DESCRIPTION
    Script searches for AppXManifest files in the WindowsApps directory of the system and attempts to register the manifest files for missing Windows 10 feature.

    .PARAMETER Calculator
    Switch parameter indicating that the script should try to re-register the calculator

    .PARAMETER StickyNotes
    Switch parameter indicating that the script should try to re-register sticky notes

    .EXAMPLE
    Enable-Win10Feature -Calculator

    .NOTES
    Paul Boyer 1-26-18

    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [Switch]
        $Calculator,
        [Switch]
        $StickyNotes
    )

    # if -Calculator was passed
    if ($Calculator){
        Get-ChildItem -Path "$env:ProgramFiles\WindowsApps\Microsoft.WindowsCalculator*" | ForEach-Object{
            if(Test-Path -Path "$_\AppxManifest.xml"){
                try {
                    Add-AppxPackage -Register "$_\AppxManifest.xml" -DisableDevelopmentMode -ErrorAction Continue
                }
                catch {
                    Write-Error $("Unable to register AppxPackage at {0}" -f $_)
                }
            }
        }
    }

    # if -StickyNotes was passed
    if ($StickyNotes) {
        Get-ChildItem -Path "$env:ProgramFiles\WindowsApps\Microsoft.MicrosoftStickyNotes*" | ForEach-Object{
            if(Test-Path -Path "$_\AppxManifest.xml"){
                try {
                    Add-AppxPackage -Register "$_\AppxManifest.xml" -DisableDevelopmentMode -ErrorAction Continue
                }
                catch {
                    Write-Error $("Unable to register AppxPackage at {0}" -f $_)
                }
            }
        }
    }
}