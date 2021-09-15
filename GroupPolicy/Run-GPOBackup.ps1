function Run-GPOBackup {
    <#
    .SYNOPSIS
    All-in-one GPO Backup Script. It leverages external modules/functions to create a robust backup of Group Policies in a domain.
    
    .DESCRIPTION
    The script runs BackUp_GPOs.ps1 and Get-GPLinks.ps1 externally to generate additional backup content. The script will backup all GPOs in the domain, as well as HTML
    reports for each GPO indicating what they do. Further, a CSV report is included. The GPO linkage to OUs is also included in both CSV and TXT reports. 
    The script also grabs a copy of the domain SYSVOL unless the -SkipSysvol parameter is supplied.
    The idea is that this backup is all-encompassing and would constitue a disaster recovery restore.
    
    .PARAMETER BackupFolder
    Path to where the backups should bs saved
    
    .PARAMETER Domain
    The domain against which backups are being run. If no value is supplied, the script will implicitly grab the domain from the machine it is running against.
    
    .PARAMETER BackupsToKeep
    Parameter that indicates how many previous backups to keep. Once the backup directory contains X backups, the oldest backups are then removed. By default, 10 backups are kept.
    
    .PARAMETER SkipSysvol
    Parameter that tells the script to forego backing up the domain SYSVOL elements (PolicyDefiniitions, StarterGPOs, and scripts)

    .PARAMETER NoZip
    Parameter that tells the script to forego zipping the results into an archive

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
        $SkipSysvol,
        [Parameter()]
        [switch]
        $NoZip
    )
    #Requires -Module ActiveDirectory
    
    # Import required module
    Import-Module $PSScriptRoot\External\GPFunctions.psm1

    ## CONSTANT Variables ##
        # Path to the location of Backup_GPOs.ps1
        [String]$global:BACKUP_GPOS = "$PSScriptRoot\External\BackUp_GPOs.ps1"

        # Path to the location of Get-GPLinks.ps1
        [String]$global:GET_GPLINKS = "$PSScriptRoot\Get-GPLinks.ps1"

        # Path to the location of the Get-GPOUnlinked.ps1 script
        [String]$global:GET_GPO_UNLINKED = "$PSScriptRoot\Get-GPOUnlinked.ps1"

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
    Write-Information "$DATE`n********************************`n" -InformationVariable +INFO

    # Assign value to the $BackupDomain variable if none supplied at runtime
    [String]$global:BackupDomain;
    if($Domain -ne ""){
        $BackupDomain = $Domain;
    }else{
        $BackupDomain = $(Get-ADDomain).Forest
    }

    # Create a new temp folder to hold the backup files
    Write-Information ("`n{0}`tCreate temporary folder at {1}" -f $LOGDATE,"$BackupFolder\Temp")
    New-Item -Path $BackupFolder -Name "Temp" -ItemType Directory | Out-Null
    $Temp = Get-Item -Path "$BackupFolder\Temp"

    # Make the temp folder hidden
    $Temp.Attributes = "Hidden"

    # Start GPO Backup Job (takes parameters in positional order only)
    Write-Information ("`n{0}`tBegin local background job: BackupJob - Executes BackUp_GPOS.ps1 `n`t`tBacking up GPOs to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO -InformationAction Continue
    $BackupJob = Start-Job -Name "BackupJob" -FilePath $global:BACKUP_GPOS -ArgumentList $BackupDomain,$Temp

    # Wait for the backup job to complete before proceeding
    Wait-Job -Job $BackupJob

    # Get BackupFolder within the Temp dir
    $SubTemp = (Get-ChildItem -Path $Temp -Filter "$((Get-Date).Year)_$((Get-Date -Format "MM"))_$((Get-Date -Format "dd"))_*").Name
    
    # Make the Manifest XML file visible
    Start-Sleep -Seconds 3

    if(Test-Path "$Temp\$SubTemp\manifest.xml"){
        $Manifest = (Get-ChildItem -Path "$Temp\$SubTemp" -File -Force -Filter "manifest*").FullName;
        $(Get-Item -Path $Manifest -Force).Attributes = "Normal";
    }

    # Analyze results
    [Int]$BackupJobResults = (Get-ChildItem -Path "$Temp\$SubTemp" -Filter "{*}" | Measure-Object).Count
    [Int]$GPOsInDomainResults = (Get-GPO -All | Measure-Object).Count

    Write-Information ("`n{0}`tResult: {1} Objects Backed Up. {2} Objects Found in the Domain." -f $LOGDATE, $BackupJobResults, $GPOsInDomainResults) -InformationAction Continue -InformationVariable +INFO

    # Determine what hasn't been backed up
    if ($BackupJobResults -lt $GPOSInDomainResults) {
        # Import the manifest file that correlates the GPO GUIDs and the GUIDs of the backup folders
        $BackupXML = Import-Clixml -Path "$Temp\$SubTemp\GPODetails.xml"

        # Now determine what is missing
        Write-Information ("`n{0]`tThe following policies have not been included in the backup.")
        Get-GPO -All | Select-Object DisplayName, ID | Where-Object{$_.ID -notin $($BackupXML |Select-Object GPOGUID).GPOGUID} | Format-Table -AutoSize -InformationVariable +INFO
    }

    # Start GPO Links Job
    Write-Information ("`n{0}`tBegin local background job: LinksJob - Executes Get-GPLinks.ps1 `n`t`tBacking up Links to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO -InformationAction Continue
    $LinksJob = Start-Job -Name "LinksJob" -ArgumentList $Temp -ScriptBlock {
        # Import required module
        . $using:GET_GPLINKS

        # Run the script
        Get-GPLinks -BothReport -Path "$args"
    }
    
    # Start GPO Unlinked Report Job
    Write-Information ("{0}`tBegin local background job: UnlinkedJob - Executes Get-GPOUnlinked.ps1 `n`t`tBacking up Unlinked Report to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO -InformationAction Continue
    $UnlinkedJob = Start-Job -Name "UnlinkedJob" -ArgumentList $Temp -ScriptBlock {
        # Import required module
        . $using:GET_GPO_UNLINKED

        # Run the Script
        Get-GPOUnlinked -FilePath "$args\UnlinkedReport.txt"
    }
    
    <# SysVol Backup #>
        # Only perform the Sysvol backup if the -SkipSysvol parameter is not supplied
        if(-not $SkipSysvol){
            # Begin the Sysvol backup
            Write-Information ("`n{0}`tBegin local background job: SysvolJob - Backs up a copy of important files in Sysvol `n`t`tBacking up Sysvol to {1}" -f $LOGDATE,$Temp) -InformationVariable +INFO -InformationAction Continue
            [String]$DomainController = $(Get-AdDomainController).hostname
            [String]$Sysvol = "\\$DomainController\Sysvol\$((Get-ADDomain | Select-Object Forest).Forest)"

                # Write out counts of objects in Sysvol dirs
                Write-Information ("`n{0}`tCount objects found in Sysvol:`n`t`tPolicyDefinitions = {1} items `n`t`tScripts = {2} items `n`t`tStarterGPOs = {3} items" -f $LOGDATE,(Get-ChildItem -Path "$Sysvol\Policies\PolicyDefinitions" -Recurse | Measure-Object).Count,(Get-ChildItem -Path "$Sysvol\scripts" -Recurse | Measure-Object).Count,(Get-ChildItem -Path "$Sysvol\StarterGPOs" -Recurse | Measure-Object).Count) -InformationAction Continue -InformationVariable +INFO

                # Start running the backup job
                $SysvolJob = Start-Job -Name "SysvolJob" -ArgumentList $Sysvol,$Temp -ScriptBlock {
                    try{
                        # Copy the contents from Sysvol (keeping the directory structure the same) to the backup folder
                        Copy-Item -Path "$($args[0])\Policies\PolicyDefinitions" -Recurse -Destination "$($args[1])\Sysvol\$((Get-ADDomain | Select-Object Forest).Forest)\Policies\PolicyDefinitions\"
                        Copy-Item -Path "$($args[0])\scripts" -Recurse -Destination "$($args[1])\Sysvol\$((Get-ADDomain | Select-Object Forest).Forest)\scripts\"
                        Copy-Item -Path "$($args[0])\StarterGPOs" -Recurse -Destination "$($args[1])\Sysvol\$((Get-ADDomain | Select-Object Forest).Forest)\StarterGPOs\"
                    }
                    catch{
                        Write-Error $Error[0] -ErrorVariable +INFO
                    }
                }
        }  else {
            # Write to the log file that Sysvol backup was not performed
            Write-Information ("`n{0}`tSkipping the Sysvol backup as the '-SkipSysvol' parameter was supplied at runtime." -f $DATE) -InformationVariable +INFO
        }

    # Wait for the backup jobs to finish, then zip up the files
    if($SkipSysvol){
        # If the -SkipSysvol parameter is supplied, don't wait for the SysvolJob before zipping (it won't be run)
        Wait-Job -Job $BackupJob,$LinksJob | Out-Null
    }else{
        Wait-Job -Job $SysvolJob,$LinksJob,$BackupJob | Out-Null
    }

    # If the -NoZip parameter is specified, then do not zip the results into an archive
    if ($NoZip) {
        # Make the folder visible
        $Temp.Attributes = "Normal";

        #Rename the Folder
        Rename-Item -Path $Temp -NewName $DATE -Force
       
    }else{
        Write-Information ("`n{0}`tBegin zipping files in {1} to archive at {2}" -f $LOGDATE,$Temp,"$BackupFolder\$DATE.zip") -InformationVariable +INFO
        Compress-Archive -Path "$Temp\*" -DestinationPath "$BackupFolder\$DATE.zip"

        # Delete Temp folder
        Write-Information ("`n{0}`tDelete Temp Folder ({1})" -f $LOGDATE,$Temp) -InformationVariable +INFO
        Remove-Item -Path $Temp -Recurse -Force
    }
    
    # Cleanup old Backups
    # Perform cleanup of older backups if the directory has more than 10 archives
    Write-Information ("`n{0}`tPerform cleanup of older backups if the directory has more than $KEEP archives" -f $LOGDATE) -InformationVariable +INFO
    if ((Get-ChildItem $backupFolder -Filter "*.zip"| Measure-Object).Count -gt $KEEP+1) {
   
        # Delete backups older than the specified retention period, however keep a minimum of 5 recent backups.
        Get-ChildItem $backupFolder -Filter "*.zip" | Sort-Object -Property LastWriteTime -Descending | Select-Object -Skip $KEEP | Remove-Item -Recurse -Force
    }

    # Write information to Log file
    $INFO | Out-File -FilePath $BackupFolder\Log.txt -Append

}


# SIG # Begin signature block
# MIIOgwYJKoZIhvcNAQcCoIIOdDCCDnACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfEdM4/VnmPbN963fIWmLZJ/G
# FgOgggvOMIIFvDCCA6SgAwIBAgITHgAAAAjRvX7DjspE9AAAAAAACDANBgkqhkiG
# 9w0BAQsFADB1MRMwEQYKCZImiZPyLGQBGRYDZWR1MRQwEgYKCZImiZPyLGQBGRYE
# d2lzYzETMBEGCgmSJomT8ixkARkWA3NzYzETMBEGCgmSJomT8ixkARkWA2FkczEe
# MBwGA1UEAxMVU1NDQ1Jvb3RDZXJ0QXV0aG9yaXR5MB4XDTE4MTIxMTIxMTY1NFoX
# DTIzMTIxMTIxMjY1NFowZzETMBEGCgmSJomT8ixkARkWA2VkdTEUMBIGCgmSJomT
# 8ixkARkWBHdpc2MxEzARBgoJkiaJk/IsZAEZFgNzc2MxEzARBgoJkiaJk/IsZAEZ
# FgNhZHMxEDAOBgNVBAMTB1NTQ0MgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQC4x+jiZP66RVCKJEhDddCX5HmBV7gdtyul5zAdugwPaqiOkXT+xWBY
# 8HeFTCvNftAvrrYAJfl18VrbS95A/sjXWsinX3CHoXCE0Qs3yBFy7UQurFVHsLkz
# Tdq/5pRHJAtOcx0uUCwoAYUhhkG+blpSkXw6JgOQNI2XWN8vzlDTbQ8JCr/Wj+ex
# 2MNJpXrd/cBSc76kUvEhW+gAJJBCiTUWSYK5Cxe9vsQPACfcCDAE5SmuOyRpTFj4
# Nw0A4VjPAskUfpnOIxcllZL+sdbeBAZ1cAu7EY5CyKrHKC+iqMYv012aT4WJf5Ok
# VzWHodI1bO43GtRVyCWdIBF5t7TQME99AgMBAAGjggFRMIIBTTAQBgkrBgEEAYI3
# FQEEAwIBATAjBgkrBgEEAYI3FQIEFgQU5JUeo22fvT6ZWUeQUv5tNUECXggwHQYD
# VR0OBBYEFJucPDsOj4fHFNBuavgyLcmy5aiOMBkGCSsGAQQBgjcUAgQMHgoAUwB1
# AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaA
# FHu0uMuXGTAdHazdkc+XVIuSke/TMEcGA1UdHwRAMD4wPKA6oDiGNmh0dHA6Ly9j
# ZXJ0LnNzYy53aXNjLmVkdS9DRFAvU1NDQ1Jvb3RDZXJ0QXV0aG9yaXR5LmNybDBS
# BggrBgEFBQcBAQRGMEQwQgYIKwYBBQUHMAKGNmh0dHA6Ly9jZXJ0LnNzYy53aXNj
# LmVkdS9jZHAvU1NDQ1Jvb3RDZXJ0QXV0aG9yaXR5LmNydDANBgkqhkiG9w0BAQsF
# AAOCAgEALqjbBWFxNMELQtvxQYHmP4yln038iQjX3o8jJxvmC/5cZwCg7jw8asdf
# lRqYR8ZGFqzGRv040ECHhicjjVKnSxcNRuQCKR+Yoz83nAQXovhU/mtP/+3PKv9N
# l/9rMAP6LZ8t49fo/BsiKMTFmVc88KCc8yuKi2ie94GherAP02b5U52A3JLRgfFW
# tXISWGY2uS6nBvxw1MWw9+5xfUH+EROdrNIXLce+ypEzHTR7C1g2QllFP65nf6cB
# WUV6Tng2eCraZl23ieZcf+OX1GMFx83LK5NGsaUsZvH7oQTq456USsah/6gNrS3C
# hE6Ir30sL93bpNtr7szrsvf2a9AnqgF80ExU3k+WROGeFor1nRw3yp1GPRXa5U9M
# Z9+wYD/dyNd48riUIOTAgcjTcaHAxJVsYeSj8Lcqxh7acJ6W2e5TYi7tgQ6unCNF
# pgIJ9er2eefd12w9OJIJDdbicJbXoe6QreLeIQMwust9qkBlxb2oiTvBJj7tfLnd
# 9x0EIr+oh+opRW96wJRsxYCs6iro0N7bSiVYbMaXGEOSkGJsaCXyDy6580RmskrF
# zXAdLADHSdVjCKJ/trH4ArYxXRU3gA4wqlc0Pr950+wypoJsE7l4bKHMaf6v+AGO
# 7GH1lo3fjpCgK/m7qnsrVl+ylvfH0QeuDkal8DDp3SC+DkNbZNYwggYKMIIE8qAD
# AgECAhMZAAAvgi/AXXfejLtDAAEAAC+CMA0GCSqGSIb3DQEBCwUAMGcxEzARBgoJ
# kiaJk/IsZAEZFgNlZHUxFDASBgoJkiaJk/IsZAEZFgR3aXNjMRMwEQYKCZImiZPy
# LGQBGRYDc3NjMRMwEQYKCZImiZPyLGQBGRYDYWRzMRAwDgYDVQQDEwdTU0NDIENB
# MB4XDTIwMDQxNDE3MTMyMVoXDTIyMDQxNDE3MTMyMVowFTETMBEGA1UEAxMKUGF1
# bCBCb3llcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANDaFi+f3bbp
# HoXchIz9lsOyFHdWjIwU25D38jaoNsLAvDxLRRhe/hJRAiplr7073atVUuyB3Jd4
# qckr24lfwuEN4mGtprgLhQaJY0L9cd7dxBwPQuwmw8PypNRPmJox1Zl9STvBlvYg
# OsXkWJU2N+/FyqFrPPkZ8dniWG0L9JqKXC3QrAPZLVm0KOBOCI09renm/N5oi0Bu
# dGUtsSUt+SY+0KA8KM0Y0cKRSUDcmJSeT/8tHQnd1urZ1I/yKD+F0GRXhl4J3Fay
# oNyFOGsxvulCkjqiscDgyB0o5gKGYM+LG+JXyKKWZRaSZl4DRoUGsMBZSzkmg1iO
# ckPph1v6N/0CAwEAAaOCAv8wggL7MD0GCSsGAQQBgjcVBwQwMC4GJisGAQQBgjcV
# CIXyvGaBt7Vqh9GbPoXpxRaC+Z5dLISosRqBpNpkAgFkAgEGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsG
# AQUFBwMDMB0GA1UdDgQWBBQuCyWOqOdAepuTFboIU+V9Kf2KdjAfBgNVHSMEGDAW
# gBSbnDw7Do+HxxTQbmr4Mi3JsuWojjCCAQAGA1UdHwSB+DCB9TCB8qCB76CB7IaB
# vWxkYXA6Ly8vQ049U1NDQyUyMENBLENOPVNTQ0NTdWJDYSxDTj1DRFAsQ049UHVi
# bGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlv
# bixEQz1hZHMsREM9c3NjLERDPXdpc2MsREM9ZWR1P2NlcnRpZmljYXRlUmV2b2Nh
# dGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludIYq
# aHR0cDovL2NlcnQuc3NjLndpc2MuZWR1L2NkcC9TU0NDJTIwQ0EuY3JsMIH+Bggr
# BgEFBQcBAQSB8TCB7jCBswYIKwYBBQUHMAKGgaZsZGFwOi8vL0NOPVNTQ0MlMjBD
# QSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMs
# Q049Q29uZmlndXJhdGlvbixEQz1hZHMsREM9c3NjLERDPXdpc2MsREM9ZWR1P2NB
# Q2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9y
# aXR5MDYGCCsGAQUFBzAChipodHRwOi8vY2VydC5zc2Mud2lzYy5lZHUvY2RwL1NT
# Q0MlMjBDQS5jcnQwMwYDVR0RBCwwKqAoBgorBgEEAYI3FAIDoBoMGHBib3llcjJA
# YWRzLnNzYy53aXNjLmVkdTANBgkqhkiG9w0BAQsFAAOCAQEANIfgfRwgh1VYrItf
# ibq0yf/2B/2qk/aMG10mDO7qxdkLIAnyUI4WQKOq0F0f/buvQvDIjBT26znagwCO
# n6JoO9j3orgDxDJ5K9SQ3DGPuhMz6t90gSt6pk2WF9V0ELSd+yrMmHHOMgrMmQ7j
# Do2mrTpAEA9Es3Z3c8gv8GjckHAo4JZqJ0rAtogKhIsD4AfP2HAJaRH3q80YJ3vq
# zoGbF6MvHLSgop+fePvxnSWiM/9qaq+xeK5sWqV3G4G7nX6932yju8q/nzr3uaVN
# PfZ/0ACfZPu9lXoPhZctK2lkiqVj25WBewX8+s/YAeD/Opz1tok5pQ98PsNmdCt+
# kv7CtzGCAh8wggIbAgEBMH4wZzETMBEGCgmSJomT8ixkARkWA2VkdTEUMBIGCgmS
# JomT8ixkARkWBHdpc2MxEzARBgoJkiaJk/IsZAEZFgNzc2MxEzARBgoJkiaJk/Is
# ZAEZFgNhZHMxEDAOBgNVBAMTB1NTQ0MgQ0ECExkAAC+CL8Bdd96Mu0MAAQAAL4Iw
# CQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# IwYJKoZIhvcNAQkEMRYEFN4K+rQ/37Ns022bMQ3wf7gMXLnQMA0GCSqGSIb3DQEB
# AQUABIIBACnQV9jwmSvvIBTqtlpdb8RrJvDnpxro2B5KJr7JOXcJoaa7ml3ecs+a
# h2tffiqqoUS0gi5VqLSVd1L9hVjhFT3iyawtbyn2jLUUQx1b7xbqnMWaJzOsQQwp
# gRtRh13eOIouG/LXiKn64+ruSOSGuPk/7v0qpIz/vZ6YqnOKhnQGJR/ehyvg6t+i
# ZZvJhgkrA+tTYxmaL4THDy2Bo3FVxbGrTI7Qp7qYiSX9eMZ3wXXoNC1DeDht8YQZ
# ss7Dn6iTo2jmas7dSZsR5vPmbm6p6KjcnLIpIF3hqp/vdzMrXaL1+V36qr9/AwgB
# 1cIUz7Sa4//kFpmMEcAxG4fhPD5y4tU=
# SIG # End signature block
