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
    <# Variables #>
        # SMTP Server Configuration
        [String]$SMTP_SERVER = ""
        [Int]$SMTP_PORT = 587
        [String]$USERNAME = ""
        [String]$PASSWORD = ""

        # Sender Information
        [String]$SENDER_NAME = ""
        [String]$SENDER_EMAIL = ""
        [String]$SENDER_REPLYTO = ""

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
