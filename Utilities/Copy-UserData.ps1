#************************
#Profile Move Script
#Paul Boyer , 11-17-2020
#************************
#######################################################################
[String]$oldProfilePath = "E:\Users\kszabados"

[String]$newProfilePath = "C:\Users\knspear"
#######################################################################

#directories that need to be copied
[String]$directories = @('Contacts','Desktop','Documents','Downloads','Favorites','Music','Pictures','Videos')

#extraneous directories
[String]$extraneousDirectories = @('AppData','.oracle_jre_usage','Links','Saved Games','Searches','Local Settings','Application Data','B')

Start-Process -FilePath robocopy.exe -ArgumentList "$oldProfilePath $newProfilePath /S /ETA /R:1 /W:3 /XX /XD $extraneousDirectories" -Wait -NoNewWindow