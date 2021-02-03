function Export-MDReadMe {
    # param (
    #     OptionalParameters
    # )
    
    Import-Module -Name platyPS

    # Create the PS1M Module file from a collection of PS1 files
    $Path = ".\Utilities"

    $files = Get-ChildItem -Path $Path -Filter "*.ps1"
    
    [System.Collections.ArrayList]$list = [System.Collections.ArrayList]::new()
    $files | %{
        $list.Add($(". `".\"+$_.name+"`"")) | Out-Null
    }

    $name = "TEST"

    # Write the dot sourcing to a module file. 
    $list | Out-File -FilePath "$Path\$name.psm1" -Force

    # Import the module file that was just created
    Import-Module -FullyQualifiedName $(Get-ChildItem -Path $Path -Filter "*.psm1").FullName -Scope Local -Force

    # Call PlatyPS
    New-MarkdownHelp -Module $(Get-ChildItem -Path $Path -Filter "*.psm1").Name.Replace(".psm1","") -AlphabeticParamsOrder -OutputFolder $Path


}




Export-MDReadMe