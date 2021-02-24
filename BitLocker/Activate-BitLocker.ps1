function Activate-BitLocker {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String[]]
        $ComputerNames,
        [System.Management.Automation.PSCredential]
        $Credential
    )

    # $session = New-PSSession -ComputerName $ComputerNames -Credential $Credential

    Invoke-Command -ComputerName $ComputerNames -AsJob -JobName "Activate BitLocker" -ScriptBlock {
        $OS_Disk = Get-Volume -DriveLetter $env:SystemDrive.Trim(":");
        $OS_Disk;
        Get-BitLockerVolume -MountPoint $OS_Disk.DriveLetter
    }

  Get-Job

    #Enable-BitLocker -MountPoint -TpmAndStartupKeyProtector
  
}
Activate-BitLocker -ComputerNames "tomahawk" -Credential $(Get-Credential)