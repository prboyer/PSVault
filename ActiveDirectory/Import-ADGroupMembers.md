---
Author: Paul Boyer
external help file: PSVault-ActiveDirectory-help.xml
Module Guid: 18f15d31-8ea0-4a67-bb67-09c9554871ae
Module Name: PSVault-ActiveDirectory
online version:
schema: 2.0.0
---

# Import-ADGroupMembers

## SYNOPSIS
Script that adds users to an AD Security group from a list of names (ln, fn mi) in text file

## SYNTAX

```
Import-ADGroupMembers [[-TextFilePath] <String>] [[-Group] <ADGroup>] [[-GroupName] <String>]
 [[-LogPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Parse the provided text file to add existing AD users to a security group.
The text file is supplied in the format (ln ,fn mi).
The script performs string manipulation
to get the names into a proper format for processing.
The entire process is logged using the PowerShell transcript function (kinda lazy, I know) and writes out the file path
provided in the -LogPath variable.

## EXAMPLES

### EXAMPLE 1
```
Import-ADGroupMembers -GroupName "Remote Desktop Users" -TextFilePath "C:\Users.txt" -LogFile "C:\Temp\"
```

## PARAMETERS

### -TextFilePath
The input file with a list of names that need to be added to a security group in AD

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
Expecting an AD group object.
This was added for additional versatility and to accommodate piping.

```yaml
Type: ADGroup
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupName
The name of the AD security group.
The script will handle creating a pointer to the object in AD.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogPath
The path where the log file should be saved.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Paul B - 9-18-19

## RELATED LINKS
