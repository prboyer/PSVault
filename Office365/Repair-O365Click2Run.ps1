function Repair-O365Click2Run {
    <#
    .SYNOPSIS
    Script that calls the O365 ClickToRun executable with the appropriate parameters for a repair.
    
    .DESCRIPTION
    Long description
    
    .PARAMETER Path
    String path to the Click2Run executable if not stored in the default location
    
    .PARAMETER Force
    Switch parameter to force all O365 apps to close before running the repair process
    
    .PARAMETER Quiet
    Switch parameter to suppress the ClickToRun executable UI
    
    .PARAMETER OnlineRepair
    Switch parameter indicating that a more exhaustive Online Repair should be performed
    
    .LINK
    https://forums.ivanti.com/servlet/fileField?entityId=ka14O000000Xhh0&field=File_attachment__Body__s

    .LINK
    https://www.thewindowsclub.com/repair-microsoft-365-using-command-prompt

    .EXAMPLE
    Repair-O365Click2Run -Force -OnlineRepair
    
    .NOTES

    #>
    param (
        [Parameter()]
        [String]
        $Path,
        [Parameter()]
        [switch]
        $Force,
        [Parameter()]
        [switch]
        $Quiet,
        [Parameter()]
        [switch]
        $OnlineRepair
    )
    # Default path to ClickToRun executable
    [String]$C2R_EXE = "$env:ProgramFiles\Microsoft Office 15\ClientX64\OfficeClickToRun.exe"

    # Override default path if passed
    if ($Path -ne "") {
        $C2R_EXE = $Path;
    }
    
    # Processor architecture check
    [String]$ARCHITECTURE 
    if ([System.Environment]::Is64BitOperatingSystem) {
        $ARCHITECTURE = "x64";
    }else{
        $ARCHITECTURE = "x86";
    }

    # Determine Repair type. Default is a quick repair
    [String]$RepairType = "QuickRepair"

    # Do an online repair if the -OnlineRepair switch is supplied
    if($OnlineRepair){
        $RepairType = "FullRepair"
    }

    # Hide UI if -Quiet is passed. Default is to show
    [bool]$DisplayLevel = $true

    if($Quiet){
        $DisplayLevel = $false
    }

    # Variable to hold the argument list before passing to Start-Process
    [String]$ARGUMENT_LIST = "scenario=Repair system=$ARCHITECTURE culture=en-us RepairType=$RepairType DisplayLevel=$DisplayLevel "

    # Close all apps if the -Force parameter is supplied
    if ($Force) {
        $ARGUMENT_LIST = $ARGUMENT_LIST+"forceappshutdown=true"
    }

    # Start the repair process
    Start-Process -FilePath $C2R_EXE -Wait -Verb RunAs -ArgumentList $ARGUMENT_LIST

    Write-Host "O365 Repair Complete" -ForegroundColor Green
}