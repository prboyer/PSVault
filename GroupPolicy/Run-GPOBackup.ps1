function Run-GPOBackup {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $BackupFolder,
        [Parameter()]
        [String]
        $Domain
    )
    #Requires -Module ActiveDirectory

    ####
    # CONSTANT Variables
        # Path to the location of Backup_GPOs.ps1
        [String]$global:BACKUP_GPOS = "$PSScriptRoot\External\BackUp_GPOs.ps1"

        # Path to the location of Get-GPLinks.ps1
        [String]$global:GET_GPLINKS = "$PSScriptRoot\Get-GPLinks.ps1"

        # Variable for today's date
        [String]$global:DATE = Get-Date -Format FileDateTimeUniversal
    
    #####
    # Other Variables 

    #####
    # Assign value to the $BackupDomain variable if none supplied at runtime
    [String]$global:BackupDomain;
    if($Domain -ne ""){
        $BackupDomain = $Domain;
    }else{
        $BackupDomain = $(Get-ADDomain).Forest
    }

    # Declare GPO Backup Job (takes parameters in positional order only)
    Start-Job -FilePath $BACKUP_GPOS -ArgumentList $BackupDomain,$BackupFolder












    while((Get-Job -State Running | Measure-Object).Count -gt 0){
        Get-Job
        Start-Sleep 2
    }



    # Run the GPO Backup Script
    # Start-Process "powershell.exe" -Wait -NoNewWindow -ArgumentList "-NoProfile -File `"$BACKUP_GPOS`" -Domain $BackupDomain -BackupFolder `"$BackupFolder`""

    # Rename the GPO Backup content folder
    # [System.IO.DirectoryInfo]$currentBackup = (Get-ChildItem $BackupFolder | Sort-Object -Descending -Property LastWriteTime)[0]
    # $currentBackup | Rename-Item -NewName $($DATE+"_GPOBackup") -Force -PassThru


}
Run-GPOBackup -BackupFolder $PSScriptRoot\backup 