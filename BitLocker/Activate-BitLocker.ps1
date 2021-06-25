function Activate-BitLocker {
    <#
    .SYNOPSIS
    Script for manually activating BitLocker on Windows 10 machines

    .DESCRIPTION
    Runs the BitLocker PowerShell cmdlet on each machine in the -ComptuerNames string array as a remote job.

    .PARAMETER ComputerNames
    String array of computer names for which BitLocker needs to be enabled

    .PARAMETER Credential
    A PSCredential object for authenticating remote sessions

    .PARAMETER LogFile
    Path to write out the log file.

    .EXAMPLE
    Activate-BitLocker -ComputerNames "desktop01","desktop02" -LogFile "\\winfs1\share1\log.txt"

    .LINK
    https://docs.microsoft.com/en-us/powershell/module/bitlocker/enable-bitlocker?view=win10-ps

    .LINK
    https://docs.microsoft.com/en-us/powershell/module/bitlocker/enable-bitlocker?view=win10-ps

    .LINK
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_remote_jobs?view=powershell-7.1

    .NOTES
    Paul Boyer - 2-24-21
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String[]]
        $ComputerNames,
        [System.Management.Automation.PSCredential]
        $Credential,
        [String]
        $LogFile
    )
    # perform the operations for each computer in the array
    foreach($computer in $ComputerNames){
        # create a new remote session to the computer
        if($Credential -ne $null){
            $session = New-PSSession -ComputerName $computer -Credential $Credential
        }else{
            $session = New-PSSession -ComputerName $computer
        }


        # invoke commands against the computer in the remote session
        $command = Invoke-Command -Session $session -AsJob -JobName "Activate BitLocker" -ScriptBlock {
            Write-Host $env:COMPUTERNAME -ForegroundColor Yellow -BackgroundColor Black

            # get disk information
            $OS_Disk = Get-Volume -DriveLetter $env:SystemDrive.Trim(":");
            $OS_Disk | Format-Table;

            # get the current BitLocker state
            $status = Get-BitLockerVolume -MountPoint $OS_Disk.DriveLetter
            $status | Select-Object ComputerName,MountPoint,VolumeType,EncryptionMethod,VolumeStatus,ProetctionStatus,LockStatus,KeyProtector | Format-Table

            # if the current BitLocker state if off, then turn it on and start the encryption
            if($status.ProtectionStatus -eq "Off"){
                Get-BitLockerVolume -MountPoint $OS_Disk.DriveLetter | Enable-BitLocker -RecoveryPasswordProtector -EncryptionMethod XtsAes128 -UsedSpaceOnly
                Get-BitLockerVolume -MountPoint $OS_Disk.DriveLetter | Enable-BitLocker -TpmProtector

                # not implementing as it is un-necessary for OS drives
                # Get-BitLockerVolume -MountPoint $OS_Disk.DriveLetter | Enable-BitLockerAutoUnlock
            }
        }
    }

    # show the status of the jobs while they are running
    do{
        Start-Sleep -Seconds 3
        Get-Job -State "Running"
    }
    while((Get-Job -State "Running" | Where-Object{$_.PSJobTypeName -eq "RemoteJob"} | Measure-Object).Count -gt 0)

    Write-Host "Remote Jobs have finished processing" -ForegroundColor Cyan

    Write-Host "Note: Machines need to be rebooted before encryption will begin" -ForegroundColor Yellow -BackgroundColor Black

    # display the results of the job & write to log file
    Get-Job | ForEach-Object{
        $_.Location | Out-File -FilePath $LogFile -Append;
        "Enable BitLocker on "+$_.Location | Out-File $LogFile -Append
        Receive-Job -Job $_ | Tee-Object -FilePath $LogFile -Append
    }

}