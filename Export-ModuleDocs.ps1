function Export-ModuleDocs {
    param (
        [String]
        $Path,
        [switch]
        $IncludeIO,
        [string]
        $ModuleDescription,
        [string]
        $ModuleDescriptionFile,
        [Parameter()]
        [ValidateScript({if(Test-Path -Path $_ -PathType Container){return $true}else{$false}})]
        [String]
        $MDFilesPath
    )
    <# Import Dependencies #>
        # Import platyPS module required for generating the markdown documentation
        Import-Module -Name platyPS

    <# Generate a PSM1 file on the fly for use with PlatyPS #>
        # Get all the PS1 files in the current directory and recurse into sub-directories
        $files = Get-ChildItem -Path $Path -Filter "*.ps1" -Recurse

        # Dot source all the PS1 files in a PSM1 module file
        $files | ForEach-Object{
            [String]$(". `""+$(Resolve-Path -Path $_.FullName -Relative)+"`"") | Out-File -FilePath "$Path\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force
        }

        # Import the module file
        $moduleFile = Get-ChildItem -Path $Path -Filter "*.psm1"
        Import-Module -Name $($Path+"\"+$moduleFile.BaseName) -DisableNameChecking
    
    <# Generate metadata for the PSM1 file to include in an associated PSD1 manifest file #>
        # Generate a new GUID for the module. This will be included on the README.md as well as each individual file
        $moduleGUID = New-Guid   

        <# Determine how to set the module description. 
            Either set the description from a pre-determined source (cmdline parameter, or file input), or prompt for interactive input #>
        
        # Variable that holds the description that will be assigned to the module.
        [String]$Description = "";
        
        # If a module description is passed as a file, try to get the content of the file and assign it to $Description
        if(($ModuleDescriptionFile -ne "") -and ($ModuleDescription -eq "")){
            try{
                $Description = Get-Content $ModuleDescriptionFile
            }catch{
                # If the content of the file cannot be read, then prompt the user to enter a description interactively
                Write-Warning $("Unable to get description text from file {0}" -f $ModuleDescriptionFile) -WarningAction Continue
                $Description = Read-Host -Prompt "Enter message to user for Module Description"
            }  
        # If a module description is not passed in a file, but as a string on the command line, then proceed with assigning that value to $Description
        }else{
            if($ModuleDescription -ne ""){
                $Description = $ModuleDescription
            }else{
                # Otherwise if there is no description passed at function-call, then prompt for it interactively.
                $Description = Read-Host -Prompt "Enter message to user for Module Description"
            }
        }

    <# Generate the PSD1 manifest file #>
        # Splat the manifest parameters 
        $manifestParameters= @{
            Path = $($Path+"\"+$moduleFile.BaseName+".psd1")
            Author = "Paul R Boyer"
            FileList = $files
            Guid = $moduleGUID.Guid
            ProcessorArchitecture = "Amd64"
            ProjectUri = "https://www.github.com/prboyer/psvault"
            RootModule = $moduleFile
            Description = $Description
        }

        # Generate the manifest file itself
        New-ModuleManifest @manifestParameters
    
    <# Create folder for individual MD files #>
        # Varible to store the path where individual MD files should be stored
        [String]$MDFilesDir = "";

        # If a specific folder is specified by the $MDFilesPath parameter, make sure the directory exists
        if ($MDFilesPath -ne "") {
            if (-not (Test-Path -Path $(Resolve-Path $MDFilesPath))) {
                New-Item -Path $(Split-Path -Path $MDFilesPath -Parent) -Name $(Split-Path -Path $MDFilesPath -Leaf) -ItemType Directory -Force
                $MDFilesDir
            }
        }else{
            # Otherwise, if no specific folder is specified, use a "Docs" folder in the $Path directory
            if(-not (Test-Path -Path "$Path\Docs")){
                New-Item -Path $Path -Name "Docs" -ItemType Directory -Force
            }
        }



   

    # Generate platyPS markdown for each script
    $parameters= @{
        Module = $moduleFile.BaseName
        FwLink = "https://github.com/prboyer/PSVault"
        Metadata = @{Author = "Paul Boyer"; 'Module Guid'= $moduleGUID.Guid;}
        Locale = "en-US"
        ExcludeDontShow = $true
        HelpVersion = "1.0.1"
        OutputFolder = "$Path\Docs\"
        Force = $true
        WithModulePage = $true
        ModulePagePath ="$Path\README.md"
    }

    # generate the individual help files
    New-MarkdownHelp @parameters | Out-Null

    # update the online version for each file. Sets the value to null
    Get-ChildItem -Path "$Path\Docs\" -Filter "*.md" -File | ForEach-Object{
        Set-Content -Path $_.FullName -Value $(Get-Content $_.FullName | ForEach-Object{
            if($_ -match "online version:"){
                $_.Substring(0,$_.IndexOf(':')+1)
            }else{
                $_
            }
        })
    }

    # generate the module readme file
    Update-MarkdownHelpModule -ModulePagePath "$Path\README.md" -Path "$Path\Docs" -RefreshModulePage -Force| Out-Null

    # change the pathing of the README.md file to support putting individual script documentation in another directory
    Set-Content -Path "$Path\README.md" -Value $(get-content -path "$Path\README.md" | ForEach-Object{
        if($_ -match "###"){
            $_.ToString().Replace($_,$_.ToString().Insert($_.ToString().IndexOf('(')+1,"Docs/"))
        }else{
            $_
        }
    })
    
    # remove the Input / Output headings from each file
    # if(-not $IncludeIO){
    #     Get-ChildItem -Path $Path -Filter "*.md" -Exclude "README.md" -Recurse | %{
    #         $content = Get-Content -Path $_.FullName ;
    #         $content = $content.Replace("## INPUTS","");
    #         $content = $content.Replace("## OUTPUTS","");
    #         Set-Content -Path $_.FullName -Value $content -Force;
    #     }
    # }

    # update the external help version for each file. Sets the value to null
    Get-ChildItem -Path "$Path\Docs\" -Filter "*.md" -File | ForEach-Object{
        Set-Content -Path $_.FullName -Value $(Get-Content $_.FullName | ForEach-Object{
            if($_ -match "external help file:"){
                $_.Substring(0,$_.IndexOf(':')+1)
            }else{
                $_
            }
        })
    }

    # update the description in the markdown readme file to match the description in the PSD1 file
    $(Get-Content -Path "$Path\README.md").Replace("{{ Fill in the Description }}",$Description) | Set-Content -Path "$Path\README.md"; 


    # manually update the guid on the readme file
    $(Get-Content -Path "$Path\README.md").Replace("00000000-0000-0000-0000-000000000000",$moduleGUID.Guid) | Set-Content -Path "$Path\README.md";

}

Export-ModuleDocs -Path .\Windows10 -ModuleDescription "This is the description of the module"