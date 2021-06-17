---
Author: Paul Boyer
external help file: psvault-SCCM_MECM-help.xml
Module Guid: bed21bd1-6f2c-4c2d-b1b8-4cd7271806ad
Module Name: psvault-SCCM_MECM
online version:
schema: 2.0.0
---

# Build-MECMComputerReport

## SYNOPSIS
Script that extracts computer information and user information from all assets in a given MECM collection

## SYNTAX

### Collection
```
Build-MECMComputerReport -Path <String> [-CollectionName <String>] -SiteCode <String>
 -ProviderMachineName <String> [<CommonParameters>]
```

### Array
```
Build-MECMComputerReport -Path <String> [-ComputerNames <String[]>] -SiteCode <String>
 -ProviderMachineName <String> [<CommonParameters>]
```

## DESCRIPTION
Using both MECM and ActiveDirectory data mining, generate a report of computers in a given collection and correlate corresponding user information.

## EXAMPLES

### EXAMPLE 1
```
Build-MECMComputerReport -CollectionName "Windows 10" -Path "C:\Temp" -SiteCode "ABC" -ProviderMachineName "mecm-server.abc.com"
```

## PARAMETERS

### -Path
The path where a csv report should be saved

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionName
The name of the device collection in MECM to report on.
Accepts wildcards.

```yaml
Type: String
Parameter Sets: Collection
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerNames
A list of computer names to run the report against

```yaml
Type: String[]
Parameter Sets: Array
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SiteCode
The MECM site code which the script should be run against.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProviderMachineName
The MECM endpoint that the script should be run against, typically a DP or another MECM server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Either the name of an existing MECM device collection or a list of computer names.
## OUTPUTS

### A CSV report with the date run appended. "MECM_Report-$(Get-Date -Format FileDate).csv"
## NOTES

## RELATED LINKS
