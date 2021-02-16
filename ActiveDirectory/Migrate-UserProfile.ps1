function Migrate-UserProfile {
  <#
  .SYNOPSIS
  Script to help with the migration of user profiles from Windows 7 to Windows 10
  
  .DESCRIPTION
  Script checks if there exists a V2 roaming profile directory for a Windows 7 user exists on a profile server. Then it copies their profile data to a new
  V6 profile directory for use with Windows 10. 
  
  .PARAMETER Usernames
  String array of usernames that need to be migrated to V6 profiles.
  
  .PARAMETER ProfileServer
  Path to the fileserver share storing the user profiles
  
  .EXAMPLE
  Migrate-UserProfile -Usernames "Bgates" -ProfileServer "\\winfs1\users\"
  
  .NOTES
  Paul Boyer , 2/23/18
  #>
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [String[]]
      $Usernames,
      [Parameter(Mandatory=$true)]
      [String]
      $ProfileServer
  )
  # VARIABLES
    #directories that need to be copied
    [String[]]$directories = 'Contacts','Desktop','Documents','Downloads','Favorites','Music','Pictures','Videos'  

  # Validate that the path to the profile server can be resolved
  try {
    if(-not (Test-Path $ProfileServer)){
      Throw [System.IO.DirectoryNotFoundException]::new()
    }
  }
  catch [System.IO.DirectoryNotFoundException]{
    Write-Error -Category ObjectNotFound -Message $("Unable to resolve path to profile server at: {0}" -f $ProfileServer)
  }

  Write-Host "Profile Migration Script" -ForegroundColor Cyan
  Set-Location $ProfileServer

  #copy contents each directory in $directories to the appropriate location in the user's .V6 profile
  #traverse each profile in the profile list array
  foreach($profile in $Usernames){

    #navigate to V2 directory for each user in the profile list array
    if($profileServer.contains($profile.V2)){
      Write-Host "Copying $profile.V2 --> $profile.V6 on $profileServer" -ForegroundColor Yellow
      Set-Location $profileServer\$profile.V2

      #copy each directory in the directories array from the user's V2 profile to their V6 profile
      foreach($dir in $directories){
        Write-Host "Copying $dir" -ForegroundColor Yellow
        Copy-Item $dir -Destination $profileServer\$profile.V6 -Recurse -Force -Verbose
        Write-Host "Complete" -ForegroundColor Green -BackgroundColor Black
      }
    }
    else{
      #error handling for if a V2 directory does not exist on the server
      Write-Error $("No .V2 directory exists for {0}" -f $profile) -ErrorAction Continue -Category ObjectNotFound
    }
  }
}