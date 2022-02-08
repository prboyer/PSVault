function Send-Email {
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

    .PARAMETER Authenticated
    Switch that indicates the SMTP server requires credentials.

    .PARAMETER Username
    String for the username to use when authenticating to the SMTP server.

    .PARAMETER Password
    String for the password to use when authenticating to the SMTP server. This is parameter is expecting a SecureString.

    .PARAMETER HTML
    Switch that indicates that the -Body String is formatted in HTML

    .PARAMETER SMTPServer
    URI of the SMTP server

    .PARAMETER SMTPPort
    Port of the SMTP server. If no port is specified, the default port is 25.

    .PARAMETER EnableSSL
    Switch parameter to tell the server to use SSL. By default, SSL is not used.

    .PARAMETER FromAddress
    String for the From address of the email.

    .PARAMETER FromName
    String for the From name of the email.

    .PARAMETER ReplyToAddress
    String for the ReplyTo address of the email.

    .EXAMPLE
    Send-Email -To bbadger@wisc.edu -Subject "Tuition is Due" -Body "Your Tuition Bill is available online" -FromAddress "noreply@wisc.edu" -FromName "WISC Tuition" -ReplyToAddress "support@wisc.edu" -SMTPServer "smtp.gmail.com"

    Sends an unauthenticated and non-SSL email to the specified recipient.

    .EXAMPLE
    Send-Email -To bbadger@wisc.edu -Subject "Tuition is Due" -Body "Your Tuition Bill is available online" -FromAddress "noreply@wisc.edu" -FromName "WISC Tuition" -ReplyToAddress "support@wisc.edu" -SMTPServer "smtp.gmail.com" -SMTPPort 587 -EnableSSL -Authenticated -Username "username" -Password "password"

    Sends an authenticated email with SSL to the specified recipient. The SMTP server is gmail.com and the port is 587.

    .NOTES
        Author: Paul Boyer
        Date: 4-9-2021

    .LINK
    https://stackoverflow.com/questions/36355271/how-to-send-email-with-powershell

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.net.mail?view=net-5.0

    #>
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(ParameterSetName="Default",Mandatory=$true)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $To,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $CC,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $BCC,
        [Parameter(ParameterSetName="Default",Mandatory=$true)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Subject,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Attachments,
        [Parameter(ParameterSetName="Default",Mandatory=$true)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Body,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [switch]
        $Authenticated,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [SecureString]
        [ValidateNotNullOrEmpty()]
        $Password,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$false)]
        [switch]
        $HTML,
        [Parameter(ParameterSetName="Default",Mandatory=$true)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SMTPServer,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$false)]
        [int]
        $SMTPPort,
        [Parameter(ParameterSetName="Default",Mandatory=$false)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$false)]
        [switch]
        $EnableSSL,
        [Parameter(ParameterSetName="Default",Mandatory=$true)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FromAddress,
        [Parameter(ParameterSetName="Default",Mandatory=$true)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FromName,
        [Parameter(ParameterSetName="Default",Mandatory=$true)]
        [Parameter(ParameterSetName="Authenticated", Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ReplyToAddress

    )
    <# Variables #>
        # SMTP Server Configuration
        [String]$SMTP_SERVER = $SMTPServer

        # SMTP Port Configuration. By default use port 25.
        [int]$script:SMTP_PORT = 25;
        if ($SMTPPort -ne 0) {
             $SMTP_PORT= $SMTPPort
        }

        # Determine if the email is authenticated
        if ($Authenticated) {
            [String]$USERNAME = $Username
            [String]$PASSWORD = $Password
        }

        # Sender Information
        [String]$SENDER_NAME = $FromName
        [String]$SENDER_EMAIL = $FromAddress
        [String]$SENDER_REPLYTO = $ReplyToAddress

    # Create new MailMessage Object
    [System.Net.Mail.MailMessage]$Message = [System.Net.Mail.MailMessage]::new();

    # Add sender information to the message
    [System.Net.Mail.MailAddress]$Sender = [System.Net.Mail.MailAddress]::new($SENDER_EMAIL, $SENDER_NAME);
    $Message.From = $Sender;
    $Message.Sender = $Sender;
    $Message.ReplyTo = $SENDER_REPLYTO;

    <# Address the message #>
        # Add the 'To' addresses
        $To | ForEach-Object {
            $Message.To.Add($_)
        }

        # Add the 'CC' addresses
        if($null -ne $CC){
            $CC | ForEach-Object {
                $Message.CC.Add($_)
            }
        }

        # Add the 'BCC' addresses
        if($null -ne $BCC){
            $BCC | ForEach-Object {
                $Message.Bcc.Add($_)
            }
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

    # If the -EnableSSL parameter is passed, set the SMTP client to use SSL
    if ($EnableSSL) {
        $Smtp.EnableSsl = $true;
    }else{
        $Smtp.EnableSsl = $false;
    }

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