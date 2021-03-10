function Disable-Users {
  <#
  .SYNOPSIS
  Script to disable AD users without deleting their accounts
  
  .DESCRIPTION
  Script takes in a String[] of usernames and disables each user. Optionally, the script can move users to an new OU 
  
  .PARAMETER TargetOU
  An [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit] object representing the new OU that disabled users should be moved to
  
  .PARAMETER Usernames
  String array of usernames that will be disabled by the script

  .PARAMETER LogFile
  String path to the log file that results should be saved to.
  
  .EXAMPLE
  Disable-Users -Usernames "bgates" -LogFile "C:\Log.txt"
  
  .NOTES
 
  #>
    [CmdletBinding()]
  param (
      [Parameter()]
      [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]
      $TargetOU,
      [Parameter(Mandatory=$true)]
      [String[]]
      $Usernames,
      [Parameter()]
      [String]
      $LogFile
  )

    foreach($i in $Usernames){
        try{
            # try finding the user object in AD
            [Microsoft.ActiveDirectory.Management.ADUser]$User = Get-ADUser $i
            Write-Information $("{0} ({1})" -f $User.Name, $User.SamAccountName) -
        }catch{
            # error handling for if the user object cannot be resolved
            Write-Error $("Unable to find a AD Object with the username {0}" -f $i)
        }

        # check of a path to a log file was supplied
        if($LogFile -ne $null){
            # T the processs to both console and log
            $User | Disable-ADAccount -PassThru | Select-Object Name, SamAccountName, Enabled, SID | Format-Table -AutoSize | Tee-Object -FilePath $LogFile -Append
        }else{
            # othewise, disable the users and just write to the console 
            $User | Disable-ADAccount -PassThru | Select-Object Name, SamAccountName, Enabled, SID | Format-Table -AutoSize
        }

        # if specified, move the disabled users to a new OU
        if($TargetOU -ne $null){
            if($LogFile -ne $null){
                # T the process to both console and log file
                $User | Move-ADObject -TargetPath $TargetOU -PassThru | Tee-Object -FilePath $LogFile -Append
            }else{
                # otherwise, just run the logic and don't write to a file
                $User | Move-ADObject -TargetPath $TargetOU -PassThru
            }
        }

        Write-Host "Complete" -ForegroundColor Green
    }
}