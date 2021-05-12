---
Author: Paul Boyer
external help file: PSVault-SCCM_MECM-help.xml
Module Guid: 61cf29f1-66a0-40cc-a981-57ff88db58b6
Module Name: PSVault-SCCM_MECM
online version:
schema: 2.0.0
---

# Build-MECMComputerReport

## SYNOPSIS
Script that extracts computer information and user information from all assets in a given MECM collection

## SYNTAX

```
Build-MECMComputerReport [-Path] <String> [-CollectionName] <String> [-SiteCode] <String>
 [-ProviderMachineName] <String> [<CommonParameters>]
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
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionName
The name of the device collection in MECM to report on.
Accepts wildcards.

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

### -SiteCode
The MECM site code which the script should be run against.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A CSV report with the date run appended. "MECM_Report-$(Get-Date -Format FileDate).csv"
## NOTES

## RELATED LINKS
