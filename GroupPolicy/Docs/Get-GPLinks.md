---
Author: Paul Boyer
external help file: group-policy-backup-help.xml
Module Guid: d179234e-20d7-417a-b855-679e9f74a6fe
Module Name: group-policy-backup
online version:
schema: 2.0.0
---

# Get-GPLinks

## SYNOPSIS
Script to provide either a TXT or CSV report of linking relationships between OUs and GPOs.

## SYNTAX

### Both
```
Get-GPLinks [[-Path] <String>] [-BothReports] [<CommonParameters>]
```

### FullReport
```
Get-GPLinks [-Path] <String> [-AllOUs] [-RootOnly] [<CommonParameters>]
```

### CSVReport
```
Get-GPLinks [-Path] <String> [-CSVReport] [<CommonParameters>]
```

## DESCRIPTION
Script that reports what OUs in the domain have what GPOs linked to them. 
Intended for use with Group Policy backup as exported policies do not retain the link information.

## EXAMPLES

### EXAMPLE 1
```
Get-GPLinks -Path "C:\Temp"
```

## PARAMETERS

### -Path
Output path for files to be saved.
This should be a directory path, not a file path.

```yaml
Type: String
Parameter Sets: Both
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: FullReport, CSVReport
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CSVReport
Parameter causes script to run just the CSV report of OU and GPO correlation

```yaml
Type: SwitchParameter
Parameter Sets: CSVReport
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -BothReports
Parameter causes script to run both the CSV and TXT reports

```yaml
Type: SwitchParameter
Parameter Sets: Both
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllOUs
Parameter causes script to list all OUs at beginning of report, not just those with GPOs linked (default)

```yaml
Type: SwitchParameter
Parameter Sets: FullReport
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RootOnly
Parameter causes script to only report GPOs linked at the Domain Root

```yaml
Type: SwitchParameter
Parameter Sets: FullReport
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A .txt file report and/or a .csv report
## NOTES
Author: Paul Boyer
Date: 3-19-21

Fix for tables being cut of when writing out to file: https://poshoholic.com/2010/11/11/powershell-quick-tip-creating-wide-tables-with-powershell/

Getting the line number of the error in PS: https://stackoverflow.com/questions/17226718/how-to-get-the-line-number-of-error-in-powershell

Exporting Arrays to a CSV: https://community.spiceworks.com/topic/336094-exporting-arrays-to-a-csv-file

Scoping in PowerShell: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.1#powershell-scopes

## RELATED LINKS
