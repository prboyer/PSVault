function Copy-UserGroupMembership {
    <#
    .SYNOPSIS
    Copies security group memberships from one user to one or more users
    
    .DESCRIPTION
    Script validates that AD user objects exist before trying to retrieve/apply group memberships. 
    
    .PARAMETER Source
    The SamAccountName of the user who the memberships should be copied from
    
    .PARAMETER Target
    String [] of SamAccountNames that the memberships should be applied to
    
    .EXAMPLE
    Copy-UserGroupMembership -Source Bgates -Target SBallmer

    .LINK
    http://mikefrobbins.com/2014/01/30/add-an-active-directory-user-to-the-same-groups-as-another-user-with-powershell/
    
    .NOTES
    
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Source,
        [Parameter(Mandatory=$true)]
        [string[]]
        $Target

    )

    Import-Module ActiveDirectory

    # try to get the source user object
    try{
        [Microsoft.ActiveDirectory.Management.ADAccount]$SourceUser = Get-ADUser -Identity $Source
    }
    # do error handling if Source cannot be found
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Error $("Unable to locate Source user ({0}) in {1}" -f $Source,$(Get-ADDomain).DistinguishedName) -Category ObjectNotFound 
    }

    # display the user group memberships of the Source user
    Write-Host $("{0} Group Membership" -f $Source) -ForegroundColor Cyan
    (Get-ADPrincipalGroupMembership -Identity $SourceUser | Select-Object samAccountName, objectGUID, DistinguishedName) | Format-Table

    foreach ($User in $Target) {
        
        # try to get the target user object
        try{
            [Microsoft.ActiveDirectory.Management.ADAccount]$TargetUser = Get-ADUser -Identity $User
    
        }
        # do error handling if Target cannot be found
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            Write-Error $("Unable to locate Target user ({0}) in {1}" -f $User,$(Get-ADDomain).DistinguishedName) -Category ObjectNotFound 
        }

        # write out status
        Write-Host $("Applying Group Membership to {0}" -f $User) -ForegroundColor Yellow

        # copy the permissions from the source to the target
        Get-ADUser -Identity $SourceUser -Properties "memberof" | Select-Object -ExpandProperty "memberof" | Add-ADGroupMember -Members $TargetUser

        Write-Host "Complete" -ForegroundColor Green

    }

}