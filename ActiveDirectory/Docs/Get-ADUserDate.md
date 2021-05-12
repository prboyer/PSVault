---
Author: Paul Boyer
external help file: PSVault-ActiveDirectory-help.xml
Module Guid: 9da83db1-41df-4af6-a82c-e4553f563e2d
Module Name: PSVault-ActiveDirectory
online version:
schema: 2.0.0
---

# Get-ADUserDate

## SYNOPSIS
Script for determining when AD user accounts were created.

## SYNTAX

### User
```
Get-ADUserDate [-Username <String>] [-FilePath <String>] [<CommonParameters>]
```

### Date
```
Get-ADUserDate [-Date <DateTime>] [-Days <Int32>] [-FilePath <String>] [<CommonParameters>]
```

## DESCRIPTION
The script will either return a simple query for when a single user account was created, or a report
of what user accounts were created in the last X days.

## EXAMPLES

### EXAMPLE 1
```
Get-ADUserDate -Days 30
```

### EXAMPLE 2
```
Get-ADUserDate -Days 30 -FilePath C:\Results.txt
```

## PARAMETERS

### -Username
String representing the username of the user account to query.
The script will return the date created.

```yaml
Type: String
Parameter Sets: User
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Date
DateTime when new accounts created thereafter should be returned.

```yaml
Type: DateTime
Parameter Sets: Date
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Days
Int number of days prior to today that the script should evaluate

```yaml
Type: Int32
Parameter Sets: Date
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath
Path to where the resulting file should be saved

```yaml
Type: String
Parameter Sets: (All)
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

## RELATED LINKS
