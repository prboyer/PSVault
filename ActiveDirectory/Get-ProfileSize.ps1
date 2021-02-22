function Get-ProfileSize {
    param (
        [Parameter(Mandatory=$true)]
        [String[]]
        $Username,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
        [System.String]
        $ProfileServer
    )
    
    # check if the profile exists on the server. Expecting a profile without a ".V6" suffix
    $profiles = Get-ChildItem $ProfileServer

    if($profiles.Name -icontains $Username[0]){
        $true;
    }

}
Get-ProfileSize -Username "pboyer2","paul" -ProfileServer "\\sscwin\dfsroot\users"