# Customizations


##########################################################################################################
# https://devblogs.microsoft.com/scripting/using-powershell-to-back-up-group-policy-objects/
# https://gallery.technet.microsoft.com/scriptcenter/Comprehensive-Group-Policy-5f9d3ea6

<#
.SYNOPSIS
    Backs up GPOs from a specified domain and includes additional GPO information.

.DESCRIPTION
    The script backs up GPOs in a target domain and captures additional GPO management information, such
    as Scope of Management, Block Inheritance, Link Enabled, Link Order, Link Enforced and WMI Filters.

    The backup can then be used by a partner script to mirror GPOs in a test domain.

    Details:
    * Creates a XML file containing PSCustomObjects used by partner import script
    * Creates a XML file WMI filter details used by partner import script
    * Creates a CSV file of additional information for readability
    * Creates a folder containing HTML reports of settings for each GPO
    * Additional backup information includes SOM (Scope of Management) Path, Block Inheritance, Link Enabled,
      Link Order', Link Enforced and WMI Filter data
    * Each CSV SOM entry is made up of "DistinguishedName:BlockInheritance:LinkEnabled:LinkOrder:LinkEnforced"
    * Option to create a Migration Table (to then be manually updated)

    Requirements: 
    * PowerShell GroupPolicy Module
    * PowerShell ActiveDirectory Module
    * Group Policy Management Console

.EXAMPLE
   .\BackUp_GPOs.ps1 -Domain wintiptoys.com -BackupFolder "\\wingdc01\backups\"

   This will backup all GPOs in the domain wingtiptoys.com and store them in a date and time stamped folder 
   under \\wingdc01\backups\.

.EXAMPLE
   .\BackUp_GPOs.ps1 -Domain contoso.com -BackupFolder "c:\backups" -MigTable

   This will backup all GPOs in the domain contoso.com and store them in a date and time stamped folder 
   under c:\backups\. A migration table, MigrationTable.migtable, will also be created for manual editing.

.EXAMPLE
   .\BackUp_GPOs.ps1 -Domain contoso.com -BackupFolder "c:\backups" -ModifiedDays 15

   This will backup all GPOs in the domain contoso.com that have been modified within the last 15 days. 
   The script will store the backed up GPOs in a date and time stamped folder under c:\backups\

.EXAMPLE
   .\BackUp_GPOs.ps1 -Domain adatum.com -BackupFolder "c:\backups" -GpoGuid "b1e0e5ea-0d6b-48f1-a56c-0a98d8acd17b"

   This will backup the GPO identified by the following GUID - "b1e0e5ea-0d6b-48f1-a56c-0a98d8acd17b" - from the 
   domain adatum.com

   The backed up GPO will be stored in a date and time stamped folder under c:\backups\

.OUTPUTS
   * Backup folder name in the format Year_Month_Day_HourMinuteSecond
   * Per-GPO HTML settings report in the format <backup-guid>__<gpo-guid>__<gpo-name>.html
   * GpoDetails.xml
   * Wmifilters.xml
   * GpoInformation.csv
   * MigrationTable.migtable (optional)

   EXIT CODES: 1 - GPMC not found

.NOTES
    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
    FITNESS FOR A PARTICULAR PURPOSE.

    This sample is not supported under any Microsoft standard support program or service. 
    The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
    implied warranties including, without limitation, any implied warranties of merchantability
    or of fitness for a particular purpose. The entire risk arising out of the use or performance
    of the sample and documentation remains with you. In no event shall Microsoft, its authors,
    or anyone else involved in the creation, production, or delivery of the script be liable for 
    any damages whatsoever (including, without limitation, damages for loss of business profits, 
    business interruption, loss of business information, or other pecuniary loss) arising out of 
    the use of or inability to use the sample or documentation, even if Microsoft has been advised 
    of the possibility of such damages, rising out of the use of or inability to use the sample script, 
    even if Microsoft has been advised of the possibility of such damages. 

#>
##########################################################################################################

#################################
## Script Options and Parameters
#################################

#Requires -version 3
#Requires -modules ActiveDirectory,GroupPolicy

#Version: 2.4
<#   
     - 2.1 - 19/08/2014 
     * the script now processes gPLink info on site objects
     * thanks to Mark Renoden [MSFT]

     - 2.2 - 08/07/2015 
     * updates to allow backup from one trusted forest to another

     - 2.3 - 12/01/2016 
     * added ability to backup GPOs modified within the last X days
     * added ability to create html report of settings per GPO
     * thanks to Marcus Carvalho [MSFT]

     - 2.4 - 15/01/2016 
     * added ability to backup a single GPO
     * added parameter sets to prevent -GpoGuid and -ModifiedDate being used together
#>

