#Copies the AD security group memberships of one employee to other employees
#http://mikefrobbins.com/2014/01/30/add-an-active-directory-user-to-the-same-groups-as-another-user-with-powershell/

#User to copy's NetID
# $userToCopy = 'dittbrender'

# $usersToUpdate = @('hkellogg')


# ######################
# Write-Host "Copying permissions from $userToCopy" -ForegroundColor Yellow -BackgroundColor Black
# foreach($newUser in $usersToUpdate){
#     Write-Host "Copying permissions to $newUser" -ForegroundColor Cyan
#     Get-ADUser -Identity $userToCopy -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $newUser -PassThru | Select-Object -Property SamAccountName

#     Write-Host "Complete" -ForegroundColor Green
# }
# Write-Host "Complete" -ForegroundColor Green -BackgroundColor black




function Copy-UserGroupMembership {
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

    }catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Error $("Unable to locate Source user ({0}) in {1}" -f $Source,$(Get-ADDomain).DistinguishedName) -Category ObjectNotFound 
    }

    # iterate through list of target users and apply group membership from source
    for ($i = 0; $i -lt $Target.Count; $i++) {
        # Write-Progress -Activity "Copy-UserGroupMembership" -Status "Copying User Group Membership from $Source" -CurrentOperation $("Copying User Group Membership to"+$($Target[$i])) -PercentComplete (($i / $Target.Count)*100)

        # try to get the target user object
        try{
            [Microsoft.ActiveDirectory.Management.ADAccount]$TargetUser = Get-ADUser -Identity $Target[$i]
    
        }catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            Write-Error $("Unable to locate Target user ({0}) in {1}" -f $Target[$i],$(Get-ADDomain).DistinguishedName) -Category ObjectNotFound 
        }

        # write-out source user's groups
        Write-Host $("`n{0} Group Membership" -f $SourceUser.SamAccountName) -ForegroundColor Yellow
        (Get-ADUser -Identity $SourceUser -Properties memberof | Select-Object -ExpandProperty memberof).memberof

        # copy the permissions from the source to the target
        Get-ADUser -Identity $SourceUser -Properties "memberof" | Select-Object -ExpandProperty "memberof" | Add-ADGroupMember -Members $TargetUser -PassThru

    }
    
}


Copy-UserGroupMembership "bbadger" -Target "testerino"