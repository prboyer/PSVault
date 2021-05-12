---
Author: Paul Boyer
external help file: PSVault-ActiveDirectory-help.xml
Module Guid: 9da83db1-41df-4af6-a82c-e4553f563e2d
Module Name: PSVault-ActiveDirectory
online version:
schema: 2.0.0
---

# Migrate-UserProfile

## SYNOPSIS
Script used in preparing to migrate from a Windows 7 to Windows 10 environment.
This copies the contents of a user's 
Windows 7 roaming profile to a new Windows 10 (V6) roaming profile on a specified profile server.

## SYNTAX

```
Migrate-UserProfile [-Usernames] <String[]> [-ProfileServer] <String> [<CommonParameters>]
```

## DESCRIPTION
For each username, check that the Windows 7 profile (V2) exists on the profile server. 
If it does, then copy the contents of the V2 profile to a new Windows 10 (V6) profile.

## EXAMPLES

### EXAMPLE 1
```
Migrate-UserProfile -Usernames "BGates" -ProfileServer "\\winfs\share1\Users"
```

## PARAMETERS

### -Usernames
String array of usernames whose profiles need to be migrated to V6

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
Path to the share on the profile server containing the user profile directories.

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
Paul Boyer , 2/23/18

## RELATED LINKS
