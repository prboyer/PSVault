function Repair-Windows10 {
    <#
    .SYNOPSIS
    Script of repair tools and their appropriate parameters for diagnosing Windows 10 issues

    .DESCRIPTION
    Long description

    .PARAMETER DISM
    Switch to tell the script to run DISM

    .PARAMETER Check
    When used with -DISM, it will use DISM.exe to check the health of the image.
    When used with -Defrag it will check the status of the system drive

    .PARAMETER Source
    File path to a Windows installation directory for system repair. This is not a path to the online system's Windows directory.

    .PARAMETER NoWU
    Switch when used with -DISM that will prevent downloading repair files from Windows Update

    .PARAMETER SFC
    Switch to run System File Check

    .PARAMETER CleanUp
    Switch to run the system disk cleanup tool

    .PARAMETER Silent
    Switch to run the system disk cleanup tool silently

    .PARAMETER Defrag
    Switch to defragment/optimize drives

    .EXAMPLE
    Repair-Windows10 -DISM -SFC

    .LINK
    https://support.microsoft.com/en-us/topic/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files-79aa86cb-ca52-166a-92a3-966e85d4094e

    .LINK
    https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-8.1-and-8/hh824869(v=win.10)?redirectedfrom=MSDN

    .LINK
    https://www.nextofwindows.com/running-disk-cleanup-tool-in-command-line-in-windows-10

    .LINK
    https://www.geeksinphoenix.com/blog/post/2015/07/19/how-to-defragment-and-optimize-your-drive-in-windows-10.aspx

    .NOTES
    General notes
    #>
    param (
        [Parameter(ParameterSetName='dism')]
        [Switch]
        $DISM,
        [Parameter(ParameterSetName='dism')]
        [Parameter(ParameterSetName='defrag')]
        [Switch]
        $Check,
        [Parameter(ParameterSetName='dism')]
        [string]
        $Source,
        [Parameter(ParameterSetName='dism')]
        [switch]
        $NoWU,
        [Parameter(ParameterSetName='sfc')]
        [switch]
        $SFC,
        [Parameter(ParameterSetName='clean')]
        [switch]
        $CleanUp,
        [Parameter(ParameterSetName='clean')]
        [switch]
        $Silent,
        [Parameter(ParameterSetName='defrag')]
        [switch]
        $Defrag


    )
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "This script should be run in an Administrative session"

    # DISM Repair
    if ($DISM) {
        Write-Host "DISM Repair"
        # Run a DISM check
        if ($Check) {
            Start-Process -FilePath dism.exe -ArgumentList "/Online /Cleanup-Image /ScanHealth" -Wait -NoNewWindow
            Start-Process -FilePath dism.exe -ArgumentList "/Online /Cleanup-Image /CheckHealth" -Wait -NoNewWindow
        }else {
            # Run DISM repair
            if($Source -ne ""){
                # Run DISM repair with access to a Windows installation directory and supplement with WU
                Start-Process -FilePath dism.exe -ArgumentList "/Online /Cleanup-Image /RestoreHealth /Source:$Source" -Wait -NoNewWindow
            }elseif ($Source -ne "" -and $NoWU) {
                # Run DISM repair with access to a Windows installation directory and do not allow downloads from WU
                Start-Process -FilePath dism.exe -ArgumentList "/Online /Cleanup-Image /RestoreHealth /Source:$Source /LimitAccess" -Wait -NoNewWindow
            }else{
                # Run DISM repair by downloading necessary files from Windows Update
                Start-Process -FilePath dism.exe -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -NoNewWindow
            }
        }
        Write-Host "Complete" -ForegroundColor Green
    }

    # Run SFC
    if ($SFC) {
        Write-Host "Run System File Check"
        Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -NoNewWindow -Wait
        Write-Host "Complete" -ForegroundColor Green
    }

    # Run the system disk cleanup tool
    if ($CleanUp) {
        Write-Host $("Run Disk Cleanup on System Drive - {0}" -f $env:SystemDrive)
        if($Silent){
            Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d $env:SystemDrive /verylowdisk"
        }else{
            Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d $env:SystemDrive /lowdisk"
        }
    }

    # Run the drive defragmentation tool
    if($Defrag){
        if ($Check) {
            Start-Process -FilePath "defrag.exe" -ArgumentList "$env:SystemDrive /A /U /V"
        }else{
            Start-Process -FilePath "defrag.exe" -ArgumentList "$env:SystemDrive /O /U /V"
        }
    }


}