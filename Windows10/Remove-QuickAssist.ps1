function Remove-QuickAssist{
    <#
    .SYNOPSIS
    . Function wrapper for removing Windows QuickAssist
    
    .DESCRIPTION
    Removes the Windows Quick Assist app using the Remove-WindowsCapability cmdlet
    
    .EXAMPLE
    Remove-QuickAssist

    .NOTES
    
    #>


    Remove-WindowsCapability -Online -Name "App.Support.QuickAssist*" -Verbose
}