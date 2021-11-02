function Compare-ADGroupMembership{
    <#
    .SYNOPSIS
    A script for comparing two Active Directory users' group membership.
    
    .DESCRIPTION
    The script grabs the group membership of two Active Directory users and compares them. Then optionally writes the output to a file. Additionally, the script can show similar groups between the users.
    
    .PARAMETER ReferenceUser
    The username of the user whose group membership is to be compared as the left operand.
    
    .PARAMETER DifferenceUser
    The username of the user whose group membership is to be compared as the right operand.
    
    .PARAMETER OutFile
    Optional path to write the output to a file
    
    .PARAMETER IncludeBoth
    Switch that will cause the script show similar groups between the users
    
    .EXAMPLE
    Compare-ADGroupMembership -ReferenceUser "jdoe" -DifferenceUser "jsmith" -OutFile "C:\Users\jdoe\Desktop\GroupMembership.txt"
    
    .NOTES
        Author: Paul Boyer
        Date: 11-2-2021
    #>
    param(
        [Parameter(Mandatory=$true)]
        [String]
        $ReferenceUser,
        [Parameter(Mandatory=$true)]
        [String]
        $DifferenceUser,
        [Parameter()]
        [String]
        $OutFile,
        [Parameter()]
        [switch]
        $IncludeBoth
    )

    #Requires -Module ActiveDirectory

    # Variables
    [String]$LogOutput

    # Get the AD User object for the reference user
    try{
        [Microsoft.ActiveDirectory.Management.ADUser]$RUser = Get-ADUser -Filter "SamAccountName -like `"*$($ReferenceUser)*`""
    }catch{
        Write-Error ("Unable to locate reference user object '{0}' in {1} domain." -f $ReferenceUser, (Get-ADDomain).DNSRoot) -ErrorAction Stop -ErrorVariable +LogOutput
    }

    # Get the AD user object for the difference user
    try{
        [Microsoft.ActiveDirectory.Management.ADUser]$DUser = Get-ADUser -Filter "SamAccountName -like `"*$DifferenceUser*`""
    }catch{
        Write-Error ("Unable to locate difference user object '{0}' in {1} domain." -f $DifferenceUser, (Get-ADDomain).DNSRoot) -ErrorAction Stop -ErrorVariable +LogOutput
    }

    # Get all the groups each user is a member of
    Write-Information "Get all groups that each user is a member of`n" -InformationAction Continue -InformationVariable +LogOutput
    @($RUser,$DUser) | ForEach-Object {
        Write-Information ("{0} ({1})" -f $_.Name,$_.SamAccountName) -InformationAction Continue; 
        $AllGroups = Get-ADPrincipalGroupMembership $_ | Select-Object Name, samAccountName, GroupScope, SID;
        
        # Write table to the console
        Write-Information ($AllGroups | Sort-Object Name | Format-Table -AutoSize | Out-String) -InformationAction Continue -InformationVariable +LogOutput;
        
    }

   # Do a side-by-side comparison of the groups each user is a member of
   Write-Information ("Do a side-by-side comparison of group membership`n`t'<=' {0}`n`t'=>' {1}" -f $RUser.Name, $DUser.Name) -InformationAction Continue -InformationVariable +LogOutput
    
    # If the -IncludeBoth switch is specified, then include groups that both the reference and difference user are members of
    if ($IncludeBoth) {
            $Compare = Compare-Object -ReferenceObject $(Get-ADPrincipalGroupMembership $RUser).Name -DifferenceObject $(Get-ADPrincipalGroupMembership $DUser).Name -IncludeEqual
            Write-Information ($Compare | Out-String) -InformationAction Continue -InformationVariable +LogOutput
    }else{
            $Compare = Compare-Object -ReferenceObject $(Get-ADPrincipalGroupMembership $RUser).Name -DifferenceObject $(Get-ADPrincipalGroupMembership $DUser).Name 
            Write-Information ($Compare | Out-String) -InformationAction Continue -InformationVariable +LogOutput
    }

    # Write the output to a file
    if ($null -ne $OutFile) {
        $LogOutput | Out-File -FilePath $OutFile -Force
    }

}