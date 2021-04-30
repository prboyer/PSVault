function Export-ModuleDocs {
    param (
        [String]
        $Path,
        [switch]
        $IncludeIO
    )

    # Import platyPS
    Import-Module -Name platyPS

    # Get all the PS1 files in the directory
    $files = Get-ChildItem -Path $Path -Filter "*.ps1"

    # Dot source all the PS1 files in a PSM1 module file
    $files | ForEach-Object{
        [string]$(". `"$Path\"+$_.Name+"`"") | Out-File -FilePath "$Path\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force 
    }
    
    # assign a new guid
    $moduleGUID = New-Guid

    # Import the module file
    $moduleFile = Get-ChildItem -Path $Path -Filter "*.psm1"
    Import-Module -Name $($Path+"\"+$moduleFile.BaseName) -DisableNameChecking

    # Generate the psd1 file
    $manifestParameters= @{
        Path = $($Path+"\"+$moduleFile.BaseName+".psd1")
        Author = "Paul R Boyer"
        FileList = $files
        Guid = $moduleGUID.Guid
        ProcessorArchitecture = "Amd64"
        ProjectUri = "https://www.github.com/prboyer/psvault"
        RootModule = $moduleFile
        Description = "this is a test of the documentation"

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

    # manually update the guid on the readme file
    $(Get-Content -Path "$Path\README.md").Replace("00000000-0000-0000-0000-000000000000",$moduleGUID.Guid) | Set-Content -Path "$Path\README.md";

}

Export-ModuleDocs -Path .\Windows10