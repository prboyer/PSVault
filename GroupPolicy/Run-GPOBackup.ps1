function Run-GPOBackup {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if(-not (Test-Path $_)){
                New-Item -Type Directory -Path $(Split-Path $_ -Parent) -Name $(Split-Path $_ -Leaf)
            }
        })]
        [String]
        $BackupFolder,
        [Parameter()]
        [String]
        $Domain,
        [Parameter()]
        [Int]
        $BackupsToKeep
    )
    #Requires -Module ActiveDirectory
    
    # Import required module
    Import-Module $PSScriptRoot\External\GPFunctions.psm1

    ## CONSTANT Variables ##
        # Path to the location of Backup_GPOs.ps1
        [String]$global:BACKUP_GPOS = "$PSScriptRoot\External\BackUp_GPOs.ps1"

        # Path to the location of Get-GPLinks.ps1
        [String]$global:GET_GPLINKS = "$PSScriptRoot\Get-GPLinks.ps1"

        # Variable for today's date
        [String]$global:DATE = Get-Date -Format FileDateTimeUniversal

        # Information variable
        [String]$INFO

        # Number of backups to keep
        [Int]$KEEP = 10
        if ($BackupsToKeep -ne $null) {
            $KEEP = $BackupsToKeep
        }
    
    ##

    # Assign value to the $BackupDomain variable if none supplied at runtime
    [String]$global:BackupDomain;
    if($Domain -ne ""){
        $BackupDomain = $Domain;
    }else{
        $BackupDomain = $(Get-ADDomain).Forest
    }

    # Create a new temp folder to hold the backup files
    New-Item -Path $BackupFolder -Name "Temp" -ItemType Directory
    $Temp = Get-Item -Path "$BackupFolder\Temp"

    # Start GPO Backup Job (takes parameters in positional order only)
    Write-Information "Begin local background job: BackupJob - Executes BackUp_GPOS.ps1" -InformationVariable +INFO
    $BackupJob = Start-Job -Name "BackupJob" -FilePath $global:BACKUP_GPOS -ArgumentList $BackupDomain,$Temp 
  

    # Start GPO Links Job
    Write-Information "Begin local background job: LinksJob - Executes Get-GPLinks.ps1" -InformationVariable +INFO   
    $LinksJob = Start-Job -Name "LinksJob" -ArgumentList $Temp -ScriptBlock {
        # Import requried module
        . $using:GET_GPLINKS

        # Run the script
        Get-GPLinks -BothReport -Path "$args"
    } 

    # Wait for the backup jobs to finish, then zip up the files
    Wait-Job -Job $BackupJob,$LinksJob
    Compress-Archive -Path "$Temp\*" -DestinationPath "$BackupFolder\$DATE.zip"

    # Delete Temp folder
    Remove-Item -Path $Temp -Recurse -Force

    # Cleanup old Backups
    # Perform cleanup of older backups if the directory has more than 10 archives 
    if ((Get-ChildItem $backupFolder | Measure-Object).Count -gt 10) {
   
        # Delete backups older than the specified retention period, however keep a minimum of 5 recent backups.
        Get-ChildItem $backupFolder | Sort-Object -Property LastWriteTime -Descending | Select-Object -Skip 5 | Where-Object {$_.LastWriteTime -lt $((Get-Date).AddDays($KEEP))} | Remove-Item -Recurse -Force
    }

}
Run-GPOBackup -BackupFolder $PSScriptRoot\Backup