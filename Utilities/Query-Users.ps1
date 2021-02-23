function Query-Users {
    <#
    .SYNOPSIS
    PowerShell implementation of quser.exe
    
    .DESCRIPTION
    Returns a table of logged on users, and the logon time as a a workable PowerShell Custom Object [System.Management.Automation.PSCustomObject]
    
    .PARAMETER ShowIndicator
    Switch parameter to print the logged on user indicator in the table
    
    .EXAMPLE
    Query-Users

    .EXAMPLE
    Query-Users -ShowIndicator

    .LINK
    https://stackoverflow.com/questions/39212183/easier-way-to-parse-query-user-in-powershell

    .LINK
    https://ss64.com/nt/query-user.html 
    
    .NOTES
    Paul Boyer 2-23-21
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $ShowIndicator
    )

    # run the 'quser' cmd, store the result in $result
    $result  = &quser

    # parse the returned string to a workable powershell object
    $quser = $result -replace '\s{2,}', ',' | ConvertFrom-Csv

    # only perfrom the -ShowIndicator parameter is NOT passed
    if(-not $ShowIndicator){
        # trim the ">" character from logged on user
        $quserTable = $quser | %{
            # if the username has the ">", set the username to itself with the ">" trimmed
            if($_.username -like ">*"){
                $_.username = $_.username.trim(">");
                $_;
            }
            else{
                # otherwise do nothing
                $_;
            }
        }
    }else{
        $quserTable = $quser
    }

    return $quserTable; 
}