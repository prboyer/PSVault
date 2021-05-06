function Export-ModuleDocs {
    param (
        [String]
        $Path,
        [switch]
        $IncludeIO,
        [string]
        $ModuleDescription,
        [string]
        $ModuleDescriptionFile
    )

    # Import platyPS module required for generating the markdown documentation
    Import-Module -Name platyPS

    # Get all the PS1 files in the directory and recurse into sub-directories
    $files = Get-ChildItem -Path $Path -Filter "*.ps1" -Recurse

    # Dot source all the PS1 files in a PSM1 module file
    $files | ForEach-Object{
        #[string]$(". `"$Path\"+$_.Name+"`"") | Out-File -FilePath "$Path\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force
        [String]$(". `""+$(Resolve-Path -Path $_.FullName -Relative)+"`"") | Out-File -FilePath "$Path\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force
    }
    
    # assign a new guid
    $moduleGUID = New-Guid

    # Import the module file
    $moduleFile = Get-ChildItem -Path $Path -Filter "*.psm1"
    Import-Module -Name $($Path+"\"+$moduleFile.BaseName) -DisableNameChecking

    # Determine how to set the module description
    [String]$Description = "";
    if(($ModuleDescriptionFile -ne "") -and ($ModuleDescription -eq "")){
        try{
            $Description = Get-Content $ModuleDescriptionFile
        }catch{
            Write-Warning $("Unable to get description text from file {0}" -f $ModuleDescriptionFile)
        }
    }else{
        if($ModuleDescription -ne ""){
            $Description = $ModuleDescription
        }else{
            $Description = Read-Host -Prompt "Enter message to user for Module Description"
        }
    }

    # Generate the psd1 file
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

    New-ModuleManifest @manifestParameters

    if(-not (Test-Path -Path "$Path\Docs")){
        New-Item -Path $Path -Name "Docs" -ItemType Directory
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