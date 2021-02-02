function Copy-LocalUserProfile {



#A custom cmdlet for quickly copying the contents of a user's profile to another location. 

#Paul Boyer, 11-17-2020

    param (
        [Parameter(Mandatory = $true)]
        [String]
        $SourcePath,
        [Parameter (Mandatory = $true)]
        [String]
        $TargetPath,
        [Parameter]
        [String]
        $LogPath,
        [Parameter]
        [Int]
        $WaitDelay
    )

    ## CONFIGURATION ##
    # directories that need to be copied
    [String]$DIRECTORIES = @('Contacts','Desktop','Documents','Downloads','Favorites','Music','Pictures','Videos')

    # extraneous directories
    [String]$EXTRANEOUS_DIRS = @('AppData','.oracle_jre_usage','Links','Saved Games','Searches','Local Settings','Application Data','B')
    
    ###################

    # Call ROBOCOPY
    Start-Process -FilePath robocopy.exe -ArgumentList "$SourcePath $TargetPath /S /ETA /R:1 /W:3 /XX /XD $EXTRANEOUS_DIRS" -Wait -NoNewWindow

    # Finish copying
    Write-Host -ForegroundColor Green "Copy Complete"
}

Copy-LocalUserProfile