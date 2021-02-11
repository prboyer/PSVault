# that was removed due to image capture issues with provisioned apps
function Enable-Win10Calculator {
    <#
    .SYNOPSIS
    Script to re-enable Windows 10 Calculator.
    
    .DESCRIPTION
    Script searches for AppXManifest files in the WindowsApps directory of the system and attempts to register the manifest files for Windows 10 Calculator.
    
    .EXAMPLE
    Enable-Win10Calculator
    
    .NOTES
    Paul Boyer 1-26-18
    #>
  
    Get-ChildItem -Path "$env:ProgramFiles\WindowsApps\Microsoft.WindowsCalculator*" | %{
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