#Define and validate parameters
[CmdletBinding(DefaultParameterSetName="All")]
Param(
      #The target domain
      [parameter(Mandatory=$True,Position=1)]
      [ValidateScript({Get-ADDomain $_})] 
      [String]$Domain,

      #The backup folder
      [parameter(Mandatory=$True,Position=2)]
      [ValidateScript({Test-Path $_})]
      [String]$BackupFolder,

      #Backup GPOs modified within the last X days
      [parameter(ParameterSetName="Modified",Mandatory=$False,Position=3)]
      [ValidateSet(15,30,45,60,90)]
      [Int]$ModifiedDays,

      #Backup a single GPO
      [parameter(ParameterSetName="Guid",Mandatory=$False,Position=3)]
      [ValidateScript({Get-GPO -Guid $_})] 
      [String]$GpoGuid,

      #Whether to create a migration table
      [Switch]$MigTable
    )


#Set strict mode to identify typographical errors (uncomment whilst editing script)
#Set-StrictMode -version Latest


##########################################################################################################

########
## Main
########


########################
##BACKUP FOLDER DETAILS
#Create a variable to represent a new backup folder
#(constructing the report name from date details and the supplied backup folder)
$Date = Get-Date
$ShortDate = Get-Date -format d

$SubBackupFolder = "$BackupFolder\" + `
                   "$($Date.Year)_" + `
                   "$("{0:D2}" -f $Date.Month)_" + `
                   "$("{0:D2}" -f $Date.Day)_" + `
                   "$("{0:D2}" -f $Date.Hour)" + `
                   "$("{0:D2}" -f $Date.Minute)" + `
                   "$("{0:D2}" -f $Date.Second)"


##################
##BACKUP ALL GPOs
#Create the backup folder
New-Item -ItemType Directory -Path $SubBackupFolder | Out-Null

#Create the settings report folder
$HtmlReports = "HTML_Reports"
New-Item -ItemType Directory -Path "$SubBackupFolder\$HtmlReports" | Out-Null


#Make sure the backup folders have been created
if ((Test-Path -Path $SubBackupFolder) -and (Test-Path -Path "$SubBackupFolder\$HtmlReports")) {

    #Connect to the supplied domain
    $TargetDomain = Get-ADDomain -Identity $Domain
    

    #Obtain the domain FQDN
    $DomainFQDN = $TargetDomain.DNSRoot


    #Obtain the domain DN
    $DomainDN = $TargetDomain.DistinguishedName


    #Connect to the forest root domain
    $TargetForestRootDomain = (Get-ADForest -Server $DomainFQDN).RootDomain | Get-ADDomain
    

    #Obtain the forest FQDN
    $ForestFQDN = $TargetForestRootDomain.DNSRoot


    #Obtain the forest DN
    $ForestDN = $TargetForestRootDomain.DistinguishedName    

	
    #Create an empty array for our backups
	$Backups = @()

        #Determine the type of backup to be performed
	    if ($ModifiedDays) {

            #Get a list of
		    $ModGpos = Get-GPO -Domain $DomainFQDN -All | Where-Object {$_.ModificationTime -gt $Date.AddDays(-$ModifiedDays)}
            
            #Loop through each recently changed GPO and back it up, adding the resultant object to the $Backups array
            foreach ($ModGpo in $ModGpos) {

			    $Backups += Backup-GPO $ModGpo.DisplayName -Path $SubBackupFolder -Comment "Scripted backup created by $env:userdomain\$env:username on $ShortDate"
		    

            }   #end of foreach ($ModGpo in $ModGpos)

	    }   #end of if ($ModifiedDays)
        elseif ($GpoGuid) {

            #Backup single GPO
             $Backups = Backup-GPO -Guid $GpoGuid -Path $SubBackupFolder -Domain $DomainFQDN -Comment "Scripted backup created by $env:userdomain\$env:username on $ShortDate"

        }   #end of elseif ($GpoGuid)
	    else {
		    
		    #Backup all GPOs found in the domain
            $Backups = Backup-GPO -All -Path $SubBackupFolder -Domain $DomainFQDN -Comment "Scripted backup created by $env:userdomain\$env:username on $ShortDate"

		    
	    }   #end of else ($ModifiedDays)

	
        #Instantiate an object for Group Policy Management (GPMC required)
        try {

            $GPM = New-Object -ComObject GPMgmt.GPM
    
        }   #end of Try...
    
        catch {

            #Display exit message to console
            $Message = "ERROR: Unable to connect to GPMC. Please check that it is installed."
            Write-Host
            Write-Error $Message
  
            #Exit the script
            exit 1
    
        }   #end of Catch...


    #Import the GPM API constants
    $Constants = $GPM.getConstants()


    #Connect to the supplied domain
    $GpmDomain = $GPM.GetDomain($DomainFQDN,$Null,$Constants.UseAnyDc)

    
    #Connect to the sites container
    $GpmSites = $GPM.GetSitesContainer($ForestFQDN,$DomainFQDN,$Null,$Constants.UseAnyDc)
    

    ###################################
    ##COLLECT SPECIFIC GPO INFORMATION
    #Loop through each backed-up GPO
    foreach ($Backup in $Backups) {

        #Get the GPO GUID for our target GPO
        $GpoGuid = $Backup.GpoId


        #Get the backup GUID for our target GPO
        $BackupGuid = $Backup.Id
        

        #Instantiate an object for the relevant GPO using GPM
        $GPO = $GpmDomain.GetGPO("{$GpoGuid}")


        #Get the GPO DisplayName property
        $GpoName = $GPO.DisplayName

        #Get the GPO ID property
        $GpoID = $GPO.ID
	
            
		##Retrieve SOM Information
		#Create a GPM search criteria object
		$GpmSearchCriteria = $GPM.CreateSearchCriteria()


		#Configure search critera for SOM links against a GPO
		$GpmSearchCriteria.Add($Constants.SearchPropertySOMLinks,$Constants.SearchOpContains,$GPO)


		#Perform the search
		$SOMs = $GpmDomain.SearchSOMs($GpmSearchCriteria) + $GpmSites.SearchSites($GpmSearchCriteria)


		#Empty the SomPath variable
		$SomInfo = $Null

		
		#Loop through any SOMs returned and write them to a variable
		foreach ($SOM in $SOMs) {

			#Capture the SOM Distinguished Name
			$SomDN = $SOM.Path

		
			#Capture Block Inheritance state
			$SomInheritance = $SOM.GPOInheritanceBlocked

		
			#Get GPO Link information for the SOM
			$GpoLinks = $SOM.GetGPOLinks()


				#Loop through the GPO Link information and match info that relates to our current GPO
				foreach ($GpoLink in $GpoLinks) {
				
					if ($GpoLink.GPOID -eq $GpoID) {

						#Capture the GPO link status
						$LinkEnabled = $GpoLink.Enabled


						#Capture the GPO precedence order
						$LinkOrder = $GpoLink.SOMLinkOrder


						#Capture Enforced state
						$LinkEnforced = $GpoLink.Enforced


					}   #end of if ($GpoLink.GPOID -eq $GpoID)


				}   #end of foreach ($GpoLink in $GpoLinks)


			#Append the SOM DN, link status, link order and Block Inheritance info to $SomInfo
			[Array]$SomInfo += "$SomDN`:$SomInheritance`:$LinkEnabled`:$LinkOrder`:$LinkEnforced"
	
	
		}   #end of foreach ($SOM in $SOMs)...


        ##Obtain WMI Filter path using Get-GPO
        $Wmifilter = (Get-GPO -Guid $GpoGuid -Domain $DomainFQDN).WMifilter.Path
        
        #Split the value down and use the ID portion of the array
        #$WMifilter = ($Wmifilter -split "`"")[1]
        $WMifilter = ($Wmifilter -split '"')[1]



        #Add selected GPO properties to a custom GPO object
        $GpoInfo = [PSCustomObject]@{

                BackupGuid = $BackupGuid
                Name = $GpoName
                GpoGuid = $GpoGuid
                SOMs = $SomInfo
                DomainDN = $DomainDN
                Wmifilter = $Wmifilter
        
        }   #end of $Properties...

        
        #Add our new object to an array
        [Array]$TotalGPOs += $GpoInfo


    }   #end of foreach ($Backup in $Backups)...



    #####################
    ##BACKUP WMI FILTERS
    #Connect to the Active Directory to get details of the WMI filters
    $Wmifilters = Get-ADObject -Filter 'objectClass -eq "msWMI-Som"' `
                               -Properties msWMI-Author, msWMI-ID, msWMI-Name, msWMI-Parm1, msWMI-Parm2 `
                               -Server $DomainFQDN `
                               -ErrorAction SilentlyContinue



    ######################
    ##CREATE REPORT FILES
    ##XML reports
    #Create a variable for the XML file representing custom information about the backed up GPOs
    $CustomGpoXML = "$SubBackupFolder\GpoDetails.xml"

    #Export our array of custom GPO objects to XML so they can be easily re-imported as objects
    $TotalGPOs | Export-Clixml -Path $CustomGpoXML

    #if $WMifilters contains objects write these to an XML file
    if ($Wmifilters) {

        #Create a variable for the XML file representing the WMI filters
        $WmiXML = "$SubBackupFolder\Wmifilters.xml"

        #Export our array of WMI filters to XML so they can be easily re-imported as objects
        $Wmifilters | Export-Clixml -Path $WmiXML

    }   #end of if ($Wmifilters)


    ##CSV report / HTML Settings reports
    #Create a variable for the CSV file that will contain the SOM (Scope of Management) information for each backed-up GPO
    $SOMReportCSV = "$SubBackupFolder\GpoInformation.csv"

    #Now, let's create the CSV report and the HTML settings reports
    foreach ($CustomGPO in $TotalGPOs) {
        
        ##CSV report stuff    
        #Start constructing the CSV file line entry for the current GPO
        $CSVLine = "`"$($CustomGPO.Name)`",`"{$($CustomGPO.GPOGuid)}`","


        #Expand the SOMs property of the current object
        $CustomSOMs = $CustomGPO.SOMs


            #Loop through any SOMs returned
            foreach ($CustomSOM in $CustomSOMs) {

                #Append the SOM path to our CSV line
                $CSVLine += "`"$CustomSOM`","

         
           }   #end of foreach ($CustomSOM in $CustomSOMs)...


       #Write the newly constructed CSV line to the report
       Add-Content -Path $SOMReportCSV -Value $CSVLine


       ##HTML settings report stuff
	   #Remove invalid characters from GPO display name
	   $GpoCleanedName = $CustomGPO.Name -replace "[^1-9a-zA-Z_]", "_"
	
       #Create path to html file
	   $ReportPath = "$SubBackupFolder\$HtmlReports\$($CustomGPO.BackupGuid)___$($CustomGPO.GpoGuid)__$($GpoCleanedName).html"
	
       #Create GPO report
       Get-GPOReport -Guid $CustomGPO.GpoGuid -Path $ReportPath -ReportType HTML 


    }   #end of foreach ($CustomGPO in $TotalGPOs)...



    ###########
    ##MIGTABLE
    #Check whether a migration table should be created
    if ($MigTable) {

        #Create a variable for the migration table
        $MigrationFile = "$SubBackupFolder\MigrationTable.migtable"

        #Create a migration table 
        $MigrationTable = $GPM.CreateMigrationTable()


        #Connect to the backup directory
        $GpmBackupDir = $GPM.GetBackUpDir($SubBackupFolder)


        #Reset the GPM search criterea
        $GpmSearchCriteria = $GPM.CreateSearchCriteria()


        #Configure search critera for the most recent backup
        $GpmSearchCriteria.Add($Constants.SearchPropertyBackupMostRecent,$Constants.SearchOpEquals,$True)
   

        #Get GPO information
        $BackedUpGPOs = $GpmBackupDir.SearchBackups($GpmSearchCriteria)


            #Add the information to our migration table
            foreach ($BackedUpGPO in $BackedUpGPOs) {

                $MigrationTable.Add($Constants.ProcessSecurity,$BackedUpGPO)
        
            }   #end of foreach ($BackedUpGPO in $BackedUpGPOs)...


        #Save the migration table
        $MigrationTable.Save($MigrationFile)


    }   #end of if ($MigTable)...


}   #end of if ((Test-Path -Path $SubBackupFolder) -and (Test-Path -Path "$SubBackupFolder\$HtmlReports"))...
else {

    #Write error
    Write-Error -Message "Backup path validation failed"


}   #end of ((Test-Path -Path $SubBackupFolder) -and (Test-Path -Path "$SubBackupFolder\$HtmlReports"))

# SIG # Begin signature block
# MIIOgwYJKoZIhvcNAQcCoIIOdDCCDnACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVKMms1MjDDFigjfJsAQfPNfo
# WxugggvOMIIFvDCCA6SgAwIBAgITHgAAAAjRvX7DjspE9AAAAAAACDANBgkqhkiG
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
# IwYJKoZIhvcNAQkEMRYEFMEHXTqEHZcmCSQMNjoN4DCJsexcMA0GCSqGSIb3DQEB
# AQUABIIBAMWfFL4eZ2YpFs+1HAubC9XyFbpilAVEqKshpbxgkD3wCYvAN+bPib+0
# A0nfr7ljxC3boKcvfy+51tojQkiZ0JMV94oqorbGW5beroaCRmp0T1sIOJUQLtUN
# 6LkCX9U6qh8LCaGw/JmajFHCGfCrvBhCFv1Q4fOhpTlfDvgw+x4GU3REAfaN8NBy
# jLYkI8NgkWBpYKSp2698yG3Zdt9quEWOHz08sg0td7/eCEy1Rnt/0Is6LNx4eDVJ
# xnYoivIDzzt6jJTahL+nuV2h8mhloKz5M4RNm04Vz3yx/NvWLPRIJAhonK6/60Aw
# MsQ7V8hCVbHfjv/KRjAk1mbpAxscOXo=
# SIG # End signature block
