function PSRobocopy {
<#
.SYNOPSIS
 PowerShell implementation of Robocopy.exe
.DESCRIPTION
Long description

.PARAMETER Source
Parameter description

.PARAMETER Target
Parameter description

.PARAMETER Username
Parameter description

.PARAMETER Password
Parameter description

.EXAMPLE
An example

.NOTES
 Written by Paul B, 9-13-19 
#>
    param (
        [string]$Source,
        [string]$Target,
        [string]$Username,
        [securestring]$Password
    )

    # Get path of source 
    if ($Source -eq "") {
        $Source = Read-Host -Prompt "Enter path to source"
    }
    
    # Get path of target
    if ($Target -eq "") {
        Write-Host "Enter the path of the target directory. `n -For personal folders (U:\ drive) start your path with `'Users\`' `n -For project folders start your path with `'Project\`'"
        $Target = Read-Host -Prompt "Enter path to target (relative to \\sscwin\dfsroot)"
    }

    # Get username
    if ($Username -eq "") {
        $Username = Read-Host -Prompt "Enter username"
    }

    # Get password
    if ($Password -eq $null) {
         # Prompt for user to enter their password securely   
        $Password = Read-Host -Prompt "Enter Password" -AsSecureString
    }

    # Check that the source exists, if not then throw error
    if (Test-Path $Source){
        
        # Check Credentials
        #add domain prefix to username if not suppplied
        if(-not ($Username.Contains("primo") -or $Username.Contains("PRIMO"))){
            $Username = "PRIMO\$Username";
        }

        #create PS credential object
        $PSCred = New-Object pscredential $Username, $Password

        Write-Host "Authenticating to SSCC server as $Username"
        
        # append domain prefis to target
        if(-not ($Target.Contains("\\sscwin.ads.ssc.wisc.edu\dfsroot\"))){
            $Target = "\\sscwin.ads.ssc.wisc.edu\dfsroot\$Target"
        }

        Write-Host "Connecting to $Target"

        # Connect to target location
        New-PSDrive -Name "W" -PSProvider FileSystem -Root $Target -Description "SSCC Network Storage" -Credential $PSCred

        Start-Sleep -Seconds 10

        if(Test-Path $Target){
            # Perform Robocopy
            Robocopy.exe $Source $Target /e /z /copy:dato /xo /im /eta /ts 

            Write-Host "Process Complete!" -ForegroundColor Green
        }else{
            Write-Error -Message "Cannot find target"
        }
    }
    else{
        Write-Error -Message "Cannot find source"
    } 
}
Write-Host "Backup directory to SSCC network file share" -ForegroundColor Cyan
#############################################################################
# DO NOT MODIFY ANYTHING ABOVE THIS LINE! Unless you know what you're doing
#############################################################################
# To Automate this script:
#   * Provide the file path to your source files for the $Source variable
#   * Provide the file path to your target for the $Target variable
#   * Enter your SSCC username for the $Username variable
#
# If you follow the above instructions, you will simply need to enter your
# SSCC password when this script is run from the command line (PowerShell Session).
################
# Edit these variables
##############
$Source =""
$Target =""
$Username =""
######################
# Line that calls the backup function 
PSRobocopy -Source $Source -Target $Target -Username $Username