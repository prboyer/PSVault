function Migrate-UserProfile {
  <#
    .SYNOPSIS
    Script used in preparing to migrate from a Windows 7 to Windows 10 environment. This copies the contents of a user's 
    Windows 7 roaming profile to a new Windows 10 (V6) roaming profile on a specified profile server. 
    
    .DESCRIPTION
    For each username, check that the Windows 7 profile (V2) exists on the profile server. 
    If it does, then copy the contents of the V2 profile to a new Windows 10 (V6) profile. 
    
    .PARAMETER Usernames
    String array of usernames whose profiles need to be migrated to V6
    
    .PARAMETER ProfileServer
    Path to the share on the profile server containing the user profile directories.
    
    .EXAMPLE
    Migrate-UserProfile -Usernames "BGates" -ProfileServer "\\winfs\share1\Users"
    
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
    if(Test-Path -Path $ProfileServer\$profile.V2){
      Write-Host "Copying $profile.V2 --> $profile.V6 on $profileServer" -ForegroundColor Yellow
      Set-Location $profileServer\$profile.V2
      Get-Location | Get-ChildItem 

      #confirm that a V6 profile also exists on the server
      if (Test-Path -Path $ProfileServer\$profile.V6) {
        #copy each directory in the directories array from the user's V2 profile to their V6 profile
        foreach($dir in $directories){
          Write-Host "Copying $dir" -ForegroundColor Yellow
          Copy-Item $dir -Destination $profileServer\$profile.V6 -Recurse -Force -Verbose
          Write-Host "Complete" -ForegroundColor Green
        }
      }else{
        #error handling for if a V6 directory does not exist on the server
        Write-Error "No .V6 directory exists for $profile" -Category ObjectNotFound -ErrorAction Continue
      } 
    }
    else{
      #error handling for if a V2 directory does not exist on the server
      Write-Error "No .V2 directory exists for $profile" -Category ObjectNotFound -ErrorAction Continue
    }
  }
  
  Write-Host "Complete" -ForegroundColor Green -BackgroundColor Black
}