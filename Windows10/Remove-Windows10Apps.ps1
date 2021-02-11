function Remove-Windows10Apps {
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
    }

}