---
Author: Paul Boyer
external help file: psvault-ActiveDirectory-help.xml
Module Guid: 66f0b290-a051-4b8e-be84-b0a280c74a50
Module Name: psvault-ActiveDirectory
online version:
schema: 2.0.0
---

# Get-ProfileSize

## SYNOPSIS
Script to calculate the size of a user profile on a profile server

## SYNTAX

```
Get-ProfileSize [-Username] <String[]> [-ProfileServer] <String> [<CommonParameters>]
```

## DESCRIPTION
Given an list of usernames and a share on a profile server, the script will calculate the sizes of profiles matching given usernames

## EXAMPLES

### EXAMPLE 1
```
Get-ProfileSize -Username "BGates" -ProfileServer "\\winfs1\dfsroot\Users"
```

## PARAMETERS

### -Username
String array of usernames.
Profile extensions (".v6") not required, script will perform wildcard lookup

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileServer
Path to share on profile server containing user profile directories

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Paul Boyer - 2-22-21

## RELATED LINKS
