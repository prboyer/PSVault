function Get-GPLinks {
    param (
        [String]
        $Path,
        [Parameter(ParameterSetName="CSVReport")]
        [Switch]
        $CSVReport,
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

    # Global Variables
        # Formatting string
        [String]$global:FORMAT_STRING = "***************************************************************************************************************************************"

        # Output file
        [String]$global:OutputPath = "$Path\$(Get-Date -Format FileDate)_GPOLinkReport.txt"

        # List of OUs with more than 1 GPO linked
        [Object[]]$global:OUList = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.LinkedGroupPolicyObjects.Count -gt 0}

    # ##########

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
            Out-File -FilePath $Path -InputObject $($RootLinks | Format-Table -AutoSize) -Append
        }catch [System.Management.Automation.ParameterBindingException] {
            
            # Perform silent error handling if the file cannot be generated. Likely because $Path was not supplied. 
            Write-Warning -Message $("Unable to bind argument from `$Path to -FilePath. Output not saved to file. `n{0}" -f $_.InvocationInfo.PositionMessage) -WarningAction $WarningPreference -WarningVariable Warn
        }
    }
    
    # Generate a CSV report of GPOs linked to each OU. Then write the results to the file represented by the -Path argument
    function private:New-CSVLinkReport([String]$Path) {
        #Requires -Module ActiveDirectory
        #Requires -Module GPFunctions

        # Get all OUs with 1 or more linked GPOs
        # [Object[]]$private:OUList = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.LinkedGroupPolicyObjects.Count -gt 0}
        # $OUList | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName | Format-Table -AutoSize

        # Array to store the results of Get-GPLink for each OU
        [Object[]]$private:Result= @();

        $OUList | %{
             $Result += @(
                # Get the DisplayName, Enabled status, Enforced status, Inheritance status, and GUID for each GPO. Combine those values with the DN of the corresponding OU for each.
                Get-GPLink -Path $_.DistinguishedName | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID, @{name='OU_DistinguishedName';expression={$_.OUDN}} 
            ) 
        }
        
        # Supply a PS table to the information stream that can be written to a file if desired
        Write-Information $($result | Format-Table -AutoSize | Out-String)
      
        # Array to store the objects returned from Get-GPLink. They need to be re-formatted into PSCustomObjects so that they can be properly written as to a CSV
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
        
        # Write the formatted array to a CSV file
        $FormatArray | Export-Csv -Path "$Path\$(Get-Date -Format FileDate)_GPOLinkReport.csv" -NoTypeInformation -Force

        return $($result | Format-Table -AutoSize)     
    }


    # Call the private function for generating the CSV report if -CSVReport is passed.
    if($CSVReport){
        private:New-CSVLinkReport($Path)  | Out-Null

        # Exit with the last 
        exit $LASTEXITCODE;
    }
    

    <#
        Report the OUs in the domain. If -AllOUs is specified, the Distinguished Name of All OUs will be returned. Otherwise, by default,
        only OUs with linked GPOs will be returned.
    #>

        # Variable to store the output for OU related steps
        [String]$OU_Output;

        if($AllOUs){
            # Report all OUs in domain
            [String]$domainName = (Get-ADDomain).Forest
            Write-Output "`nAll Organizational Units in $domainName" -OutVariable OU_Output
            Write-Output $FORMAT_STRING.Substring(0,(("Organizational Units in $domainName").Length)) 

            # Get all OUs and sort by their Distinguished Name. Then Tee out to $AllOUs and the console
            [Object[]]$AllOUs = Get-ADOrganizationalUnit -Filter * | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName 
            $AllOUs | Format-Table -AutoSize
            
            # Write the contents of $AllOUs to the file represented by the parameter $Path 
            try{
                Out-File -FilePath $OutputPath -InputObject $OU_Output -NoNewline
                Out-File -FilePath $OutputPath -InputObject $($AllOUs | Format-Table -AutoSize) -Append
            }catch [System.Management.Automation.ParameterBindingException] {
                
                # Perform silent error handling if the file cannot be generated. Likely because $Path was not supplied. 
                Write-Warning -Message $("Unable to bind argument from `$Path to -FilePath. Output not saved to file. `n{0}" -f $_.InvocationInfo.PositionMessage) -WarningAction $WarningPreference -WarningVariable Warn
            }
        }else{
            # Report all OUs in domain with linked GPOs
            Write-Output "Organizational Units with Linked GPOS" -OutVariable OU_Output
            Write-Output $FORMAT_STRING.Substring(0,(("Organizational Units with Linked GPOS").Length)) 
            # [Object[]]$OUList = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.LinkedGroupPolicyObjects.Count -gt 0}
            $OUList | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName | Tee-Object -Variable LinkedGPOs | Format-Table -AutoSize
            
            # Write the contents of $LinkedGPOs to the file represented by the parameter $Path 
            try{
                Out-File -FilePath $OutputPath -InputObject $OU_Output -NoNewline
                Out-File -FilePath $OutputPath -InputObject $($LinkedGPOs | Format-Table -AutoSize) -Append
            }catch [System.Management.Automation.ParameterBindingException] {
                
                # Perform silent error handling if the file cannot be generated. Likely because $Path was not supplied. 
                Write-Warning -Message $("Unable to bind argument from `$Path to -FilePath. Output not saved to file. `n{0}" -f $_.InvocationInfo.PositionMessage) -WarningAction $WarningPreference -WarningVariable Warn
            }
        }

    <#
        Traverse through the list of OUs and then report all GPOs linked to each OU
    #>

        # Report GPOs linked to each OU
        $OUList |Select -First 1 | ForEach-Object {
            Write-Output "$($_.DistinguishedName)"; 
            Write-Output $FORMAT_STRING.Substring(0,($_.DistinguishedName.Length));
            Get-GPLink -Path $_.DistinguishedName | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID | Format-Table -AutoSize 
        }
}
Get-GPLinks -Path "$PSScriptRoot"