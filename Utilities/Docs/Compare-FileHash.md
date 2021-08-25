---
Author: Paul Boyer
external help file: psvault-Utilities-help.xml
Module Guid: b2069617-078d-4bc3-bea3-3a5a2b8c694b
Module Name: psvault-Utilities
online version:
schema: 2.0.0
---

# Compare-FileHash

## SYNOPSIS
Quick script to compare file hashes of contents between two directories

## SYNTAX

```
Compare-FileHash [-DifferenceDirectory] <String> [-ReferenceDirectory] <String> [[-Algorithm] <String>]
 [[-Recurse] <ParameterAttribute>] [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Script get the child items in each directory (recursing if necessary) and then hashes each file.
Then the two sets of file hashes are compared using
Compare-Object.
The results can be piped out to a file.

## EXAMPLES

### EXAMPLE 1
```
Compare-FileHash -ReferenceDirectory C:\Windows -DifferenceDirectory D:\Windows -Recurse
```

## PARAMETERS

### -DifferenceDirectory
Path to the directory to compare as the right operand (=\>)

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

### -ReferenceDirectory
Path to the directory to compare as the left operand (\<=)

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

### -Algorithm
String parameter for which algorithm to use to compute hashes.
Accepted values are SHA1, SHA256, SHA384, SHA512, MD5

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

### -Recurse
Switch parameter that will cause the reference and difference directories to recurse through all files, not just at the depth that was passed

```yaml
Type: ParameterAttribute
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to the output file

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A .txt file with results of the comparison operations piped out using Tee-Object
## NOTES

## RELATED LINKS
