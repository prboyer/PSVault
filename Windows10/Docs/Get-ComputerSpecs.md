---
Author: Paul Boyer
external help file: PSVault-Windows10-help.xml
Module Guid: ffa4f42e-7097-4055-ae7d-e2e8974c6758
Module Name: PSVault-Windows10
online version:
schema: 2.0.0
---

# Get-ComputerSpecs

## SYNOPSIS
A PowerShell script to create a report of a machine's hardware.

## SYNTAX

```
Get-ComputerSpecs [-Path] <String> [[-ComputerName] <String>] [<CommonParameters>]
```

## DESCRIPTION
The script uses mainly WMI to query the hardware (and OS) of a machine and generate a text report.
The report can then be saved to a location specified by -Path.
The script can be run
against remote machines by supplying a value for -ComputerName.

## EXAMPLES

### EXAMPLE 1
```
Get-ComputerSpecs -Path C:\temp\report.txt
```

Run the report and save the results to a TXT file at C:\temp\report.txt

### EXAMPLE 2
```
Get-ComputerSpecs -Path C:\temp\report.txt -ComputerName Server01.contoso.com
```

Run the report against Server01.contoso.com and save the results to a TXT file at C:\temp\report.txt

## PARAMETERS

### -Path
Confirm $Path is Valid

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

### -ComputerName
{{ Fill ComputerName Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A .TXT file containing the hardware report for the computer.
## NOTES
Author: Paul Boyer
Date: 06-23-2021

## RELATED LINKS
