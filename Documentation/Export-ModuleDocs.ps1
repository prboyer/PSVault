function Export-ModuleDocs {
    <#
    .SYNOPSIS
    Script used for generating Markdown documentation for PowerShell files.

    .DESCRIPTION
    The script leverages the PlatyPS module to generate Markdown files for each PS1 file as well as for the whole module.
    The script also generates a relatively-pathed PSM1 file, and complimentary PSD1 file.

    .PARAMETER Path
    Path to the directory containing PowerShell (PS1) files to generate documentation for.

    .PARAMETER ModulePrefix
    String to be pre-fixed to the beginning of the generated PSM1,PSD1, and used in the ReadMe file.

    .PARAMETER ModuleDescription
    The description that should be used in the PSD1 file and ReadMe file for the Module.

    .PARAMETER ModuleDescriptionFile
    Path to a file containing the description that should be used in the PSD1 file and ReadMe file for the Module. Optionally, specify an empty string (""), and
    the script will attempt to use the "$Path\Description.txt" to get the Module description. This is helpful for keeping the same description in place when updating
    documentation through multiple revisions.

    .PARAMETER MarkdownFilesPath
    Path to the directory where Markdown files for each PS1 script should be stored. By default, the script will save the files to $Path\Docs

    .PARAMETER Exclude
    String array of paths to exclude when getting PowerShell (PS1) files to document.

    .PARAMETER NoClobber
    No not overwrite existing PSM1 and PSD1 files. A value must be supplied for -ModuleFilePath in order to user -NoClobber

    .PARAMETER ModuleFilePath
    Path to the existing module file. Script is expecting a PSM1 file.

    .PARAMETER NoModulePrefix
    Switch to exclude application of a module prefix to the beginning of the generated PSM1,PSD1, and used in the ReadMe file.

    .PARAMETER Version
    Specify a string to represent the revision of the help documentation. This will also be applied to the PSD1 manifest file.

    .EXAMPLE
    Export-ModuleDocs -Path ".\Windows10" -ModuleDescription "Windows 10 PowerShell Scripts"

    .EXAMPLE
    Export-ModuleDocs -Path ".\Windows10" -ModuleDescriptionFile ".\Windows10\Description.txt"

    .EXAMPLE
    Export-ModuleDocs -Path ".\Windows10" -ModuleDescription "Windows 10 PowerShell Scripts" -MarkdownFilesPath ".\Windows10\Markdown" -NoModulePrefix

    .EXAMPLE
    Export-ModuleDocs -Path ".\Windows10" -ModuleDescription "Windows 10 PowerShell Scripts" -NoCobber -ModuleFilePath ".\Windows10\Module.psm1" -NoModulePrefix

    .LINK
    https://github.com/PowerShell/platyPS

    .LINK
    https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/create-help-using-platyps?view=powershell-7.1

    .NOTES
        Author: Paul Boyer
        Date: 5-11-2021
    #>
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $Path,
        [Parameter(ParameterSetName="Module_Prefix")]
        [String]
        $ModulePrefix,
        [Parameter(Mandatory=$true,ParameterSetName="Description_String")]
        [string]
        $ModuleDescription,
        [Parameter(Mandatory=$false,ParameterSetName="Description_File")]
        [AllowEmptyString()]
        [string]
        $ModuleDescriptionFile,
        [Parameter(Mandatory=$true,ParameterSetName="MarkdownFiles_Path")]
        [ValidateScript({if(Test-Path -Path $_ -PathType Container -IsValid){return $true}else{$false}})]
        [String]
        $MarkdownFilesPath,
        [Parameter()]
        [String[]]
        $Exclude,
        [Parameter(ParameterSetName="NoClobber")]
        [switch]
        $NoClobber,
        [Parameter(Mandatory=$true,ParameterSetName="NoClobber")]
        [ValidateNotNullOrEmpty()]
        [String]
        $ModuleFilePath,
        [Parameter(ParameterSetName="Module_NoPrefix")]
        [switch]
        $NoModulePrefix,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Version,
        [Parameter()]
        [Switch]
        $Prune
    )
    <# Import Dependencies #>
        # Import platyPS module required for generating the markdown documentation
        Import-Module -Name platyPS

    <# Get all the PS1 files in the current directory and recurse into sub-directories #>
        $PSFiles = Get-ChildItem -Path $Path -Filter "*.ps1" -Recurse -Exclude $Exclude

    <# Check for existing PSM1 & PSD1 module files #>
        # Declare variable for $ModuleFile
        $script:ModuleFile="";

        # NoClobber switch will prevent existing module files from being overwritten
        if (-not $NoClobber) {
            # Check if there are already existing module files, if so remove them
            try{
                if(Test-Path -Path $($Path+"\"+$(split-path -path $(split-path -path $($Path) -parent) -leaf)+"-"+$(Split-Path -Path $Path -Leaf)+".*")){
                    Remove-Item -Path $($Path+"\"+$(split-path -path $(split-path -path $($Path) -parent) -leaf)+"-"+$(Split-Path -Path $Path -Leaf)+".*")
                }
            }catch [System.Management.Automation.ParameterBindingException]{
                Write-Warning -Message $("Unable to Split-Path. Likely because script was called from within working directory.`n`t{0}" -f $Error[0])
            }

            <# Generate a PSM1 file on the fly for use with PlatyPS #>
                # Determine the prefix to use when generating module files
                [String]$Prefix = $(split-path -path $(split-path -path $($Path) -parent) -leaf)+"-"
                if ($ModulePrefix -ne "") {
                    $Prefix = $ModulePrefix;
                }elseif ($NoModulePrefix) {
                    $Prefix = "";
                }

                # Assign the value of $ModuleFile
                $ModuleFile = $Path+"\"+$Prefix+$(Split-Path -Path $Path -Leaf)+".psm1"

                # Dot source all the PS1 files in a PSM1 module file
                $PSFiles | ForEach-Object {
                    [String]$(". `""+$(Resolve-Path -Path $_.FullName -Relative)+"`"") | Out-File -FilePath $ModuleFile -Force -Append
                }
        }else{
            # When -NoClobber and -ModuleFilePath are specified, no additional work needed. Just assigning values
            $ModuleFile = (Resolve-Path -Path $ModuleFilePath).Path
        }

        # Transition $ModuleFile from being a String to a File Object
        try{
            $ModuleFile = Get-Item -Path $($Path+"\"+$Prefix+$(Split-Path -Path $Path -Leaf)+".psm1")
        }catch{
            Write-Error -Message $("Module file not found.`n`t{0}" -f $($Path+"\"+$Prefix+$(Split-Path -Path $Path -Leaf)+".psm1"))
        }

        # Import the module file
        Import-Module -Name $ModuleFile -DisableNameChecking -Force

    <# Generate metadata for the PSM1 file to include in an associated PSD1 manifest file #>
        # Generate a new GUID for the module. This will be included on the README.md as well as each individual file
        $moduleGUID = New-Guid

        <# Determine how to set the module description.
        Either set the description from a pre-determined source (cmdline parameter, or file input), or prompt for interactive input #>

        # Only process if -NoClobber is not passed
        if (-not $NoClobber) {

            # Variable that holds the description that will be assigned to the module.
            [String]$Description = "";

            # If a module description is not passed in a file, but as a string on the command line, then proceed with assigning that value to $Description
            if ($ModuleDescription -ne "") {
                if($ModuleDescription -ne ""){
                    $Description = $ModuleDescription
                }else{
                    # Otherwise if there is no description passed at function-call, then prompt for it interactively.
                    $Description = Read-Host -Prompt "Enter message to user for Module Description"
                }
            }else{
                # If the -ModuleDescriptionFile parameter is passed, but with no Path, try to get the content of the default 'Description.txt' file and assign it to $Description
                if ($ModuleDescriptionFile -eq "" -and (Test-Path -Path "$Path\Description.txt")) {
                    try{
                        $ModuleDescriptionFile = "$Path\Description.txt"
                        $Description = Get-Content $ModuleDescriptionFile
                    }catch{
                        # If the content of the file cannot be read, then prompt the user to enter a description interactively
                        Write-Warning $("Unable to get description text from file {0}" -f $ModuleDescriptionFile) -WarningAction Continue
                        $Description = Read-Host -Prompt "Enter message to user for Module Description"
                    }
                }else{
                    # If a module description is passed as a file, try to get the content of the file and assign it to $Description
                    try{
                        $Description = Get-Content $ModuleDescriptionFile
                    }catch{
                        # If the content of the file cannot be read, then prompt the user to enter a description interactively
                        Write-Warning $("Unable to get description text from file {0}" -f $ModuleDescriptionFile) -WarningAction Continue
                        $Description = Read-Host -Prompt "Enter message to user for Module Description"
                    }
                }
            }
        }
    <# Generate the PSD1 manifest file #>
        # Splat the manifest parameters
        $Manifest_Parameters= @{
            Path = $($Path+"\"+$ModuleFile.BaseName+".psd1")
            Author = "Paul R Boyer"
            FileList = $PSFiles
            Guid = $moduleGUID.Guid
            ProcessorArchitecture = "Amd64"
            ProjectUri = "https://www.github.com/prboyer/psvault"
            RootModule = $ModuleFile.BaseName
            Description = $Description
        }

        # Skip generating a new manifest if -NoClobber is passed
        if(-not $NoClobber){
            # Generate the manifest file itself
            New-ModuleManifest @Manifest_Parameters
        }

    <# Create folder for individual MD files #>
        # Variable to store the path where individual MD files should be stored
        [String]$MDFilesDir = "";

        # If a specific folder is specified by the $MarkdownFilesPath parameter, make sure the directory exists
        if ($MarkdownFilesPath -ne "") {
            if (-not (Test-Path -Path $MarkdownFilesPath)) {
                New-Item -Path $(Split-Path -Path $MarkdownFilesPath -Parent) -Name $(Split-Path -Path $MarkdownFilesPath -Leaf) -ItemType Directory -Force | Out-Null
                $MDFilesDir = $MarkdownFilesPath
            }else{
                $MDFilesDir = $MarkdownFilesPath
            }
        }else{
            # Otherwise, if no specific folder is specified, use a "Docs" folder in the $Path directory
            if(-not (Test-Path -Path "$Path\Docs")){
                New-Item -Path $Path -Name "Docs" -ItemType Directory -Force | Out-Null
                $MDFilesDir = "$Path\Docs"
            }else{
                $MDFilesDir = "$Path\Docs"
            }
        }

    <# Generate platyPS markdown for each script #>
        # Splatting parameters
        $MarkdownHelp_Parameters= @{
            Module = $ModuleFile.BaseName
            FwLink = "https://github.com/prboyer/PSVault"
            Metadata = @{Author = "Paul Boyer"; 'Module Guid'= $moduleGUID.Guid;}
            Locale = "en-US"
            ExcludeDontShow = $true
            HelpVersion = $Version
            OutputFolder = $MDFilesDir
            Force = $true
            WithModulePage = $true
            ModulePagePath ="$Path\README.md"
        }

        # Generate the individual help files
        New-MarkdownHelp @MarkdownHelp_Parameters | Out-Null

    <# Customize each individual MD file with edits/information not generated by PlatyPS #>

        <# Update the online version for each file. Sets the value to null #>
        Get-ChildItem -Path $MDFilesDir -Filter "*.md" -File | ForEach-Object{
            Set-Content -Path $_.FullName -Value $(Get-Content $_.FullName | ForEach-Object{
                if($_ -match "online version:"){
                    $_.Substring(0,$_.IndexOf(':')+1)
                }else{
                    $_
                }
            })
        }

        <# Update the external help version for each file. Sets the value to null #>
        Get-ChildItem -Path $MarkdownFilesPath -Filter "*.md" -File | ForEach-Object{
            Set-Content -Path $_.FullName -Value $(Get-Content $_.FullName | ForEach-Object{
                if($_ -match "external help file:"){
                    $_.Substring(0,$_.IndexOf(':')+1)
                }else{
                    $_
                }
            })
        }

    <# Generate the module README file. This is a summary page that has a short description and link to each individual MD file #>
        Update-MarkdownHelpModule -ModulePagePath "$Path\README.md" -Path $(Resolve-Path -Path $MDFilesDir -Relative) -RefreshModulePage -Force| Out-Null

    <# Customize the README.md file with edits/information not generated by PlatyPS #>

        <# Change the pathing of the README.md file to support putting individual script documentation in another directory #>
            Set-Content -Path "$Path\README.md" -Value $(get-content -path "$Path\README.md" | ForEach-Object{
                if($_ -match "###"){
                    $_.ToString().Insert($_.ToString().IndexOf('(')+1,$(Resolve-Path -Path $MDFilesDir -Relative | Split-Path -Leaf).ToString()+"/")
                }else{
                    $_
                }
            })

        <# Update the description in the markdown readme file to match the description in the PSD1 file #>
            Set-Content -Path "$Path\README.md" -Value $(Get-Content -path "$Path\README.md" | ForEach-Object{
                if($_ -match "{{ Fill in the Description }}"){
                    $_.ToString().Replace("{{ Fill in the Description }}",$Description)
                }else{
                    $_
                }
            })

        <# Manually update the guid on the readme file #>
            $(Get-Content -Path "$Path\README.md").Replace("00000000-0000-0000-0000-000000000000",$moduleGUID.Guid) | Set-Content -Path "$Path\README.md";

    <# Prune functionality for getting rid of extra information on README.md files when they don't process properly #>
        if ($Prune) {
            # Delete the un-necessary individual MD files
            $WorkingFolderFiles = Get-ChildItem -Path $Path -File -Filter "*.ps1"
            Get-ChildItem -Path $MDFilesDir | Where-Object{$_.BaseName -notin $WorkingFolderFiles.BaseName} | Remove-Item -Force

            <# Prune the README.MD file #>
                # Prune out the headers that are unnecessary
                    $Content = Get-Content -Path "$Path\README.md"

                    $X = $Content | ForEach-Object{
                        # Grab headers starting with ###
                        if ($_ -like "###*") {
                            $Files = (Get-ChildItem -Path $Path -File -Filter "*.ps1")
                            if($_.TrimStart("# [").Substring(0,$_.TrimStart("# [").IndexOf(']')) -in $Files.BaseName){
                                    $_
                            }

                        }else{
                            $_
                        }
                    }

                    # Get rid of empty lines
                    $X = $X | Where-Object {$_ -ne ""}

                    # Write out filtered content to the README.md file
                    $X | Set-Content -Path "$Path\Readme.md"

            <# Prune the "{{ Fill in the Synopsis }} lines "#>
            Set-Content -Path "$Path\Readme.md" -Value $($(Get-Content "$Path\README.md") -replace "{{ Fill in the Synopsis }}","" | Where-Object {$_ -ne "" } )

        }

}