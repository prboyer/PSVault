# Installs the Win10_1903 update silently from a source file passed at runtime
# more information on Setup.exe here: https://blogs.technet.microsoft.com/home_is_where_i_lay_my_head/2015/09/14/windows-10-setup-command-line-switches/

#PARAMETERS
param (
    # This should be the path to the setup.exe of the Windows offline update
    $SetupFile,

    # This should be the path to the post upgrade installation cmd
    $PostOOBE
);

# See if installation files were already extracted to C: .. if so then delete them
if(Test-Path "$env:SystemDrive\$WINDOWS.~BT"){
	Remove-Item -Recurse -Force "$env:SystemDrive\$WINDOWS.~BT"
}

# Set the execution policy
try{
Set-ExecutionPolicy -ExecutionPolicy bypass -Scope CurrentUser -Force -ErrorAction SilentlyContinue
}catch{
    Write-Host "Could not change execution policy" -ForegroundColor Red
}

if($SetupFile -ne $null){
    # Run the upgrade
    if($PostOOBE -ne $null){
        & $SetupFile --% /auto upgrade /DynamicUpdate Enable /MigrateDrivers all /ShowOOBE none /Telemetry disable /BitLocker TryKeepActive /Compat IgnoreWarning /PostOOBE $PostOOBE
    }else{
        & $SetupFile --% /auto upgrade /DynamicUpdate Enable /MigrateDrivers all /ShowOOBE none /Telemetry disable /BitLocker TryKeepActive /Compat IgnoreWarning
    }
}else{
    Write-Error "No setup.exe file specified."
}
