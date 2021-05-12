---
Author: Paul Boyer
external help file: PSVault-ActiveDirectory-help.xml
Module Guid: 9da83db1-41df-4af6-a82c-e4553f563e2d
Module Name: PSVault-ActiveDirectory
online version:
schema: 2.0.0
---

# Disable-Users

## SYNOPSIS
Script to disable AD users without deleting their accounts

## SYNTAX

```
Disable-Users [[-TargetOU] <ADOrganizationalUnit>] [-Usernames] <String[]> [[-LogFile] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Script takes in a String\[\] of usernames and disables each user.
Optionally, the script can move users to an new OU

## EXAMPLES

### EXAMPLE 1
```
Disable-Users -Usernames "bgates" -LogFile "C:\Log.txt"
```

## PARAMETERS

### -TargetOU
An \[Microsoft.ActiveDirectory.Management.ADOrganizationalUnit\] object representing the new OU that disabled users should be moved to

```yaml
Type: ADOrganizationalUnit
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Usernames
String array of usernames that will be disabled by the script

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFile
String path to the log file that results should be saved to.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
requires -Modules ActiveDirectory

## RELATED LINKS
