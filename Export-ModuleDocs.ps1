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
        [ValidateScript({if(Test-Path -Path $_ -PathType Container -IsValid){return $true}else{$false}})]
        [String]
        $MDFilesPath,
        [String[]]
        $Exclude
    )
    <# Import Dependencies #>
        # Import platyPS module required for generating the markdown documentation
        Import-Module -Name platyPS

    <# Generate a PSM1 file on the fly for use with PlatyPS #>
        # Get all the PS1 files in the current directory and recurse into sub-directories
        $files = Get-ChildItem -Path $Path -Filter "*.ps1" -Recurse -Exclude $Exclude

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
        $Manifest_Parameters= @{
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
        New-ModuleManifest @Manifest_Parameters
    
    <# Create folder for individual MD files #>
        # Variable to store the path where individual MD files should be stored
        [String]$MDFilesDir = "";

        # If a specific folder is specified by the $MDFilesPath parameter, make sure the directory exists
        if ($MDFilesPath -ne "") {
            if (-not (Test-Path -Path $MDFilesPath)) {
                New-Item -Path $(Split-Path -Path $MDFilesPath -Parent) -Name $(Split-Path -Path $MDFilesPath -Leaf) -ItemType Directory -Force | Out-Null
                $MDFilesDir = $MDFilesPath
            }else{
                $MDFilesDir = $MDFilesPath
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
            Module = $moduleFile.BaseName
            FwLink = "https://github.com/prboyer/PSVault"
            Metadata = @{Author = "Paul Boyer"; 'Module Guid'= $moduleGUID.Guid;}
            Locale = "en-US"
            ExcludeDontShow = $true
            HelpVersion = "1.1"
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
        Get-ChildItem -Path $MDFilesPath -Filter "*.md" -File | ForEach-Object{
            Set-Content -Path $_.FullName -Value $(Get-Content $_.FullName | ForEach-Object{
                if($_ -match "external help file:"){
                    $_.Substring(0,$_.IndexOf(':')+1)
                }else{
                    $_
                }
            })
        }
        
        <# Remove Inputs/Outputs sections if there is no content #>
            ## TODO Finish code for removing null inputs
            <# Remove the Inputs #>
            # # Get each MD file
            # Get-ChildItem -Path $MDFilesPath -Filter "*.md" -File | ForEach-Object{
            
            #     # Set the variable to the file path of the markdown file
            #     $File = $(Resolve-Path $_.FullName -Relative)

            #     #Find the line in the file that matches the ##INPUTS header (subtract one from the line number for the array index)
            #     [Int]$heading = (Get-Content -Path $File | Select-String "## INPUTS").LineNumber-1

            #     # Check if the following line is empty
            #     if ([String]::IsNullOrWhiteSpace($(Get-Content -Path $File)[$heading+1])){
            #         # Go through the current file and only return the appropriate lines (exclude ##INPUTS and the null line thereafter)
            #         Set-Content -Path $File -Value $(
            #             for ([Int]$i = 0; $i -lt $(Get-Content $File).Count; $i++) {
            #                 # exclude the heading and the line after
            #                 if ($i -eq $heading -or $i -eq $heading+1) {
            #                     ""
            #                 }else{
            #                     # return the other acceptable lines
            #                     $(Get-Content $File)[$i]
            #                 }
            #             }
            #         )
            #     }
            # }

        <# Remove the Outputs #>
            ## TODO Finish code for removing null outputs

    <# Generate the module README file. This is a summary page that has a short description and link to each individual MD file #>
        Start-Job -Name "Update-MarkdownHelpModule" -ArgumentList "$Path\README.md",$(Resolve-Path -Path $MDFilesDir -Relative).ToString() -ScriptBlock {
            Update-MarkdownHelpModule -ModulePagePath $args[0] -Path $args[1] -RefreshModulePage -Force| Out-Null
            Start-Sleep -Seconds 3
            
            # Close any open handles/file locks to the README.md file. If handles/locks are still open, then subsequent actions will fail
            if([System.IO.File]::Exists($args[0])){
                $FileStream = [System.IO.File]::Open($args[0],"Open","Write")
                $FileStream.Close()
                $FileStream.Dispose()
            }
        } | Out-Null

        # Wait for the job to complete before proceeding
        Wait-Job "Update-MarkdownHelpModule" | Out-Null
    
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
            $(Get-Content -Path "$Path\README.md").Replace("{{ Fill in the Description }}",$Description) | Set-Content -Path "$Path\README.md"; 

        <# Manually update the guid on the readme file #>
            $(Get-Content -Path "$Path\README.md").Replace("00000000-0000-0000-0000-000000000000",$moduleGUID.Guid) | Set-Content -Path "$Path\README.md";
        
}