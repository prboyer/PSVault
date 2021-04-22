function Export-ModuleDocs {
    param (
        [String]
        $Path,
        [Switch]
        $Concat,
        [switch]
        $IncludeIO
    )

    # Import platyPS
    Import-Module -Name platyPS

    # Get all the PS1 files in the directory
    $files = Get-ChildItem -Path $Path -Filter "*.ps1"

    # Append the contents of all the PS1 files into a PSM1 module file
    # if ($Concat) {
    #     $files | %{
    #         Get-Content -Path $_.FullName | Out-File -FilePath "$Path\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force
    #     }
    # }else {
        # Dot source all the PS1 files in a PSM1 module file
        $files | ForEach-Object{
            [string]$(". `"$Path\"+$_.Name+"`"") | Out-File -FilePath "$Path\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force 
        }
    # }

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

    }

    New-ModuleManifest @manifestParameters

    if(-not (Test-Path -Path "$Path\Docs")){
        New-Item -Path $Path -Name "Docs" -ItemType Directory
    }

    # Generate platyPS markdown
    $parameters= @{
        Module = $moduleFile.BaseName
        FwLink = "https://github.com/prboyer/PSVault"
        Metadata = @{Author = "Paul Boyer"; 'Module Guid'= $moduleGUID.Guid; }
        Locale = "en-US"
        ExcludeDontShow = $true
        HelpVersion = "1.0.1"
        OutputFolder = "$Path\Docs\"
        Force = $true
        WithModulePage = $false
        ModulePagePath ="$Path\README.md"
    }

    # generate the individual help files
    New-MarkdownHelp @parameters | Out-Null

    # generate the module readme file
    Update-MarkdownHelpModule -ModulePagePath "$Path\README.md" -Path "$Path\Docs" -RefreshModulePage | Out-Null

    # change the pathing of the README.md file to be correct
    Set-Content -Path "$Path\README.md" -Value $(get-content -path "$Path\README.md" | ForEach-Object{
        if($_ -match "###"){
            $_.ToString().Replace($_,$_.ToString().Insert($_.ToString().IndexOf('(')+1,$(Split-Path $Path -Leaf)+"\Docs\"))
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

    # manually update the guid on the readme file
    $(Get-Content -Path "$Path\README.md").Replace("00000000-0000-0000-0000-000000000000",$moduleGUID.Guid) | Set-Content -Path "$Path\README.md";

}

Export-ModuleDocs -Path .\Windows10