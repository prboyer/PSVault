function Import-ADGroupMembers {
    <#
    .SYNOPSIS
    Script that adds users to an AD Security group from a list of names (ln, fn mi) in text file
    
    .DESCRIPTION
    Parse the provided text file to add existing AD users to a security group. The text file is supplied in the format (ln ,fn mi). The script performs string manipulation
    to get the names into a proper format for processing. The entire process is logged using the PowerShell transcript function (kinda lazy, I know) and writes out the file path
    provided in the -LogPath variable.
    
    .PARAMETER TextFilePath
    The input file with a list of names that need to be added to a security group in AD
    
    .PARAMETER Group
    Expecting an AD group object. This was added for additional versatility and to accommodate piping. 
    
    .PARAMETER GroupName
    The name of the AD security group. The script will handle creating a pointer to the object in AD.
    
    .PARAMETER LogPath
    The path where the log file should be saved.
    
    .EXAMPLE
    Import-ADGroupMembers -GroupName "Remote Desktop Users" -TextFilePath "C:\Users.txt" -LogFile "C:\Temp\"
    
    .NOTES
    Written by Paul B - 9-18-19
    #>
    param (
        [string]$TextFilePath,
        [Microsoft.ActiveDirectory.Management.ADGroup]$Group,
        [string]$GroupName,
        [string]$LogPath
    )
    
    # Read in the list of names
    $name_list = Get-Content $TextFilePath

    # Query AD to get security group object if not provided
    if (-not ($GroupName -eq "")) {
        $Group = Get-ADGroup $GroupName
    }

    # Begin logging
    if ($LogPath -ne "") {
        Start-Transcript -Path $LogPath
    }

    # start adding users
    foreach($line in $name_list){

        #do some string manipulation to get list from ln, fn mi --> fn _ ln
        $ln = [string]$line.Split(',')[0];
        $fn = [string]$line.Split(',')[1];

        #try removing mi if provided
        try{
            $fn = $fn.Split(' ')[0];
        }catch{}

        #concat the names back together to be fn _ ln
        $User = "$fn $ln";

        Write-Host "Adding $User to $Group.name"

        # add user to security group
        try{
            $ADUser = Get-ADUser -Filter {Name -like $User}
            Add-ADGroupMember -Identity $ADGroup -Members $ADUser 
            Write-Host "[Sucess]" -ForegroundColor Green
        }catch{
            Write-Host "[Error]: Failed to add $User to group" -ForegroundColor Red
        }
    }

    Write-Host "`n##############`n" $Group.Name "Members" -ForegroundColor Cyan
    Get-ADGroupMember $Group | Select-Object name, samAccountName, SID | Format-Table
}