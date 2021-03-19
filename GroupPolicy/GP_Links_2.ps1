# Powershell script that reports what OUs in the domain have what GPOs linked to them. Intended for use with Group Policy backup as exported policies do not retain the link information.
# Paul B - 4-23-2020

# # Destination of the report file. $Args[0] should be the output file path. If null or inaccessible, then save at script root
# if ($args[0] -eq $null) {
#     $logDir = $PSScriptRoot
# }elseif(Test-Path $args[0]){
#     $logDir = $args[0]
# }else{
#     $logDir = $PSScriptRoot
# }

# # Formatting
# $FORMAT_STRING = "*************************************************************************************************************************************"

# # Start logging 
# New-Item -Path "$logDir\Link Report-$(Get-Date -Format 'yyyyMMdd').txt" -ItemType File
# $file = Get-Item -Path "$logDir\Link Report-$(Get-Date -Format 'yyyyMMdd').txt"

# # Import Functions
# Import-Module "$PSScriptRoot\External\GPFunctions.psm1"

# # Report all OUs in domain
# $domainName = (Get-ADDomain).Forest
# Write-Output "`n"
# Write-Output "Organizational Units in $domainName" >> $file
# Write-Output $FORMAT_STRING.Substring(0,(("Organizational Units in $domainName").Length)) >> $file
# Get-ADOrganizationalUnit -Filter * | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName | Format-Table >> $file

# # Report all OUs in domain with linked GPOs
# Write-Output "Organizational Units with Linked GPOS" >> $file
# Write-Output $FORMAT_STRING.Substring(0,(("Organizational Units with Linked GPOS").Length)) >> $file
# $OUList = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.LinkedGroupPolicyObjects.Count -gt 0}
# $OUList | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName | Format-Table >> $file

# # Report GPOS linked to domain root
# $domainRoot = (Get-ADDomain).DistinguishedName
# Write-Output "$domainRoot" >> $file
# Write-Output $FORMAT_STRING.Substring(0,("$domainRoot").Length) >> $file
# Get-GpLink -Path $domainRoot | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID | Format-Table -AutoSize >> $file

# # Report GPOs linked to each OU
# $OUList | ForEach-Object {Write-Output "$($_.DistinguishedName)" >> $file; Write-Output $FORMAT_STRING.Substring(0,($_.DistinguishedName.Length)) >> $file;
# Get-GPLink -Path $_.DistinguishedName | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID | Format-Table -AutoSize >> $file}

# #Mass Report that shows the one to many relationship of OUs and GPO Links
# Write-Output "Correlation Table" >> $file
# Write-Output $FORMAT_STRING.Substring(0,"Correleation Table".Length) >> $file

# $reportArray = @();

# $OUList += $domainRoot

# foreach ($item in $OUList) {
#     if($item.DistinguishedName -eq $domainRoot.DistinguishedName){
#         $links = Get-ADDomain | select -ExpandProperty linkedgrouppolicyobjects | ForEach-Object {$_.Substring($_.IndexOf('{'),38)} 
#         $links | ForEach-Object {$r = "" | Select-Object OU_Name, Linked_GUIDS; $r.OU_Name = (Get-ADDomain).DistinguishedName; $r.Linked_GUIDS = $_ ; $reportArray += $r;}
#     }else{
#         $links = Get-ADOrganizationalUnit -SearchBase $item.DistinguishedName -Filter * | select -ExpandProperty linkedgrouppolicyobjects | ForEach-Object {$_.Substring($_.IndexOf('{'),38)} 
#         $links | ForEach-Object {$r = "" | Select-Object OU_Name, Linked_GUIDS; $r.OU_Name = $item.DistinguishedName; $r.Linked_GUIDS = $_ ; $reportArray += $r;}
#     }
# }

# $reportArray | Format-Table -AutoSize #>> $file

