function Export-MDReadMe {
    # param (
    #     OptionalParameters
    # )
    
    #######################
    Import-Module platyPS

    $Path = "C:\Users\pboyer2\OneDrive - UW-Madison\Documents\Scripts\PSVault\Utilities"

    $files = Get-ChildItem -Path $Path -Filter "*.ps1"

    $files | %{
        Get-Content -Path $_.FullName | Out-File -FilePath $Path\Test-Module.psm1 -Append -Force
    }

    Import-Module -Name $Path\$(Get-ChildItem -Path $Path -Filter "*.psm1") -Force

    $OutputFolder = "$PSScriptRoot\Utilities"
    $parameters = @{
        Module = "Test-Module"
        OutputFolder = $OutputFolder
        AlphabeticParamsOrder = $true
        WithModulePage = $true
        ExcludeDontShow = $true
        #Encoding = 'UTF8BOM'
    }
    New-MarkdownHelp @parameters

    #New-MarkdownAboutHelp -OutputFolder $OutputFolder -AboutName "topic_name"

}

Export-MDReadMe