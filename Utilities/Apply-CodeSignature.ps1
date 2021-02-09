function Apply-CodeSignature {
    <#
    .SYNOPSIS
    Script to automate signing of other scripts with digital certificate

    .DESCRIPTION
    Automatically grab a code signing certificate from the current user certificate store (after checking that a code signing certificate exists). 
    Then append that certificate to the end of the code file. 
    
    .PARAMETER FilePath
    FilePath to the file that will be digitally signed with the code signing certificate. Note that the parameter is positionally bound and does not need to be called explicitly.
    
    .EXAMPLE
    Apply-CodeSignature -FilePath "path to file"

    .EXAMPLE
    Apply-CodeSignature "path to file"
    
    .LINK
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing?view=powershell-7.1
    #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FilePath
    )
    
    # Make sure that a digital code signing certificate is available. 
    if((Get-ChildItem Cert:\CurrentUser\my -CodeSigning | Measure-Object).Count -lt 1){
        Write-Error "No digital code signing certificate available." -ErrorAction Stop
    }

    # Set variable equal to code signing certificate
    $cert = @(Get-ChildItem Cert:\CurrentUser\my -CodeSigning)[0];

    # Sign the script
    Set-AuthenticodeSignature $FilePath $cert
}

#Apply-CodeSignature -FilePath $args[0]