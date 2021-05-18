---
Author: Paul Boyer
external help file: group-policy-backup-help.xml
Module Guid: d179234e-20d7-417a-b855-679e9f74a6fe
Module Name: group-policy-backup
online version:
schema: 2.0.0
---

# Run-GPOBackup

## SYNOPSIS
All-in-one GPO Backup Script.
It leverages external modules/functions to create a robust backup of Group Policies in a domain.

## SYNTAX

```
Run-GPOBackup [-BackupFolder] <String> [[-Domain] <String>] [-BackupsToKeep] <Int32> [<CommonParameters>]
```

## DESCRIPTION
The script runs BackUp_GPOs.ps1 and Get-GPLinks.ps1 externally to generate additional backup content.
The script will backup all GPOs in the domain, as well as HTML
reports for each GPO indicating what they do.
Further, a CSV report is included.
The GPO linkage to OUs is also included in both CSV and TXT reports.
The idea is that this backup is
all-encompassing and would constitue a disaster recovery restore.

## EXAMPLES

### EXAMPLE 1
```
Run-GPOBackup -BackupFolder C:\Backups -BackupsToKeep 10
```

## PARAMETERS

### -BackupFolder
Path to where the backups should bs saved

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

### -Domain
The domain against which backups are being run.
If no value is supplied, the script will implicitly grab the domain from the machine it is running against.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupsToKeep
Parameter that indicates how many previous backups to keep.
Once the backup directory contains X backups, the oldest backups are then removed.
By default, 10 backups are kept.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A .zip archive containing all necessary backup information to restore a GPO environment
## NOTES
Author: Paul Boyer
Date: 5-5-21

## RELATED LINKS
