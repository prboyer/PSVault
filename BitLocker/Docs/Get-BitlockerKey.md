---
Author: Paul Boyer
external help file: PSVault-BitLocker-help.xml
Module Guid: a4cc3f60-0be8-4abd-90f6-78845d0c3e76
Module Name: PSVault-BitLocker
online version:
schema: 2.0.0
---

# Get-BitlockerKey

## SYNOPSIS
Script that runs a report against your AD instance to query for escrowed Bitlocker recovery keys.

## SYNTAX

```
Get-BitlockerKey [-SearchBase] <String> [-All] [-NoKey] [[-FilePath] <String>] [<CommonParameters>]
```

## DESCRIPTION
The script can be used to generate a report of computers in your AD domain that have had their
Bitlocker recovery keys escrowed to AD.
The report can be modified (with parameters) to show data for only machines with 
missing keys and can also write out the results to a CSV.

## EXAMPLES

### EXAMPLE 1
```
Get-BitlockerKey -SearchBase "DC=corp,DC=contoso,DC=com" -FilePath "C:\BitlockerReport.csv"
```

## PARAMETERS

### -SearchBase
The DistinguishedName of the starting point for the search.
You can enter the DN of an OU or just the root of the domain to
search for all machines

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

### -All
"All" will return results for all machines, whether there is an escrowed key or not.
By default, the report only returns
results for machines with keys (null keys are excluded).

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

### -NoKey
Only returns a list of machines with null recovery keys.

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

### -FilePath
The filepath where the CSV file should be saved.
Validation in script confirms that filepath is passed with .CSV extension.

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

## NOTES
Author: Paul Boyer
Date: 7-7-2020

Script adopted from https://social.technet.microsoft.com/Forums/en-US/fbb2135e-e3ce-4eb0-8ddc-ff9f3d0b0158/ad-objects-without-bitlocker-keys-stored-in-ad?forum=winserverDS

## RELATED LINKS
