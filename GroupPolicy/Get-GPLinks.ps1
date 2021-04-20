function Get-GPLinks {
    <#
    .SYNOPSIS
    Script to provide either a TXT or CSV report of linking relationships between OUs and GPOs.
    
    .DESCRIPTION
    Script that reports what OUs in the domain have what GPOs linked to them. 
    Intended for use with Group Policy backup as exported policies do not retain the link information.
    
    .PARAMETER Path
    Output path for files to be saved. This should be a directory path, not a file path.
    
    .PARAMETER CSVReport
    Parameter causes script to run just the CSV report of OU and GPO correlation
    
    .PARAMETER BothReports
    Parameter causes script to run both the CSV and TXT reports
    
    .PARAMETER AllOUs
    Parameter causes script to list all OUs at beginning of report, not just those with GPOs linked (default)
    
    .PARAMETER RootOnly
    Parameter causes script to only report GPOs linked at the Domain Root

    .Outputs
    A .txt file report and/or a .csv report
    
    .EXAMPLE
    Get-GPLinks -Path "C:\Temp"
    
    .NOTES
        Author: Paul Boyer
        Date: 3-19-21

        Fix for tables being cut of when writing out to file: https://poshoholic.com/2010/11/11/powershell-quick-tip-creating-wide-tables-with-powershell/

        Getting the line number of the error in PS: https://stackoverflow.com/questions/17226718/how-to-get-the-line-number-of-error-in-powershell

        Exporting Arrays to a CSV: https://community.spiceworks.com/topic/336094-exporting-arrays-to-a-csv-file

        Scoping in PowerShell: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.1#powershell-scopes
    #>
    param (
        [Parameter(Mandatory=$true,ParameterSetName="CSVReport")]
        [Parameter(Mandatory=$true,ParameterSetName="FullReport")]
        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,
        [Parameter(ParameterSetName="CSVReport")]
        [Switch]
        $CSVReport,
        [Parameter(Position=1)]
        [switch]
        $BothReports,
        [Parameter(ParameterSetName="FullReport")]
        [switch]
        $AllOUs,
        [Parameter(ParameterSetName="FullReport")]
        [switch]
        $RootOnly
    )
    #Requires -Module GroupPolicy
    #Requires -Module ActiveDirectory

    # Import module for determining GPO Links. Evaluate if the module is already loaded. Perform error handling if the module cannot be located
    try{
        if($(get-module | Where-Object {"GPFunctions" -in $_.name} | Measure-Object).Count -lt 1){
            Import-Module "$PSScriptRoot\External\GPFunctions.psm1" -ErrorAction Stop
        }

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

    # Validate that $Path can be resolved before executing the rest of the script
    if (-not (Test-Path -Path $Path -PathType Container)) {
        throw [System.IO.DirectoryNotFoundException]::new("Cannot resolve path. Directory not found.`n`t$Path")
    }

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
            Out-File -FilePath $Path -InputObject $($RootLinks | Format-Table -AutoSize) -Append -Force
        }catch [System.Management.Automation.ParameterBindingException] {
            
            # Perform silent error handling if the file cannot be generated. Likely because $Path was not supplied. 
            Write-Warning -Message $("Unable to bind argument from `$Path to -FilePath. Output not saved to file. `n{0}" -f $_.InvocationInfo.PositionMessage) -WarningAction $WarningPreference -WarningVariable Warn
        }
    }
    
    # Generate a CSV report of GPOs linked to each OU. Then write the results to the file represented by the -Path argument
    function private:New-CSVLinkReport([String]$Path) {
        #Requires -Module ActiveDirectory
        #Requires -Module GPFunctions

        # Array to store the results of Get-GPLink for each OU
        [Object[]]$private:Result= @();

        $OUList | ForEach-Object {
             $Result += @(
                # Get the DisplayName, Enabled status, Enforced status, Inheritance status, and GUID for each GPO. Combine those values with the DN of the corresponding OU for each.
                Get-GPLink -Path $_.DistinguishedName | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID, @{name='OU_DistinguishedName';expression={$_.OUDN}} 
            ) 
        }
        
        # Supply a PS table to the information stream that can be written to a file if desired
        Write-Information $($result | Format-Table -AutoSize | Out-String)
      
        # Array to store the objects returned from Get-GPLink. They need to be re-formatted into PSCustomObjects so that they can be properly written as to a CSV
        [Object[]]$FormatArray = @();
        $Result | ForEach-Object{
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

        # Exit with the last exit code
        exit $LASTEXITCODE;
    }elseif ($BothReports) {
        # Call the CSV report and then continue with the rest of the reporting
        private:New-CSVLinkReport($Path)  | Out-Null
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
            $OUList | Select-Object DistinguishedName | Sort-Object -Property DistinguishedName | Tee-Object -Variable LinkedGPOs | Format-Table -AutoSize
            
            # Write the contents of $LinkedGPOs to the file represented by the parameter $Path 
            try{
                Out-File -FilePath $OutputPath -InputObject $OU_Output -NoNewline -Force
                Out-File -FilePath $OutputPath -InputObject $($LinkedGPOs) -Append

            }catch [System.Management.Automation.ParameterBindingException] {
                
                # Perform silent error handling if the file cannot be generated. Likely because $Path was not supplied. 
                Write-Warning -Message $("Unable to bind argument from `$Path to -FilePath. Output not saved to file. `n{0}" -f $_.InvocationInfo.PositionMessage) -WarningAction $WarningPreference -WarningVariable Warn
            }
        }

    <#
        Traverse through the list of OUs and then report all GPOs linked to each OU
    #>  
        # Only report GPOs linked at the Domain Root
        if ($RootOnly) {
            private:Get-DomainRootLinks($OutputPath)
        }else{
            # Report GPOs linked to each OU
            $OUList | ForEach-Object {
                # Variable to store the output from traversing each OU and getting link details
                [String]$DetailOutput = "";

                Write-Output "$($_.DistinguishedName)" -OutVariable DetailOutput; 
                Write-Output $FORMAT_STRING.Substring(0,($_.DistinguishedName.Length))
                
                Get-GPLink -Path $_.DistinguishedName | Select-Object DisplayName, LinkEnabled, Enforced, BlockInheritance,GUID | Format-Table -AutoSize | Out-String -Width 4096 | Tee-Object -FilePath $OutputPath -Append 

                # Write the contents of $DetailOutput & $DetailTable to the file represented by the parameter $Path 
                try{
                    Out-File -FilePath $OutputPath -InputObject $DetailOutput -NoNewline -Append
                }catch [System.Management.Automation.ParameterBindingException] {
                    
                    # Perform silent error handling if the file cannot be generated. Likely because $Path was not supplied. 
                    Write-Warning -Message $("Unable to bind argument from `$Path to -FilePath. Output not saved to file. `n{0}" -f $_.InvocationInfo.PositionMessage) -WarningAction $WarningPreference -WarningVariable Warn
                }
            }
        }
}