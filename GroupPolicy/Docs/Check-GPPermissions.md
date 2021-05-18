---
Author: Paul Boyer
external help file: group-policy-backup-help.xml
Module Guid: d179234e-20d7-417a-b855-679e9f74a6fe
Module Name: group-policy-backup
online version:
schema: 2.0.0
---

# Check-GPPermissions

## SYNOPSIS
Script to report GPOs in a domain that do not have accessible ACLs applied.

## SYNTAX

```
Check-GPPermissions [[-FilePath] <String>] [-Fix] [[-Exclude] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
The script will evaluate which GPOs are lacking 'Apply' permissions for either Authenticated Users or Domain Computers.
If neither permission is applied, the group
policies themselves will not be applied.
However, sometimes when a GPO is to be limited to a specific security group it is necessary to make the ACLs more targeted.
With this in mind, 
certain GUIDs can excluded from the report.

## EXAMPLES

### EXAMPLE 1
```
Check-GPPermissions -FilePath C:\Temp\Report.txt
```

### EXAMPLE 2
```
Check-GPPermissions -Fix
```

## PARAMETERS

### -FilePath
Path to where the report should be saved.
This should be a .txt file.

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

### -Fix
Switch parameter that will send the script into an interactive mode to fix the missing ACLs on GPOs

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude
String Array of GUIDs to exclude from evaluation

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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
