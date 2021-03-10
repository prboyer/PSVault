<#
.SYNOPSIS
Script for determining when AD user accounts were created.

.DESCRIPTION
The script will either return a simple query for when a single user account was created, or a report
of what user accounts were created in the last X days. 

.PARAMETER Username
String representing the username of the user account to query. The script will return the date created.

.PARAMETER Date
DateTime when new accounts created thereafter should be returned.

.PARAMETER Days
Int number of days prior to today that the script should evaluate

.PARAMETER FilePath
Path to where the resulting file should be saved

.EXAMPLE
Get-ADUserDate -Days 30 

.EXAMPLE
Get-ADUserDate -Days 30 -FilePath C:\Results.txt

.NOTES

#>
function Get-ADUserDate {
    param (
        [Parameter(ParameterSetName="User")]
        [String]
        $Username,
        [Parameter(ParameterSetName="Date")]
        [DateTime]
        $Date,
        [Parameter(ParameterSetName="Date")]
        [Int]
        $Days,
        [Parameter()]
        [String]
        $FilePath
    )
    #requires -Modules ActiveDirectory

    if($Username -ne ""){
        try{
            Get-ADUser $Username -Properties whenCreated | Select-Object Name, SamAccountName, whenCreated
        }catch{
            Write-Error $("Unable to locate user {0} in Active Directory." -f $Username)
        }
    }

    # process a report of all users created since $Date
    if($Date -ne $null -or $Days -ne 0){
        if ($Days -ne 0) {
           [DateTime]$CreateDate = $(Get-Date).AddDays([int]$Days*-1) 
        }else{
            [DateTime]$CreateDate = $Date
        }


        # Get all AD users created within the last X days (specified by -Date). Select whencreated, name, samaccountname 
        $A = Get-ADUser -Filter {whenCreated -ge $CreateDate} -Properties whenCreated | Select-Object Name, SamAccountName, whenCreated 
        
        # Generate a custom PSObject so that the formatting of the date can be shortened 
        $B = $A | %{
            [PSCustomObject]@{
                Name = $_.Name
                SamAccountName = $_.SamAccountName
                DateCreated = $_.whenCreated.ToShortDateString()
            }
            # group the object by the properly formatted date
        } | Group-Object -Property DateCreated

        # iterate through each of the groupings, and then print out the names for each group
        for ($i = 0; $i -lt ($B.Name | Measure-Object).Count; $i++) {
            if($i -ne 0){
                if($FilePath -ne ""){
                    "***** " + $B[$i].Name + " *****" | Tee-Object -FilePath $FilePath -Append
                }else{
                    "***** " + $B[$i].Name + " *****"
                }
            }
            # group by date, then sort by Name
            if($FilePath -ne ""){
                $B[$i].Group | Sort-Object Name | Tee-Object -FilePath $FilePath -Append
            }else{
                $B[$i].Group | Sort-Object Name
            }
        }
    }
}