#############################################
<#
http://learningpcs.blogspot.com/2011/08/powershell-nested-functions.html
#>
function Get-GPLinks {
    param (
        # [Parameter(Mandatory=$true)]
        # [String]
        # $Path,
        [Parameter()]
        [switch]
        $AllOUs,
        [Parameter()]
        [switch]
        $RootOnly
    )
    #Requires -Module GroupPolicy
    #Requires -Module ActiveDirectory

    # Import module for determining GPO Links. Perform error handling if the module cannot be located
    try{
        Import-Module "$PSScriptRoot\External\GPFunctions.psm1" -ErrorAction Stop
    }catch [System.IO.FileNotFoundException]{
        # Terminate process of the script if the requisite module cannot be imported
        Write-Error "Unable to locate module 'GPFunctions.psm1'" -Category ObjectNotFound 
        Exit;
    }
    
    <#
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.1#powershell-scopes
    #>

    # Formatting string
    $global:FORMAT_STRING = "***************************************************************************************************************************************"

    # Report GPOS linked to the Domain Root. Write the results to the file represented by the -Path argument
    function private:Get-DomainRootLinks ([String]$Path) {
        #Requires -Module ActiveDirectory
        #Requires -Module GPFunctions    
        
        # Dynamically get the name of the AD Domain using cmdlet from the Active Directory module
        [String]$domainRoot = (Get-ADDomain).DistinguishedName
        
        Write-Information "GPOs Linked to Domain Root" -InformationAction Continue
        Write-Output "$domainRoot" 
        Write-Output $FORMAT_STRING.Substring(0,("$domainRoot").Length)
        
        # Use Get-GPLink cmdlet from GPFunctions module to get the linked GPOs for each OU at the Domain Root. Then Tee out to $RootLinks and the Console
        Get-GpLink -Path $domainRoot | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID | Tee-Object -Variable RootLinks | Format-Table -AutoSize
        
        # Write the contents of $RootLinks to the file represented by the parameter $Path 
        try{
            Out-File -FilePath $Path -InputObject $RootLinks -Append
        }catch [System.Management.Automation.ParameterBindingException] {
            
            # Perform silent error handling if the file cannot be generated. Likely because $Path was not supplied. 
            Write-Warning -Message "Unable to bind argument from `$Path to -FilePath. Output not saved to file." -WarningAction SilentlyContinue
        }
    }


















    # Only report if the -AllOUs parameter is supplied
    if($AllOUs){
        # Report all OUs in domain
        $domainName = (Get-ADDomain).Forest
        Write-Output "`nOrganizational Units in $domainName"
        Write-Output $FORMAT_STRING.Substring(0,(("Organizational Units in $domainName").Length)) 
        Get-ADOrganizationalUnit -Filter * | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName | Format-Table -AutoSize
    }else{
        # Report all OUs in domain with linked GPOs
        Write-Output "Organizational Units with Linked GPOS" 
        Write-Output $FORMAT_STRING.Substring(0,(("Organizational Units with Linked GPOS").Length)) 
        $OUList = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.LinkedGroupPolicyObjects.Count -gt 0}
        $OUList | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName | Format-Table -AutoSize
    }

    if($RootOnly){
         Get-DomainRootLinks;
    }else{
         Get-DomainRootLinks;

        # Report GPOs linked to each OU
        $OUList |Select -First 1 | ForEach-Object {
            Write-Output "$($_.DistinguishedName)"; 
            Write-Output $FORMAT_STRING.Substring(0,($_.DistinguishedName.Length));
            Get-GPLink -Path $_.DistinguishedName | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID | Format-Table -AutoSize 
        }
    }
}
# Get-GPLinks


        # # # CSV report of GPOs and their Linked OUs
        
        [Object[]]$OUList = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.LinkedGroupPolicyObjects.Count -gt 0} | Select -First 2
        # $OUList | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName | Format-Table -AutoSize

        # Array to store the results of Get-GPLink for each OU
        [Object[]]$Result= @();

        $OUList | %{
             $Result += @(
                Get-GPLink -Path $_.DistinguishedName | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID, @{name='OU_DistinguishedName';expression={$_.OUDN}} 
            ) 
        }

        $result | FT -AutoSize
        <#
        https://community.spiceworks.com/topic/336094-exporting-arrays-to-a-csv-file
        #>

        [Object[]]$FormatArray = @();
        $Result | %{
             $FormatArray += @(
                [PSCustomObject]@{
                'DisplayName' = $_.DisplayName
                'LinkEnabled' = $_.LinkEnabled
                'Enforced' = $_.Enforced
                'BlockInheritance' = $_.BlockInheritance
                'GUID' = $_.GUID
                'OU_DistinguishedName' = $_.OU_DistinguishedName
                }
            )
        }
        
        $FormatArray | Export-Csv -Path "$PSScriptRoot\$(Get-Date -Format FileDate)_GPOLinkReport.csv" -NoTypeInformation -Append
















<#
https://stackoverflow.com/questions/17226718/how-to-get-the-line-number-of-error-in-powershell
#>

