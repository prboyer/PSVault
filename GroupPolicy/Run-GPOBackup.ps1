function Run-GPOBackup {
    <#
    .SYNOPSIS
    All-in-one GPO Backup Script. It leverages external modules/functions to create a robust backup of Group Policies in a domain.
    
    .DESCRIPTION
    The script runs BackUp_GPOs.ps1 and Get-GPLinks.ps1 externally to generate additional backup content. The script will backup all GPOs in the domain, as well as HTML
    reports for each GPO indicating what they do. Further, a CSV report is included. The GPO linkage to OUs is also included in both CSV and TXT reports. The idea is that this backup is
    all-encompassing and would constitue a disaster recovery restore.
    
    .PARAMETER BackupFolder
    Path to where the backups should bs saved
    
    .PARAMETER Domain
    The domain against which backups are being run. If no value is supplied, the script will implicitly grab the domain from the machine it is running against.
    
    .PARAMETER BackupsToKeep
    Parameter that indicates how many previous backups to keep. Once the backup directory contains X backups, the oldest backups are then removed. By default, 10 backups are kept.
    
    .EXAMPLE
    Run-GPOBackup -BackupFolder C:\Backups -BackupsToKeep 10

    .OUTPUTS
    A .zip archive containing all necessary backup information to restore a GPO environment
    
    .NOTES
        Author: Paul Boyer
        Date: 5-5-21
    #>
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if(-not (Test-Path $_)){
                New-Item -Type Directory -Path $(Split-Path $_ -Parent) -Name $(Split-Path $_ -Leaf)
            }else{
                return $true
            }
        })]
        [String]
        $BackupFolder,
        [Parameter()]
        [String]
        $Domain,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
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
        
        # Variable for logging the timestamp
        [String]$LOGDATE = Get-Date -Format "G"

        # Information variable
        [String]$INFO

        # Number of backups to keep
        [Int]$KEEP = 10
        if ($BackupsToKeep -ne $null) {
            $KEEP = $BackupsToKeep
        }
    
    ##
    Write-Information $DATE -InformationVariable +INFO

    # Assign value to the $BackupDomain variable if none supplied at runtime
    [String]$global:BackupDomain;
    if($Domain -ne ""){
        $BackupDomain = $Domain;
    }else{
        $BackupDomain = $(Get-ADDomain).Forest
    }

    # Create a new temp folder to hold the backup files
    Write-Information ("{0}`tCreate temporary folder at {1}" -f $LOGDATE,"$BackupFolder\Temp")
    New-Item -Path $BackupFolder -Name "Temp" -ItemType Directory | Out-Null
    $Temp = Get-Item -Path "$BackupFolder\Temp"

    # Start GPO Backup Job (takes parameters in positional order only)
    Write-Information ("{0}`tBegin local background job: BackupJob - Executes BackUp_GPOS.ps1 `n`t`tBacking up GPOs to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO
    $BackupJob = Start-Job -Name "BackupJob" -FilePath $global:BACKUP_GPOS -ArgumentList $BackupDomain,$Temp 
  
    # Start GPO Links Job
    Write-Information ("{0}`tBegin local background job: LinksJob - Executes Get-GPLinks.ps1 `n`t`tBacking up Links to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO   
    $LinksJob = Start-Job -Name "LinksJob" -ArgumentList $Temp -ScriptBlock {
        # Import requried module
        . $using:GET_GPLINKS

        # Run the script
        Get-GPLinks -BothReport -Path "$args"
    } 

    # Wait for the backup jobs to finish, then zip up the files
    Wait-Job -Job $BackupJob,$LinksJob | Out-Null
    Write-Information ("{0}`tBegin zipping files in {1} to archive at {2}" -f $LOGDATE,$Temp,"$BackupFolder\$DATE.zip") -InformationVariable +INFO
    Compress-Archive -Path "$Temp\*" -DestinationPath "$BackupFolder\$DATE.zip"

    # Delete Temp folder
    Write-Information ("{0}`tDelete Temp Folder ({1})" -f $LOGDATE,$Temp) -InformationVariable +INFO
    Remove-Item -Path $Temp -Recurse -Force

    # Cleanup old Backups
    # Perform cleanup of older backups if the directory has more than 10 archives
    Write-Information ("{0}`tPerform cleanup of older backups if the directory has more than $KEEP archives" -f $LOGDATE) -InformationVariable +INFO
    if ((Get-ChildItem $backupFolder -Filter "*.zip"| Measure-Object).Count -gt $KEEP+1) {
   
        # Delete backups older than the specified retention period, however keep a minimum of 5 recent backups.
        Get-ChildItem $backupFolder -Filter "*.zip" | Sort-Object -Property LastWriteTime -Descending | Select-Object -Skip $KEEP | Remove-Item -Recurse -Force
    }

    # Write information to Log file
    $INFO | Out-File -FilePath $BackupFolder\Log.txt -Append

}