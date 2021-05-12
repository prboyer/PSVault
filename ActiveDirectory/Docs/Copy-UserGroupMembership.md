---
Author: Paul Boyer
external help file: PSVault-ActiveDirectory-help.xml
Module Guid: 9da83db1-41df-4af6-a82c-e4553f563e2d
Module Name: PSVault-ActiveDirectory
online version:
schema: 2.0.0
---

# Copy-UserGroupMembership

## SYNOPSIS
Copies security group memberships from one user to one or more users

## SYNTAX

```
Copy-UserGroupMembership [-Source] <String> [-Target] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Script validates that AD user objects exist before trying to retrieve/apply group memberships.

## EXAMPLES

### EXAMPLE 1
```
Copy-UserGroupMembership -Source Bgates -Target SBallmer
```

## PARAMETERS

### -Source
The SamAccountName of the user who the memberships should be copied from

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target
String \[\] of SamAccountNames that the memberships should be applied to

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[http://mikefrobbins.com/2014/01/30/add-an-active-directory-user-to-the-same-groups-as-another-user-with-powershell/](http://mikefrobbins.com/2014/01/30/add-an-active-directory-user-to-the-same-groups-as-another-user-with-powershell/)

