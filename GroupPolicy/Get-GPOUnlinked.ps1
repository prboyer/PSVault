function Get-GPOUnlinked {
<#
.SYNOPSIS
Script for evaluating unlinked GPOs

.DESCRIPTION
Get a list of all GPOs and then only select those that are unlinked. Join in information about the owner and description of the policy using calculated properties and the Get-GPO cmdlet. 
Then sort the results by their creation time and group them by owner. The final results are then written to a file.

.PARAMETER FilePath
The path to the file to write the results to.

.PARAMETER SendEmail
Switch parameter that tells the script to send the results in an email

.PARAMETER To
String array of email addresses 
    
.PARAMETER CC
String array of email addresses 
    
.PARAMETER BCC
String array of email addresses 

.EXAMPLE
Get-GPOUnlinked -FilePath C:\Temp\UnlinkedGPOs.txt

This will save the results to a file called UnlinkedGPOs.txt in the C:\Temp directory. The script will also return the results to standard out.

.EXAMPLE
Get-GPOUnlinked -SendEmail -To bbadger@wisc.edu 

This will email the results to bbadger@wisc.edu

.NOTES
    Author: Paul Boyer
    Date: 9-3-2021
#>
    param (
        [Parameter(ParameterSetName="FilePath")]
        [String]
        $FilePath,
        [Parameter(ParameterSetName="Email")]
        [Switch]
        $SendEmail,
        [Parameter(ParameterSetName="Email", Mandatory=$true)]
        [String[]]
        $To,
        [Parameter(ParameterSetName="Email")]
        [String[]]
        $CC,
        [Parameter(ParameterSetName="Email")]
        [String[]]
        $BCC
    )
        
    #Requires -Module GroupPolicy
    #Requires -Version 5.1

    function private:Send-Email {
        <#
        .SYNOPSIS
        Script that generates and sends an Email message.
        
        .DESCRIPTION
        Due to the deprecation of Send-MailMessage cmdlet, this script leverages the .NET libraries to construct and email and send it to a user.
        
        .PARAMETER To
        String array of email addresses 
        
        .PARAMETER CC
        String array of email addresses 
        
        .PARAMETER BCC
        String array of email addresses 
        
        .PARAMETER Subject
        String for the subject line of the mail message
    
        .PARAMETER Attachments
        String array of paths to files to attach to the email
        
        .PARAMETER Body
        String to place into the body of the email
        
        .PARAMETER Unauthenticated
        Switch that indicates the SMTP server does not require credentials
        
        .PARAMETER HTML
        Switch that indicates that the -Body String is formatted in HTML
    
        .EXAMPLE
        Send-Email -To bbadger@wisc.edu -Subject "Tuition is Due" -Body "Your Tuition Bill is available online"
        
        .NOTES
            Author: Paul Boyer
            Date: 4-9-20201
    
        .LINK
        https://stackoverflow.com/questions/36355271/how-to-send-email-with-powershell
    
        .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.net.mail?view=net-5.0
    
        #>
        param (
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [String[]]
            $To,
            [Parameter(Mandatory=$false)]
            [ValidateNotNullOrEmpty()]
            [String[]]
            $CC,
            [Parameter(Mandatory=$false)]
            [ValidateNotNullOrEmpty()]
            [String[]]
            $BCC,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [String]
            $Subject,
            [Parameter(Mandatory=$false)]
            [ValidateNotNullOrEmpty()]
            [String[]]
            $Attachments,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [String]
            $Body,
            [Parameter()]
            [switch]
            $Unauthenticated,
            [Parameter()]
            [switch]
            $HTML
    
        )
        # Variables #
            # SMTP Server Configuration
            [String]$SMTP_SERVER = "smtp.ssc.wisc.edu"
            [Int]$SMTP_PORT = 587
            [String]$USERNAME = ""
            [String]$PASSWORD = ""
    
            # Sender Information
            [String]$SENDER_NAME = "SSCC"
            [String]$SENDER_EMAIL = "donotreply@ssc.wisc.edu"
            [String]$SENDER_REPLYTO = "helpdesk@ssc.wisc.edu"
    
        #########
        # Create new MailMessage Object
        [System.Net.Mail.MailMessage]$Message = [System.Net.Mail.MailMessage]::new();
    
        # Add sender information to the message
        [System.Net.Mail.MailAddress]$Sender = [System.Net.Mail.MailAddress]::new($SENDER_EMAIL, $SENDER_NAME);
        $Message.From = $Sender;
        $Message.Sender = $Sender;
        $Message.ReplyTo = $SENDER_REPLYTO;
    
        # Address the message
        $Message.To.Add($To)
        if($null -ne $CC){
            $Message.CC.Add($CC) 
        }
        
        if($null -ne $BCC){
            $Message.Bcc.Add($BCC)
        }
    
        # Compose the message
        $Message.Subject = $Subject
        $Message.Body = $Body
    
        # Set the body formatting mode to HTML if -HTML passed
        if ($HTML) {
            $Message.IsBodyHtml = $true;
        }
    
        # Handle Attachments
        if ($null -ne $Attachments) {
            foreach($a in $Attachments){
                $AttachmentObject = New-Object Net.Mail.Attachment($a);
                $Message.Attachments.Add($AttachmentObject);
            }
        }
    
        # Send the message
        [Net.Mail.SmtpClient]$Smtp = [Net.Mail.SmtpClient]::new()
        $Smtp.EnableSsl = $true;
        $Smtp.Port = $SMTP_PORT
        $Smtp.Host = $SMTP_SERVER
    
            # Create credentials
            if (-not $Unauthenticated) {
                [System.Net.NetworkCredential]$Credentials = [System.Net.NetworkCredential]::new()
                $Credentials.UserName = $USERNAME
                $Credentials.Password = $PASSWORD
                $Smtp.Credentials = $Credentials;
            }
        
        $Smtp.Send($Message);
    
        # Cleanup
        try{
            $AttachmentObject.Dispose();
        }catch [System.Management.Automation.RuntimeException] {
            if ($null -eq $Attachments) {
                Write-Warning -Message "No attachment object passed. Unable to dispose of null object."
            }else{
                Write-Warning -Message "Unable to dispose of attachment object."
            }
        }
    }
    

    # Import module for determining GPO Links. Evaluate if the module is already loaded. Perform error handling if the module cannot be located
        try{
            if($(get-module | Where-Object {"GPFunctions" -in $_.name} | Measure-Object).Count -lt 1){
                Import-Module "$PSScriptRoot\External\GPFunctions.psm1" -ErrorAction Stop
            }
        }   catch [System.IO.FileNotFoundException]{

            # Terminate process of the script if the requisite module cannot be imported
            Write-Error "Unable to locate module 'GPFunctions.psm1'" -Category ObjectNotFound 
            Exit;
        }
    
    # Only process if the -SendEmail parameter was specified
    if ($SendEmail) {
        # Set the $FilePath parameter
        $FilePath = "$PSScriptRoot\UnlikedGPOReport_$(Get-Date -Format FileDateTimeUniversal).txt"
        
        # Get a list of all GPOs and then only select those that are unlinked. Join in information about the owner and description of the policy using calculated properties and the Get-GPO cmdlet.
        # Then sort the results by their creation time and group them by owner. The final results are then written to a file.
        Get-GPUnlinked | Where-Object {!$_.Linked} | Select-Object DisplayName, @{Name="Owner";Expression={(Get-GPO -GUID $_.Name.Trim('{}').Trim()).Owner}}, @{Name="DateModified";Expression={$_.whenChanged}}, @{Name="DateCreated"; Expression={$_.whenCreated}}, @{Name="Description";Expression={(Get-GPO -GUID $_.Name.Trim('{}')).Description}} | Sort-Object DateCreated | Group-Object Owner | ForEach-Object{
                Tee-Object -InputObject $_.Name -File $FilePath -Append
                Tee-Object -InputObject $($_ | Select-Object -ExpandProperty Group | Format-Table -AutoSize | Out-String -Width 640) -File $FilePath -Append
        }

        <# Prepare to send the email with the results #>
        # Create a string to store the email body message
        [string]$EmailBody = "Attached are the results of Get-GPOUnlinked.ps1; a report to gather all unlinked GPOs in the domain. The results are grouped by owner and sorted by creation time. The results can be found below or in the attached text file. Please do not reply to this message. It was systematically generated from $($env:COMPUTERNAME)."

        # Handle sending the email to the appropriate addresses based on how they are specifed (To, CC, BCC)
        if ($To -ne $null -and $CC -ne $null -and $BCC -ne $null) {
            private:Send-Email -To $To -CC $CC -BCC $BCC -Subject "Unlinked GPO Report - $(Get-Date -Format "d")" -Unauthenticated -Attachments $FilePath -Body $EmailBody 
        }elseif($To -ne $null -and $CC -ne $null){
            private:Send-Email -To $To -CC $CC -Subject "Unlinked GPO Report - $(Get-Date -Format "d")" -Unauthenticated -Attachments $FilePath -Body $EmailBody 
        }else{
            private:Send-Email -To $To -Subject "Unlinked GPO Report - $(Get-Date -Format "d")" -Unauthenticated -Attachments $FilePath -Body $EmailBody
        }
    
        # Cleanup by removing the file from $PSScriptRoot
        Remove-Item -Force -Path $FilePath

    }
    else{
    # Get a list of all GPOs and then only select those that are unlinked. Join in information about the owner and description of the policy using calculated properties and the Get-GPO cmdlet.
    # Then sort the results by their creation time and group them by owner. The final results are then written to a file.
        Get-GPUnlinked | Where-Object {!$_.Linked} | Select-Object DisplayName, @{Name="Owner";Expression={(Get-GPO -GUID $_.Name.Trim('{}').Trim()).Owner}}, @{Name="DateModified";Expression={$_.whenChanged}}, @{Name="DateCreated"; Expression={$_.whenCreated}}, @{Name="Description";Expression={(Get-GPO -GUID $_.Name.Trim('{}')).Description}} | Sort-Object DateCreated | Group-Object Owner | ForEach-Object{
            if ($FilePath -ne ""){
                Tee-Object -InputObject $_.Name -File $FilePath -Append
                Tee-Object -InputObject $($_ | Select-Object -ExpandProperty Group | Format-Table -AutoSize | Out-String) -File $FilePath -Append
            }
            else{
                $_.Name
                $_ | Select-Object -ExpandProperty Group | Format-Table -AutoSize
            }
        }
    }
}


