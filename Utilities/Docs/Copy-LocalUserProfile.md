---
Author: Paul Boyer
external help file: PSVault-Utilities-help.xml
Module Guid: 8ce86084-d7bb-482e-9729-9d3048ff0c61
Module Name: PSVault-Utilities
online version:
schema: 2.0.0
---

# Copy-LocalUserProfile

## SYNOPSIS
A custom cmdlet for quickly copying the contents of a user's profile to another location using ROBOCOPY.

## SYNTAX

```
Copy-LocalUserProfile [-SourcePath] <String> [-TargetPath] <String> [[-LogFile] <String>]
 [[-WaitDelay] <Int32>] [-NoRetry] [[-RobocopyArguments] <String>] [[-ExcludeDirs] <String[]>]
 [[-ExcludeFiles] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
PowerShell implementation of Robocopy with standardized parameters.
Additional Robocopy arguments can be passed in the
-RobocopyArguments parameter.

## EXAMPLES

### EXAMPLE 1
```
Copy-LocalUserProfile -SourcePath C:\Users\Paul -TargetPath C:\Users\NewPaul
```

## PARAMETERS

### -SourcePath
Path to the source user profile with files to copy

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

### -TargetPath
Path to the destination user profile where files should be copy to

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

### -LogFile
Path to the log file where Robocopy should write progress to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WaitDelay
Integer for the amount of time that Robocopy should wait before retrying copy

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoRetry
Switch to disable Robocopy from retrying a failed copy

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

### -RobocopyArguments
Additional arguments to supply to Robocopy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDirs
Additional directory names to exclude

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeFiles
Additional file names to exclude

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
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
Date: 11-17-2020

## RELATED LINKS
