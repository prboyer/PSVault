#**********************************
#Profile Move Script
#Paul Boyer , 2/23/18
#**********************************
#$$$$$$$$ Revisions $$$$$$$$
# 2/28 - Added IF statement to verify if a V2 profile already exists on the server. If not, throws an error


#######################################################################

#update this list with the NetID of users who need their profiles copied
$profileList = 'kgiese'

#######################################################################

#location of profile server
$profileServer = '\\fs-se-3\Users'

#directories that need to be copied
$directories = 'Contacts','Desktop','Documents','Downloads','Favorites','Music','Pictures','Videos'

#extraneous directories
#$extraneousDirectories = 'AppData','.oracle_jre_usage','Links','Saved Games','Searches'


Write-Host "Profile Migration Script" -ForegroundColor Cyan
Write-Host "Set Location $profileServer"
Set-Location $profileServer

#copy contents each directory in $directories to the appropriate location in the user's .V6 profile
#traverse each profile in the profile list array
foreach($profile in $profileList){

   #navigate to V2 directory for each user in the profile list array
   if($profileServer.contains($profile.V2)){
     Write-Host "Copying $profile.V2 --> $profile.V6 on $profileServer" -ForegroundColor Yellow
     Set-Location $profileServer\$profile.V2
     ls
    #copy each directory in the directories array from the user's V2 profile to their V6 profile
        foreach($dir in $directories){
           Write-Host "Copying $dir" -ForegroundColor Yellow
          Copy-Item $dir -Destination $profileServer\$profile.V6 -Recurse -Force -Verbose
            Write-Host "Complete" -ForegroundColor Green    -BackgroundColor Black
            }
    }
    else{

        #error handling for if a V2 directory does not exist on the server
        Write-Host "No .V2 directory exists for $profile" -ForegroundColor Red
    }
}


function Migrate-UserProfile {
  param (
    [Parameter(Mandatory=$true)]
    [String[]]
    $Usernames,
    [Parameter(Mandatory=$True)]
    [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
    [System.IO.Path]
    $ProfileServer
  )
 
  #directories that need to be copied
  [String[]]$directories = @('Contacts','Desktop','Documents','Downloads','Favorites','Music','Pictures','Videos')

  #extraneous directories
  #$extraneousDirectories = 'AppData','.oracle_jre_usage','Links','Saved Games','Searches'


  Write-Host "Profile Migration Script" -ForegroundColor Cyan

  #copy contents each directory in $directories to the appropriate location in the user's .V6 profile
  #traverse each profile in the profile list array
  foreach($profile in $Usernames){

    #navigate to V2 directory for each user in the profile list array
    if($profileServer.contains($profile.V2)){
      Write-Host "Copying $profile.V2 --> $profile.V6 on $profileServer" -ForegroundColor Yellow
      Set-Location $profileServer\$profile.V2
      Get-Location | Get-ChildItem 

      #copy each directory in the directories array from the user's V2 profile to their V6 profile
      foreach($dir in $directories){
        Write-Host "Copying $dir" -ForegroundColor Yellow
        Copy-Item $dir -Destination $profileServer\$profile.V6 -Recurse -Force -Verbose
        Write-Host "Complete" -ForegroundColor Green
      }
    }
    else{

        #error handling for if a V2 directory does not exist on the server
        Write-Host "No .V2 directory exists for $profile" -ForegroundColor Red
    }
  }
  Write-Host "Complete" -ForegroundColor Green -BackgroundColor Black

}