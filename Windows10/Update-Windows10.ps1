function Update-Windows10 {
<#
.SYNOPSIS
Script that facilitates an online (running OS) upgrade of Windows 10 given a setup file from an expanded ISO

.DESCRIPTION
After extracting the contents of an ISO of a new version of Windows 10, this script can utilize the setup.exe file to perform
and upgrade to an online (running) system. 

.PARAMETER SetupFile
Path to the "Setup.exe" file extracted from the ISO. 

.PARAMETER LogDir
Path to a directory where logs from the upgrade process should be copied.

.PARAMETER ScanCompat
Switch to scan for current machine's compatibility with the upgrade. Provides a report of any incompatibilities. This does not perform the upgrade.

.PARAMETER NoDynamicUpdate
Switch to disable Dynamic Update functionality during the upgrade process. By default, new updates will be installed at upgrade time.

.PARAMETER AnswerFile
To use an AnswerFile and perform the update in unattended mode, supply the path to the XML answer file.

.PARAMETER ConfigFile
To use a configuration file, provide the path to the INI config file. Settings in the config file will override those specified in the command line

.PARAMETER Quiet
Switch parameter to perform the upgrade silently without user interaction.

.PARAMETER BitLocker
String parameter as to how the upgrade should handle machines protected by BitLocker. By default, the upgrade will try to keep BitLocker active.

.EXAMPLE
Update-Windows10 -SetupFile "D:\Setup.exe" -ScanCompat

.EXAMPLE
Update-Windows10 -SetupFile "D:\Setup.exe"

.EXAMPLE
Update-Windows10 -SetupFile "D:\Setup.exe" -Quiet -LogDir "\\fs1\share\Logs\Update" 

.EXAMPLE
Update-Windows10 -SetupFile "D:\Setup.exe" -NoDynamicUpdate -ConfigFile "\\fs1\share\UpdateConfig.ini" -BitLocker "ForceKeepActive" -Quiet

.LINK
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options

.NOTES
Paul Boyer - 2-11-2021
#>    
    [CmdletBinding()]
    param (
        [Parameter (ParameterSetName='ConfigFile',Mandatory=$true)]
        [Parameter (ParameterSetName='AnswerFile', Mandatory=$true)]
        [Parameter (ParameterSetName='ScanCompat', Mandatory=$true)]
        [Parameter (ParameterSetName='Update',  Mandatory=$true)]
        [Parameter(Mandatory=$true)]
        [String]
        $SetupFile,

        [Parameter (ParameterSetName='ConfigFile')]
        [Parameter (ParameterSetName='AnswerFile')]
        [Parameter (ParameterSetName='Update')]
        [Parameter (ParameterSetName='ScanCompat', Mandatory=$false)]
        [String]
        $LogDir,

        [Parameter (ParameterSetName='ScanCompat', Mandatory=$true)]
        [switch]
        $ScanCompat,

        [Parameter (ParameterSetName='ConfigFile')]
        [Parameter (ParameterSetName='AnswerFile')]
        [Parameter (ParameterSetName='Update')]
        [switch]
        $NoDynamicUpdate,

        [Parameter (ParameterSetName='AnswerFile',Mandatory=$true)]
        [Parameter (ParameterSetName='Update')]
        [String]
        $AnswerFile,

        [Parameter (ParameterSetName='ConfigFile',Mandatory=$true)]
        [Parameter (ParameterSetName='Update')]
        [String]
        $ConfigFile,
        
        [Parameter (ParameterSetName='AnswerFile')]
        [Parameter (ParameterSetName='ConfigFile')]
        [Parameter (ParameterSetName='Update')]
        [Parameter (ParameterSetName='ScanCompat', Mandatory=$false)]
        [switch]
        $Quiet,

        [Parameter (ParameterSetName='AnswerFile')]
        [Parameter (ParameterSetName='ConfigFile')]
        [Parameter (ParameterSetName='Update')]
        [ValidateSet("AlwaysSuspend","TryKeepActive","ForceKeepActive")]
        [string]
        $BitLocker



    )

    # See if installation files were already extracted to C:\ .. if so then delete them
    if(Test-Path "$env:SystemDrive\$WINDOWS.~BT"){
        Remove-Item -Recurse -Force "$env:SystemDrive\$WINDOWS.~BT"
    }

    # Set the execution policy
    try{
        Set-ExecutionPolicy -ExecutionPolicy bypass -Force -ErrorAction SilentlyContinue
    }catch{
        Write-Host "Could not change execution policy" -ForegroundColor Red
        Get-ExecutionPolicy -List
    }

    ## Handle scanning for compatibility 
        if($ScanCompat -and $Quiet -and ($LogDir -ne "")){
            # If scan for compatibility, quiet and logging are specified 
            Start-Process -FilePath $SetupFile -ArgumentList "/auto upgrade /Compat ScanOnly /Quiet /CopyLogs $LogDir" -Wait
        }elseif($ScanCompat -and $Quiet){
            # If scan for compatibility, and quiet are specified
            Start-Process -FilePath $SetupFile -ArgumentList "/auto upgrade /Compat ScanOnly /Quiet" -Wait
        }elseif($ScanCompat -and ($LogDir -ne "")){
            # If scan for compatibility and logging are specified
            Start-Process -FilePath $SetupFile -ArgumentList "/auto upgrade /Compat ScanOnly /CopyLogs $LogDir" -Wait
        }elseif($ScanCompat){
            # If only scanning for compatibility is specified
            Start-Process -FilePath $SetupFile -ArgumentList "/auto upgrade /Compat ScanOnly" -Wait
        }

    ##
    
    # The standard (default) list of arguments that will always be called with the update
    [String]$STANDARD_ARGS = "/auto upgrade /MigrateDrivers all /ShowOOBE none /Telemetry disable /Compat IgnoreWarning ";
    
    # Working list of additional arguments to be concatenated with the standard arguments
    [String]$arguments += $STANDARD_ARGS;

    # DynamicUpdate control
    if($NoDynamicUpdate){
        $arguments += "/DynamicUpdate Disable "
    }else{
        $arguments += "/DynamicUpdate Enable "
    }

    # Bitlocker Control
    if ($Bitlocker -eq "") {
        $arguments += "/BitLocker:TryKeepActive "
    }else {
        $arguments += "/BitLocker:$BitLocker "
    }

    # Silent Control
    if($Quiet){
        $arguments += "/Quiet "
    }

    # AnswerFile Control
    ## Check that the answer file param isn't empty, the file path exists, and that it is an XML file
    if($AnswerFile -ne ""){
        if((Test-Path -Path $AnswerFile) -and ([IO.Path]::GetExtension($AnswerFile) -eq ".xml")){
            $arguments += "/Unattend:$AnswerFile "    
        }else{
            Write-Error $("Cannot apply /Unattend switch. `n`tAnswer File exists: {0} `n`tAnswer File correct format: {1}" -f ($(Test-Path -Path $AnswerFile),$([IO.Path]::GetExtension($AnswerFile) -eq ".xml")))
        }
    }
    
    # ConfigFile Control
    ## Check that the config file param isn't empty, the file path exists, and that it is an ini file
    if($ConfigFile -ne ""){
        if((Test-Path -Path $ConfigFile) -and ([IO.Path]::GetExtension($ConfigFile) -eq ".ini")){
            $arguments += "/ConfigFile:$ConfigFile "    
        }else{
            Write-Error $("Cannot apply /ConfigFile switch. `n`tConfig File exists: {0} `n`tConfig File correct format: {1}" -f ($(Test-Path -Path $ConfigFile),$([IO.Path]::GetExtension($ConfigFile) -eq ".ini")))
        }
    }

    # Logging Control
    if ($LogDir -ne "") {
        $arguments += "/LogDir:$LogDir "
    }

    ## Run the upgrade
    # First check if the setup file exists and is the right extension type
    if ((Test-Path $SetupFile) -and ([IO.Path]::GetExtension($SetupFile) -eq ".exe")) {
        Start-Process -FilePath $SetupFile -ArgumentList $arguments -Wait
    }else{
        Write-Error $("Could not start the upgrade. `n`tArguments: {0} `n`tSetup File Test-Path: {1} `n`tSetup File Test-Extension: {2}" -f ($arguments,$(Test-Path $SetupFile),$([IO.Path]::GetExtension($SetupFile) -eq ".exe")))
    }

}