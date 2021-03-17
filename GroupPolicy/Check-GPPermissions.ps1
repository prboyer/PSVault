<#
.SYNOPSIS
Script to report GPOs in a domain that do not have accessible ACLs applied.

.DESCRIPTION
The script will evaluate which GPOs are lacking 'Apply' permissions for either Authenticated Users or Domain Computers. If neither permission is applied, the group
policies themselves will not be applied. However, sometimes when a GPO is to be limited to a specific security group it is necessary to make the ACLs more targeted. With this in mind, 
certain GUIDs can excluded from the report.

.PARAMETER FilePath
Path to where the report should be saved. This should be a .txt file. 

.PARAMETER Fix
Switch parameter that will send the script into an interactive mode to fix the missing ACLs on GPOs

.PARAMETER Exclude
String Array of GUIDs to exclude from evaluation

.EXAMPLE
Check-GPPermissions -FilePath C:\Temp\Report.txt

.EXAMPLE
Check-GPPermissions -Fix

.NOTES

#>
function Check-GPPermissions{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $FilePath,
        [Parameter()]
        [Switch]
        $Fix,
        [Parameter()]
        [String[]]
        $Exclude
    )
    #Requires -Module GroupPolicy
    Import-Module GroupPolicy

    #List of GPOs that don't have proper permissions
    [System.Collections.ArrayList]$BadPermissions = [System.Collections.ArrayList]::new()

    #Get all GPOs in current domain
    [Object[]]$DomainGPOs = Get-GPO -All
    
    # For each GPO in $DomainGPOs, this block of logic checks to see if the GPO has an Apply ACL for either Authenticated Users or Domain Computers
    foreach($gpo in $DomainGPOs){
        if ((($gpo.GetSecurityInfo() | ?{$_.Trustee.Name -eq "Authenticated Users"} | Select-Object Permission).Permission -ine "GpoApply") -and 
        (($gpo.GetSecurityInfo() | ?{$_.Trustee.Name -eq "Domain Computers"} | Select-Object Permission).Permission -ine "GpoApply")){
            # Add the offending GPOs to the array list. Using Out-Null to suppress the index # returned to the console after adding to the list
            $BadPermissions.Add($gpo.Id.Guid) | Out-Null
        }
    }

    # Process the list of GUIDs to exclude from evaluation
    foreach($e in $Exclude){
        # need to covert the GUID to lowercase so that matching will work properly. GPO cmdlets report GUIDs in lowercase, and don't do case-insensitive matching
        $BadPermissions.Remove($e.ToLower())
    }

    Write-Information "`nGPOs that are missing both `"Authenticated Users`" and `"Domain Computers`" application scopes" -InformationAction Continue

    # Write out the polices that need to have new permissions applied. If -FilePath is supplied, pipe to the console and a file
    foreach($guid in $BadPermissions){
        if($FilePath -ne ""){
            # print out the results to the console and to the output file
            Get-GPO -Guid $guid | Select-Object DisplayName, Owner, ID, Description, GpoStatus, CreationTime, ModificationTime | Tee-Object -FilePath $FilePath -Append
        }else{
            $formattedResults += @(Get-GPO -Guid $guid | Select-Object DisplayName, Owner, ID, GpoStatus, CreationTime, ModificationTime)
        }
    }
    # display the results to just the console, but in a cleaner fashion
    $formattedResults | Sort-Object DisplayName | Format-Table -AutoSize

    # If fix is supplied, add the missing delegations to the GPOs interactively
    if($Fix){
        foreach($guid in $BadPermissions){
            Write-Host $(Get-GPO -Guid $guid).DisplayName -ForegroundColor Yellow
            (Get-GPO -Guid $guid).GetSecurityInfo() | Format-Table
            [int]$z = Read-Host -Prompt "Which ACL would you like to apply? `n[1] Authenticated Users `n[2] Domain Computers `n[3] Both`n[0] Exit`nPress `'Enter`' to skip without making changes"
            
            # add the missing ACL specified by the user
            switch ($z) {
                1 {Get-GPO -Guid $guid | Set-GPPermission -PermissionLevel GpoApply -TargetName "Authenticated Users" -TargetType Group}
                2{Get-GPO -Guid $guid | Set-GPPermission -PermissionLevel GpoApply -TargetName "Domain Computers" -TargetType Group}
                3{
                    Get-GPO -Guid $guid | Set-GPPermission -PermissionLevel GpoApply -TargetName "Authenticated Users" -TargetType Group;
                    Get-GPO -Guid $guid | Set-GPPermission -PermissionLevel GpoApply -TargetName "Domain Computers" -TargetType Group; 
                }
                0{exit;}
                Default {break;}
            }
        }
    }
}