# SIG # Begin signature block
# MIIOgwYJKoZIhvcNAQcCoIIOdDCCDnACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVvLNQ75zstgpiz0vqVb3LpBN
# UHGgggvOMIIFvDCCA6SgAwIBAgITHgAAAAjRvX7DjspE9AAAAAAACDANBgkqhkiG
# 9w0BAQsFADB1MRMwEQYKCZImiZPyLGQBGRYDZWR1MRQwEgYKCZImiZPyLGQBGRYE
# d2lzYzETMBEGCgmSJomT8ixkARkWA3NzYzETMBEGCgmSJomT8ixkARkWA2FkczEe
# MBwGA1UEAxMVU1NDQ1Jvb3RDZXJ0QXV0aG9yaXR5MB4XDTE4MTIxMTIxMTY1NFoX
# DTIzMTIxMTIxMjY1NFowZzETMBEGCgmSJomT8ixkARkWA2VkdTEUMBIGCgmSJomT
# 8ixkARkWBHdpc2MxEzARBgoJkiaJk/IsZAEZFgNzc2MxEzARBgoJkiaJk/IsZAEZ
# FgNhZHMxEDAOBgNVBAMTB1NTQ0MgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQC4x+jiZP66RVCKJEhDddCX5HmBV7gdtyul5zAdugwPaqiOkXT+xWBY
# 8HeFTCvNftAvrrYAJfl18VrbS95A/sjXWsinX3CHoXCE0Qs3yBFy7UQurFVHsLkz
# Tdq/5pRHJAtOcx0uUCwoAYUhhkG+blpSkXw6JgOQNI2XWN8vzlDTbQ8JCr/Wj+ex
# 2MNJpXrd/cBSc76kUvEhW+gAJJBCiTUWSYK5Cxe9vsQPACfcCDAE5SmuOyRpTFj4
# Nw0A4VjPAskUfpnOIxcllZL+sdbeBAZ1cAu7EY5CyKrHKC+iqMYv012aT4WJf5Ok
# VzWHodI1bO43GtRVyCWdIBF5t7TQME99AgMBAAGjggFRMIIBTTAQBgkrBgEEAYI3
# FQEEAwIBATAjBgkrBgEEAYI3FQIEFgQU5JUeo22fvT6ZWUeQUv5tNUECXggwHQYD
# VR0OBBYEFJucPDsOj4fHFNBuavgyLcmy5aiOMBkGCSsGAQQBgjcUAgQMHgoAUwB1
# AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaA
# FHu0uMuXGTAdHazdkc+XVIuSke/TMEcGA1UdHwRAMD4wPKA6oDiGNmh0dHA6Ly9j
# ZXJ0LnNzYy53aXNjLmVkdS9DRFAvU1NDQ1Jvb3RDZXJ0QXV0aG9yaXR5LmNybDBS
# BggrBgEFBQcBAQRGMEQwQgYIKwYBBQUHMAKGNmh0dHA6Ly9jZXJ0LnNzYy53aXNj
# LmVkdS9jZHAvU1NDQ1Jvb3RDZXJ0QXV0aG9yaXR5LmNydDANBgkqhkiG9w0BAQsF
# AAOCAgEALqjbBWFxNMELQtvxQYHmP4yln038iQjX3o8jJxvmC/5cZwCg7jw8asdf
# lRqYR8ZGFqzGRv040ECHhicjjVKnSxcNRuQCKR+Yoz83nAQXovhU/mtP/+3PKv9N
# l/9rMAP6LZ8t49fo/BsiKMTFmVc88KCc8yuKi2ie94GherAP02b5U52A3JLRgfFW
# tXISWGY2uS6nBvxw1MWw9+5xfUH+EROdrNIXLce+ypEzHTR7C1g2QllFP65nf6cB
# WUV6Tng2eCraZl23ieZcf+OX1GMFx83LK5NGsaUsZvH7oQTq456USsah/6gNrS3C
# hE6Ir30sL93bpNtr7szrsvf2a9AnqgF80ExU3k+WROGeFor1nRw3yp1GPRXa5U9M
# Z9+wYD/dyNd48riUIOTAgcjTcaHAxJVsYeSj8Lcqxh7acJ6W2e5TYi7tgQ6unCNF
# pgIJ9er2eefd12w9OJIJDdbicJbXoe6QreLeIQMwust9qkBlxb2oiTvBJj7tfLnd
# 9x0EIr+oh+opRW96wJRsxYCs6iro0N7bSiVYbMaXGEOSkGJsaCXyDy6580RmskrF
# zXAdLADHSdVjCKJ/trH4ArYxXRU3gA4wqlc0Pr950+wypoJsE7l4bKHMaf6v+AGO
# 7GH1lo3fjpCgK/m7qnsrVl+ylvfH0QeuDkal8DDp3SC+DkNbZNYwggYKMIIE8qAD
# AgECAhMZAAAvgi/AXXfejLtDAAEAAC+CMA0GCSqGSIb3DQEBCwUAMGcxEzARBgoJ
# kiaJk/IsZAEZFgNlZHUxFDASBgoJkiaJk/IsZAEZFgR3aXNjMRMwEQYKCZImiZPy
# LGQBGRYDc3NjMRMwEQYKCZImiZPyLGQBGRYDYWRzMRAwDgYDVQQDEwdTU0NDIENB
# MB4XDTIwMDQxNDE3MTMyMVoXDTIyMDQxNDE3MTMyMVowFTETMBEGA1UEAxMKUGF1
# bCBCb3llcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANDaFi+f3bbp
# HoXchIz9lsOyFHdWjIwU25D38jaoNsLAvDxLRRhe/hJRAiplr7073atVUuyB3Jd4
# qckr24lfwuEN4mGtprgLhQaJY0L9cd7dxBwPQuwmw8PypNRPmJox1Zl9STvBlvYg
# OsXkWJU2N+/FyqFrPPkZ8dniWG0L9JqKXC3QrAPZLVm0KOBOCI09renm/N5oi0Bu
# dGUtsSUt+SY+0KA8KM0Y0cKRSUDcmJSeT/8tHQnd1urZ1I/yKD+F0GRXhl4J3Fay
# oNyFOGsxvulCkjqiscDgyB0o5gKGYM+LG+JXyKKWZRaSZl4DRoUGsMBZSzkmg1iO
# ckPph1v6N/0CAwEAAaOCAv8wggL7MD0GCSsGAQQBgjcVBwQwMC4GJisGAQQBgjcV
# CIXyvGaBt7Vqh9GbPoXpxRaC+Z5dLISosRqBpNpkAgFkAgEGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsG
# AQUFBwMDMB0GA1UdDgQWBBQuCyWOqOdAepuTFboIU+V9Kf2KdjAfBgNVHSMEGDAW
# gBSbnDw7Do+HxxTQbmr4Mi3JsuWojjCCAQAGA1UdHwSB+DCB9TCB8qCB76CB7IaB
# vWxkYXA6Ly8vQ049U1NDQyUyMENBLENOPVNTQ0NTdWJDYSxDTj1DRFAsQ049UHVi
# bGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlv
# bixEQz1hZHMsREM9c3NjLERDPXdpc2MsREM9ZWR1P2NlcnRpZmljYXRlUmV2b2Nh
# dGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludIYq
# aHR0cDovL2NlcnQuc3NjLndpc2MuZWR1L2NkcC9TU0NDJTIwQ0EuY3JsMIH+Bggr
# BgEFBQcBAQSB8TCB7jCBswYIKwYBBQUHMAKGgaZsZGFwOi8vL0NOPVNTQ0MlMjBD
# QSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMs
# Q049Q29uZmlndXJhdGlvbixEQz1hZHMsREM9c3NjLERDPXdpc2MsREM9ZWR1P2NB
# Q2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9y
# aXR5MDYGCCsGAQUFBzAChipodHRwOi8vY2VydC5zc2Mud2lzYy5lZHUvY2RwL1NT
# Q0MlMjBDQS5jcnQwMwYDVR0RBCwwKqAoBgorBgEEAYI3FAIDoBoMGHBib3llcjJA
# YWRzLnNzYy53aXNjLmVkdTANBgkqhkiG9w0BAQsFAAOCAQEANIfgfRwgh1VYrItf
# ibq0yf/2B/2qk/aMG10mDO7qxdkLIAnyUI4WQKOq0F0f/buvQvDIjBT26znagwCO
# n6JoO9j3orgDxDJ5K9SQ3DGPuhMz6t90gSt6pk2WF9V0ELSd+yrMmHHOMgrMmQ7j
# Do2mrTpAEA9Es3Z3c8gv8GjckHAo4JZqJ0rAtogKhIsD4AfP2HAJaRH3q80YJ3vq
# zoGbF6MvHLSgop+fePvxnSWiM/9qaq+xeK5sWqV3G4G7nX6932yju8q/nzr3uaVN
# PfZ/0ACfZPu9lXoPhZctK2lkiqVj25WBewX8+s/YAeD/Opz1tok5pQ98PsNmdCt+
# kv7CtzGCAh8wggIbAgEBMH4wZzETMBEGCgmSJomT8ixkARkWA2VkdTEUMBIGCgmS
# JomT8ixkARkWBHdpc2MxEzARBgoJkiaJk/IsZAEZFgNzc2MxEzARBgoJkiaJk/Is
# ZAEZFgNhZHMxEDAOBgNVBAMTB1NTQ0MgQ0ECExkAAC+CL8Bdd96Mu0MAAQAAL4Iw
# CQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# IwYJKoZIhvcNAQkEMRYEFGRLFOjM3vpOd6N0lY/Iv7cLEP72MA0GCSqGSIb3DQEB
# AQUABIIBAJpM6nsllET7yNJR7ePC+vt9f9M99aGlhEY4QxEnR8KjBPI+M2V43kdU
# yBs2ysE7XgEcufu9bW7FXzJdTcI5hPZIzndEDaxrhho4YH1/TlW75/nU4LXEOfy2
# 9EmInqNNo8wcrQY5WAsST+f4CvXh+c1XRqpg1hCybK/1TgMWMCzPHgYHQQvxwfYL
# AlOaDyoYZ6ABkpInbYiTEhot9j7U9K6OYtVjXBDVCRbeQaps5sA/6yp7MVSolpqP
# sndaJwKNFpjXHnhg6J3UewSz/QcVyGWE2AY/l2gas0u9/A4fZbw0S2wm2FW2qg5O
# m/I44S4/lhMRN0GKDqXg8BRbWgUxsFA=
# SIG # End signature block
