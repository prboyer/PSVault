function Get-ProfileSize {
    <#
    .SYNOPSIS
    Script to calculate the size of a user profile on a profile server
    
    .DESCRIPTION
    Given an list of usernames and a share on a profile server, the script will calculate the sizes of profiles matching given usernames
    
    .PARAMETER Username
    String array of usernames. Profile extensions (".v6") not required, script will perform wildcard lookup
    
    .PARAMETER ProfileServer
    Path to share on profile server containing user profile directories
    
    .EXAMPLE
    Get-ProfileSize -Username "BGates" -ProfileServer "\\winfs1\dfsroot\Users"
    
    .NOTES
    Paul Boyer - 2-22-21
    #>
    param (
        [Parameter(Mandatory=$true)]
        [String[]]
        $Username,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
        [System.String]
        $ProfileServer
    )
    # Get a list of profiles on the profile server
    [Object[]]$profiles = Get-ChildItem $ProfileServer
    
    # iterate through list of usernames
    for ($i = 0; $i -lt $Username.Count; $i++) {
        
        # get the profile directory and then calculate the size as a sum of all child objects
        try{
            $prof =  Get-Item -Path ($profiles | ?{$_.Name -like $Username[$i]+"*"} | Select-Object FullName).fullname
            $profsize = ($prof | Get-ChildItem -Recurse -Force | Measure-Object -Property Length -Sum)
        }catch{
            Write-Error $("Profile path not able to be resolved for user: {0}" -f $Username[$i])
            break;
        }

        $profsize_MB = $profsize.Sum / 1MB;
        $profsize_GB = $profsize.Sum / 1GB;
        
        # create a custom object to report the values
        [PSCustomObject]@{
            Name = $prof.Name.Trim(".vV6")
            FullName = $prof.FullName
            Size_MB = $profsize_MB
            Size_GB = $profsize_GB
        }
    }
}