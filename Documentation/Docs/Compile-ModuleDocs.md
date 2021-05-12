---
Author: Paul Boyer
external help file: PSVault-Documentation-help.xml
Module Guid: f161ba1f-1962-435c-b32c-8433dc61b203
Module Name: PSVault-Documentation
online version:
schema: 2.0.0
---

# Compile-ModuleDocs

## SYNOPSIS
Script that updates the README file on the front page.

## SYNTAX

```
Compile-ModuleDocs [-Path] <String> [-OutFile] <String> [<CommonParameters>]
```

## DESCRIPTION
Script pulls data from the individual README files in each folder and consolidates them into one README for the front page.
Script
also changes the paths in the consolidated file so that they can be resolved from the front page.

## EXAMPLES

### EXAMPLE 1
```
Compile-ModuleDocs -Path C:\Scripts -OutFile C:\Scripts\Readme.md
```

## PARAMETERS

### -Path
Path to working directory containing sub-folders with scripts and README files.

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

### -OutFile
Path to where the consolidated file should be saved.

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
Author: Paul Boyer
Date: 5-12-21

## RELATED LINKS
