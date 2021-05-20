function Run-GPOBackup {
    <#
    .SYNOPSIS
    All-in-one GPO Backup Script. It leverages external modules/functions to create a robust backup of Group Policies in a domain.
    
    .DESCRIPTION
    The script runs BackUp_GPOs.ps1 and Get-GPLinks.ps1 externally to generate additional backup content. The script will backup all GPOs in the domain, as well as HTML
    reports for each GPO indicating what they do. Further, a CSV report is included. The GPO linkage to OUs is also included in both CSV and TXT reports. The idea is that this backup is
    all-encompassing and would constitue a disaster recovery restore. The script also grabs a copy of the domain SYSVOL unless the -SkipSysvol parameter is supplied.
    
    .PARAMETER BackupFolder
    Path to where the backups should bs saved
    
    .PARAMETER Domain
    The domain against which backups are being run. If no value is supplied, the script will implicitly grab the domain from the machine it is running against.
    
    .PARAMETER BackupsToKeep
    Parameter that indicates how many previous backups to keep. Once the backup directory contains X backups, the oldest backups are then removed. By default, 10 backups are kept.
    
    .PARAMETER SkipSysvol
    Parameter that tells the script to forego backing up the domain SYSVOL elements (PolicyDefiniitions, StarterGPOs, and scripts)

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
        $BackupsToKeep,
        [Parameter()]
        [switch]
        $SkipSysvol
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
        [String]$global:INFO

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

    # Make the temp folder hidden
    $Temp.Attributes = "Hidden"

    # Start GPO Backup Job (takes parameters in positional order only)
    Write-Information ("{0}`tBegin local background job: BackupJob - Executes BackUp_GPOS.ps1 `n`t`tBacking up GPOs to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO -InformationAction Continue
    $BackupJob = Start-Job -Name "BackupJob" -FilePath $global:BACKUP_GPOS -ArgumentList $BackupDomain,$Temp 
  
    # Start GPO Links Job
    Write-Information ("{0}`tBegin local background job: LinksJob - Executes Get-GPLinks.ps1 `n`t`tBacking up Links to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO -InformationAction Continue
    $LinksJob = Start-Job -Name "LinksJob" -ArgumentList $Temp -ScriptBlock {
        # Import required module
        . $using:GET_GPLINKS

        # Run the script
        Get-GPLinks -BothReport -Path "$args"
    }
    
    <# SysVol Backup #>
        # Only perform the Sysvol backup if the -SkipSysvol parameter is not supplied
        if(-not $SkipSysvol){
            # Begin the Sysvol backup
            Write-Information ("{0}`tBegin local background job: SysvolJob - Backs up a copy of important files in Sysvol `n`t`tBacking up Sysvol to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO -InformationAction Continue
            [String]$DomainController = $(Get-AdDomainController).hostname
            [String]$Sysvol = "\\$DomainController\Sysvol\$((Get-ADDomain | Select-Object Forest).Forest)"

                # Write out counts of objects in Sysvol dirs
                Write-Information ("{0}`tRecord counts of objects found in Sysvol:`n`t`tPolicyDefinitions = {1} items `n`t`tScripts = {2} items `n`t`tStarterGPOs = {3} items" -f $LOGDATE,(Get-ChildItem -Path "$Sysvol\Policies\PolicyDefinitions" -Recurse | Measure-Object).Count,(Get-ChildItem -Path "$Sysvol\scripts" -Recurse | Measure-Object).Count,(Get-ChildItem -Path "$Sysvol\StarterGPOs" -Recurse | Measure-Object).Count) -InformationAction Continue -InformationVariable +INFO

                # Start running the backup job
                $SysvolJob = Start-Job -Name "SysvolJob" -ArgumentList $Sysvol,$Temp -ScriptBlock {
                    try{
                        # Copy the contents from Sysvol (keeping the directory structure the same) to the backup folder
                        Copy-Item -Path "$($args[0])\Policies\PolicyDefinitions" -Recurse -Destination "$($args[1])\Sysvol\$((Get-ADDomain | Select-Object Forest).Forest)\Policies"
                        Copy-Item -Path "$($args[0])\scripts" -Recurse -Destination "$($args[1])\Sysvol\$((Get-ADDomain | Select-Object Forest).Forest)\scripts\"
                        Copy-Item -Path "$($args[0])\StarterGPOs" -Recurse -Destination "$($args[1])\Sysvol\$((Get-ADDomain | Select-Object Forest).Forest)\StarterGPOs\"
                    }
                    catch{
                        Write-Error $Error[0] -ErrorVariable +INFO
                    }
                }
        }  else {
            # Write to the log file that Sysvol backup was not performed
            Write-Information ("{0}`tSkipping the Sysvol backup as the '-SkipSysvol' parameter was supplied at runtime." -f $DATE) -InformationVariable +INFO
        }

    # Wait for the backup jobs to finish, then zip up the files
    if($SkipSysvol){
        # If the -SkipSysvol parameter is supplied, don't wait for the SysvolJob before zipping (it won't be run)
        Wait-Job -Job $BackupJob,$LinksJob | Out-Null
    }else{
        Wait-Job -Job $SysvolJob,$LinksJob,$BackupJob | Out-Null
    }
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