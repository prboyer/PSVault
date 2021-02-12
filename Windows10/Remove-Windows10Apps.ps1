function Remove-Windows10Apps {
<<<<<<< HEAD
    <#
    .SYNOPSIS
    Script for removing Windows 10 metro apps.
    
    .DESCRIPTION
    Provided an update version or a specific AppList name, the script will remove applications that prevent the system from being syspreped for imaging.
    
    .PARAMETER Version
    Integer parameter representing the feature version of the OS. Check "winver" for the version number.
    
    .PARAMETER AppListName
    String parameter representing the name of a specific AppList to remove from the system    
    
    .EXAMPLE
    Remove-Windows10Apps -Version 1909

    .EXAMPLE
    Remove-Windows10Apps -AppListName "AllApps"
    .NOTES
    Paul Boyer - Last updated 2-11-2021
    #>
    param (
        [Parameter()]
        [int]
        $Version,
        [Parameter()]
        [string]
        $AppListName
    )
    
    ## DEFINE APP LISTS ##
    # Define an app list for a specific version of Windows 10 to be processed

        # AllApps list is a compilation list of apps that have been removed from Windows 10 at some point 
        [String[]]$AllApps = @("3dviewer","alarms","bingfinance","bingnews","bingsports","bingweather","camera",
        "candycrushsodasaga","codewriter","commsphone","communications","desktopappinstaller","duolingo",
        "eclipse","farmville2countryescape","feedback","gethelp","getstarted","maps","messaging",
        "microsoftsolitairecollection","netflix","office","office.sway","officehub","oneconnect",
        "onenote","paint","pandora","people","photos","print3d","skype","skypeapp","solitaire",
        "solitairecollection","sound","soundrecorder","sticky","storepurchase","twitter","wallet",
        "windows.photos","windowsalarms","windowscamera","windowscommunicationsapps","windowsfeedbackhub",
        "windowsmaps","windowsphone","windowssoundrecorder","xbox","xboxapp","xboxonesmartglass","zune",
        "zunemusic","zunevideo");

        # App list for packages that need to be removed to sysprep Windows 10 version 1803
        [String[]]$1803 = @("3dviewer","alarms","bing","bingweather","camera","communications","duolingo","eclipse",
        "feedback","gethelp","getstarted","maps","messaging","microsoft.webmediaextensions","officehub",
        "oneconnect","onenote","paint","paint","people","photos","photoshop","print3d","skype","solitaire",
        "soundrecorder","speedtest","sway","wallet","weather","xbox","xbox.tcui","zune");
    
        # App list for packages that need to be removed to sysprep Windows 10 version 1809
        [String[]]$1809 = @("bingweather","bing","solitaire","oneconnect","people","skype","print3d","wallet","gethelp",
        "maps","getstarted","alarms","soundrecorder","camera","communications","feedback","photos","paint",
        "xbox.tcui","microsoft.webmediaextensions","messaging","xbox","paint","zune","3dviewer","duolingo",
        "eclipse","photoshop","sway","speedtest","weather","whiteboard","lens","todos",'gameoverlay', 'gamingoverlay', 'oneconnect', 'messaging', 'officehub');

        # App list for packages that need to be removed to sysprep Windows 10 version 1903
        [String[]]$1903 = @("feedback","solitaire","weather","soundrecorder","oneconnect","onenote","officehub",
        "getstarted","zune","messaging","mixedreality","skype");

        # App list for packages that need to be removed to sysprep Windows 10 version 1909
        [String[]]$1909 = @("feedback","solitaire","weather","soundrecorder","3dviewer","3dprint","gethelp",
        "print3d","oneconnect","mail","onenote","xbox","officehub","getstarted","zune","messaging",
        "mixedreality","skype");

    ######
    # Define the sub-routine to handle removing the apps given a specific app list
    function Process-AppRemoval {
    <#
    .SYNOPSIS
        Private helper function that takes in a AppList and then traverses the list and removes AppxPackages from the system
    .EXAMPLE
        Process-AppRemoval -AppList [String[]]$AppList
    .INPUTS
        Takes in a String[] for -AppList parameter
    .NOTES

    #>
        [CmdletBinding()]
        param (
            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [String[]]
            $AppList
        )
        
        # Generate a random number to assign to the ID of Write-Process
        [int]$processID = Get-Random

        for ([int]$i = 0; $i -lt $AppList.Count; $i++) {
            # Write out the progress of the removal operations
            Write-Progress -Activity "Remove Windows 10 Apps (Remove-Windows10Apps.ps1)" -Status $("Processing List: {0}" -f $(Get-Variable -Name AppList).Name) -CurrentOperation $("Removing {0}" -f $AppList[$i]) -PercentComplete $(($i / $AppList.Count)*100) -Id $processID 
            
            # Remove the app package from the system for all users
            try{
                Get-AppxPackage -AllUsers -Name "*$AppList[$i]*" | Remove-AppxPackage -AllUsers -Verbose -ErrorAction Continue
            }catch{
                Write-Error $("Unable to remove AppxPackage: {0} ; {1}" -f ($AppList[$i],$(Get-AppxPackage -Name "*$AppList[$i]*" -AllUsers))) 
            }
        }
    }
    #####

     # Self-elevate the script if required
     if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
            $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            #Exit
        }
    }

    # Check to see if the name of an AppList was specified
    if($AppListName -ne ""){
        # Call the sub-routine to process removal of apps on a given app list
        Process-AppRemoval -AppList $AppListName
    }

    # Otherwise enter the switch statement to run an AppList for a given version of Windows 10
    switch ($Version) {
        1803 {Process-AppRemoval -AppList $1803}
        1809 {Process-AppRemoval -AppList $1809}
        1903 {Process-AppRemoval -AppList $1903}
        1909 {Process-AppRemoval -AppList $1909}
        Default {Write-Error "No viable AppList found for: $Version."; break;}
=======
<#
.SYNOPSIS
Script for removing Windows 10 metro apps.

.DESCRIPTION
Provided a update version, the script will remove applications that prevent the system from being syspreped for imaging.

.PARAMETER Version
Integer parameter representing the feature version of the OS. Check "winver" for the version number.

.EXAMPLE
Remove-Windows10Apps -Version 1909

.NOTES
Paul Boyer - Last updated 2-11-2021
#>
    param (
        [Parameter(Mandatory=$true)]
        [int]
        $Version
    )
    
    if ($Version -eq 1803) {
        Write-Host "Remove Windows 10 1803 Apps" -ForegroundColor yellow -BackgroundColor black

        $applicationShortNames = @('BingWeather','Bing','GetHelp','GetStarted','Feedback','Messaging','Paint',
        '3DViewer','OfficeHub','OneNote','Solitaire','OneConnect','People','Skype','Print3D','Wallet','Alarms',
        'Maps','SoundRecorder','Camera','Communications','Photos','Paint','Xbox.TCUI','Microsoft.WebMediaExtensions',
        'Xbox','Zune','Duolingo',,'eclipse','photoshop','sway','speedtest','weather');

        foreach($app in $applicationShortNames){
            Write-Host "Removing " $app -foregroundcolor yellow

            try{
                $temp = Get-AppxPackage *$app* -allusers | Select-Object name
                Get-AppxPackage *$app* -allusers | Remove-AppxPackage 
                Write-Host $temp.Name " removed" -foregroundcolor green
            }
            catch{
                Write-Host "Application not removed" -foregroundcolor red
            }
        }
        Write-Host "Process Complete" -foregroundcolor green -backgroundcolor black
    }

    if($Version -eq 1809){
        Write-Host "Remove Windows 10 1809 Apps" -ForegroundColor yellow -BackgroundColor black

        $applicationShortNames =@('BingWeather','Bing','GetHelp','GetStarted','Feedback','Messaging',
        'Paint','3DViewer','OfficeHub','OneNote','Solitaire','OneConnect','People','Skype','Print3D',
        'Wallet','Alarms','Maps','SoundRecorder','Camera','Communications','Photos','Paint','Xbox.TCUI',
        'Microsoft.WebMediaExtensions','Xbox','Zune','Duolingo',,'eclipse','photoshop','sway','speedtest',
        'weather','whiteboard','lens','todos','remotedesktop');

        foreach($app in $applicationShortNames){
            
            Write-Host "Removing " $app -foregroundcolor yellow

            try{
                $temp = Get-AppxPackage *$app* -allusers | Select-Object name
                Get-AppxPackage *$app* -allusers | Remove-AppxPackage -ErrorAction SilentlyContinue
                Write-Host $temp.Name " removed" -foregroundcolor green
            }
            catch{
                Write-Host "Application not removed" -foregroundcolor red
            }
        }

        Write-Host "Processing Pesky 1809 Apps"

        $peskyApps_FullName = 'Microsoft.XboxGameOverlay_1.34.5003.0_x64__8wekyb3d8bbwe','Microsoft.XboxGamingOverlay_2.22.11001.0_x64__8wekyb3d8bbwe','Microsoft.OneConnect_5.1809.2571.0_x64__8wekyb3d8bbwe','Microsoft.Messaging_3.43.27001.0_x64__8wekyb3d8bbwe','Microsoft.MicrosoftOfficeHub_17.10314.31700.1000_x64__8wekyb3d8bbwe'

        $peskyApps_Short = 'gameoverlay','gamingoverlay','oneconnect','messaging','officehub'

        for($i=0; $i -ilt $peskyApps_Short.Length; $i++){
            Write-Host "Removing" $peskyApps_FullName[$i] "as" $peskyApps_Short[$i]
            Get-AppxPackage "*$peskyApps_Short[$i]*" | Remove-AppXPackage -AllUsers -ErrorAction Continue -Verbose
        }

        Write-Host "Process Complete" -foregroundcolor green -backgroundcolor black
    }

    if($Version -eq 1903){
        $applist = @('feedback','solitaire','oneconnect','onenote','officehub',
        'getstarted','zune','messaging','mixedreality','skype','weather','soundrecorder');

        # Traverse app list and remove
        foreach ($app in $applist){
            try{
                Write-Host "Removing $app from Image"
                Get-AppxPackage "*$app*" -AllUsers | Remove-AppxPackage -AllUsers
                Write-Host "$app removed!" -ForegroundColor Green
            }catch{
                Write-Host "$app not removed!" -ForegroundColor Red
            }
        }
    }

    if($Version -eq 1909){
        $applist = @('feedback','solitaire','oneconnect','onenote
        officehub','getstarted','zune','messaging','mixedreality',
        'skype','weather','soundrecorder','3dviewer','3dprint','gethelp','print3d','xbox','mail');

        # Traverse app list and remove
        foreach ($app in $applist){
            try{
                Write-Host "Removing $app from Image"
                Get-AppxPackage "*$app*" -AllUsers | Remove-AppxPackage -AllUsers
                Write-Host "$app removed!" -ForegroundColor Green
            }catch{
                Write-Host "$app not removed!" -ForegroundColor Red
            }

        }
>>>>>>> 6ad449ec6e191858f875ea97077bf58ff88c225b
    }

}