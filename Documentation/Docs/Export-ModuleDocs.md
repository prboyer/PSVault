---
Author: Paul Boyer
external help file: PSVault-Documentation-help.xml
Module Guid: f161ba1f-1962-435c-b32c-8433dc61b203
Module Name: PSVault-Documentation
online version:
schema: 2.0.0
---

# Export-ModuleDocs

## SYNOPSIS
Script used for generating Markdown documentation for PowerShell files.

## SYNTAX

### Module_Prefix
```
Export-ModuleDocs -Path <String> [-ModulePrefix <String>] [-Exclude <String[]>] [-Version <String>] [-Prune]
 [<CommonParameters>]
```

### Description_String
```
Export-ModuleDocs -Path <String> -ModuleDescription <String> [-Exclude <String[]>] [-Version <String>] [-Prune]
 [<CommonParameters>]
```

### Description_File
```
Export-ModuleDocs -Path <String> [-ModuleDescriptionFile <String>] [-Exclude <String[]>] [-Version <String>]
 [-Prune] [<CommonParameters>]
```

### MarkdownFiles_Path
```
Export-ModuleDocs -Path <String> -MarkdownFilesPath <String> [-Exclude <String[]>] [-Version <String>] [-Prune]
 [<CommonParameters>]
```

### NoClobber
```
Export-ModuleDocs -Path <String> [-Exclude <String[]>] [-NoClobber] -ModuleFilePath <String>
 [-Version <String>] [-Prune] [<CommonParameters>]
```

### Module_NoPrefix
```
Export-ModuleDocs -Path <String> [-Exclude <String[]>] [-NoModulePrefix] [-Version <String>] [-Prune]
 [<CommonParameters>]
```

## DESCRIPTION
The script leverages the PlatyPS module to generate Markdown files for each PS1 file as well as for the whole module.
The script also generates a relatively-pathed PSM1 file, and complimentary PSD1 file.

## EXAMPLES

### EXAMPLE 1
```
Export-ModuleDocs -Path ".\Windows10" -ModuleDescription "Windows 10 PowerShell Scripts"
```

### EXAMPLE 2
```
Export-ModuleDocs -Path ".\Windows10" -ModuleDescriptionFile ".\Windows10\Description.txt"
```

### EXAMPLE 3
```
Export-ModuleDocs -Path ".\Windows10" -ModuleDescription "Windows 10 PowerShell Scripts" -MarkdownFilesPath ".\Windows10\Markdown" -NoModulePrefix
```

### EXAMPLE 4
```
Export-ModuleDocs -Path ".\Windows10" -ModuleDescription "Windows 10 PowerShell Scripts" -NoCobber -ModuleFilePath ".\Windows10\Module.psm1" -NoModulePrefix
```

## PARAMETERS

### -Path
Path to the directory containing PowerShell (PS1) files to generate documentation for.

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

### -ModulePrefix
String to be pre-fixed to the beginning of the generated PSM1,PSD1, and used in the ReadMe file.

```yaml
Type: String
Parameter Sets: Module_Prefix
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleDescription
The description that should be used in the PSD1 file and ReadMe file for the Module.

```yaml
Type: String
Parameter Sets: Description_String
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleDescriptionFile
Path to a file containing the description that should be used in the PSD1 file and ReadMe file for the Module.
Optionally, specify an empty string (""), and 
the script will attempt to use the "$Path\Description.txt" to get the Module description.
This is helpful for keeping the same description in place when updating
documentation through multiple revisions.

```yaml
Type: String
Parameter Sets: Description_File
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MarkdownFilesPath
Path to the directory where Markdown files for each PS1 script should be stored.
By default, the script will save the files to $Path\Docs

```yaml
Type: String
Parameter Sets: MarkdownFiles_Path
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude
String array of paths to exclude when getting PowerShell (PS1) files to document.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoClobber
No not overwrite existing PSM1 and PSD1 files.
A value must be supplied for -ModuleFilePath in order to user -NoClobber

```yaml
Type: SwitchParameter
Parameter Sets: NoClobber
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleFilePath
Path to the existing module file.
Script is expecting a PSM1 file.

```yaml
Type: String
Parameter Sets: NoClobber
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoModulePrefix
Switch to exclude application of a module prefix to the beginning of the generated PSM1,PSD1, and used in the ReadMe file.

```yaml
Type: SwitchParameter
Parameter Sets: Module_NoPrefix
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
Specify a string to represent the revision of the help documentation.
This will also be applied to the PSD1 manifest file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prune
{{ Fill Prune Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Paul Boyer
Date: 5-11-2021

## RELATED LINKS

[https://github.com/PowerShell/platyPS](https://github.com/PowerShell/platyPS)

[https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/create-help-using-platyps?view=powershell-7.1](https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/create-help-using-platyps?view=powershell-7.1)

