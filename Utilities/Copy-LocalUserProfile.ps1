function Copy-LocalUserProfile {
<#
.SYNOPSIS
A custom cmdlet for quickly copying the contents of a user's profile to another location using ROBOCOPY. 

.DESCRIPTION
Long description

.PARAMETER SourcePath
Parameter description

.PARAMETER TargetPath
Parameter description

.PARAMETER LogFile
Parameter description

.PARAMETER WaitDelay
Parameter description

.PARAMETER NoRetry
Parameter description

.PARAMETER RobocopyArguments
Parameter description

.PARAMETER ExcludeDirs
Parameter description

.PARAMETER ExcludeFiles
Parameter description

.EXAMPLE
An example

.NOTES
Paul Boyer, 11-17-2020

#>
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $SourcePath,
        [Parameter (Mandatory = $true)]
        [String]
        $TargetPath,
        [String]
        $LogFile,
        [Int]
        $WaitDelay,
        [Switch]
        $NoRetry,
        [String]
        $RobocopyArguments,
        [String[]]
        $ExcludeDirs,
        [String[]]
        $ExcludeFiles
    )

    ## DIRECTORY & FILE FILTERING ##

    # directories that need to be copied
    #[String[]]$DIRECTORIES = ('Contacts','Desktop','Documents','Downloads','Favorites','Music','Pictures','Videos') # This is currently not implemented

    # hard-coded extraneous directories that will never be included
    [String[]]$EXTRANEOUS_DIRS = ('App Data','AppData','.oracle_jre_usage','Links','Saved Games','Searches','Local Settings','Application Data','OneDrive','Box','Box Sync','Dropbox','iCloud Drive')

    # hard-coded extraneous file types that will never be included
    [String[]]$EXTRANEOUS_FILES = ('.dat')
    
    ###################
    # Build some ArrayLists 
    [System.Collections.ArrayList]$extraDirs = [System.Collections.ArrayList]::new();
    [System.Collections.ArrayList]$extraFiles = [System.Collections.ArrayList]::new();

    # Convert the primative Arrays into ArrayLists & add in extra elements from function call
    $EXTRANEOUS_DIRS | %{$extraDirs.Add($_) | Out-Null}
    $EXTRANEOUS_FILES | %{$extraFiles.Add($_) | Out-Null}

    # Add in extra elements from runtime
    $ExcludeDirs | %{$extraDirs.Add($_) | Out-Null}
    $ExcludeFiles | %{$extraFiles.Add($_) | Out-Null}

    # Format for ROBOCOPY
    $X_DIRS = $extraDirs -join ","
    $X_FILES = $extraFiles -join ","
    ################

    ### ROBOCOPY Setup ###
    # Default number of times to retry
    [Int]$ROBO_Retry = 1;

        # If specified not to retry, set variable to 0
        if ($NoRetry) {
            $ROBO_Retry = 0;
        }    

    # Default number of seconds to wait
    [Int]$ROBO_Wait = 3;

        # Pass in argument specified at run time if there is one. Otherwise, use the default.
        if($WaitDelay -ne $null){
            $ROBO_Wait = $WaitDelay
        }
    
    # Standard argument list for Robocopy
    [String]$ROBO_ArgumentList = "$SourcePath $TargetPath /S /ETA /R:$ROBO_Retry /W:$ROBO_Wait /XX /XD $X_DIRS /XF $X_FILES "

    # Add in the additional parameters from command line
    if ($RobocopyArguments -ne "") {
        $ROBO_ArgumentList = $ROBO_ArgumentList.Insert($ROBO_ArgumentList.Length,$RobocopyArguments);
    }

    # Append the parameter to output to the log file
    if ($LogFile -ne "" -and $LogFile -ne $null){
        $ROBO_ArgumentList = $ROBO_ArgumentList.Insert($ROBO_ArgumentList.Length," /TEE /LOG:$LogFile");
    }

    # Call ROBOCOPY
    Start-Process -FilePath robocopy.exe -ArgumentList $ROBO_ArgumentList -Wait -NoNewWindow

    # Finish copying
    Write-Host -ForegroundColor Green "Copy Complete"
}