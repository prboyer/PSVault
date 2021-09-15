---
Author: Paul Boyer
external help file: psvault-GroupPolicy-help.xml
Module Guid: 5dd6cc45-eba3-42c7-b88a-75181c5faa55
Module Name: psvault-GroupPolicy
online version:
schema: 2.0.0
---

# Get-GPOUnlinked

## SYNOPSIS
Script for evaluating unlinked GPOs

## SYNTAX

### FilePath
```
Get-GPOUnlinked [-FilePath <String>] [<CommonParameters>]
```

### Email
```
Get-GPOUnlinked [-SendEmail] -To <String[]> [-CC <String[]>] [-BCC <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get a list of all GPOs and then only select those that are unlinked.
Join in information about the owner and description of the policy using calculated properties and the Get-GPO cmdlet. 
Then sort the results by their creation time and group them by owner.
The final results are then written to a file.

## EXAMPLES

### EXAMPLE 1
```
Get-GPOUnlinked -FilePath C:\Temp\UnlinkedGPOs.txt
```

This will save the results to a file called UnlinkedGPOs.txt in the C:\Temp directory.
The script will also return the results to standard out.

### EXAMPLE 2
```
Get-GPOUnlinked -SendEmail -To bbadger@wisc.edu
```

This will email the results to bbadger@wisc.edu

## PARAMETERS

### -FilePath
The path to the file to write the results to.

```yaml
Type: String
Parameter Sets: FilePath
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SendEmail
Switch parameter that tells the script to send the results in an email

```yaml
Type: SwitchParameter
Parameter Sets: Email
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -To
String array of email addresses

```yaml
Type: String[]
Parameter Sets: Email
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CC
String array of email addresses

```yaml
Type: String[]
Parameter Sets: Email
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BCC
String array of email addresses

```yaml
Type: String[]
Parameter Sets: Email
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Paul Boyer
Date: 9-3-2021

## RELATED LINKS
