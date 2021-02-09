---
Author: Paul Boyer
external help file: PSVault-ActiveDirectory-help.xml
Module Guid: 18f15d31-8ea0-4a67-bb67-09c9554871ae
Module Name: PSVault-ActiveDirectory
online version:
schema: 2.0.0
---

# Get-ComputerData

## SYNOPSIS
Cmdlet to quickly return information about a AD-joined computer

## SYNTAX

```
Get-ComputerData [-ComputerName] <String> [[-Path] <ParameterAttribute>] [<CommonParameters>]
```

## DESCRIPTION
Script returns:
- Operating System
- Operating System Version
- Hardware Vendor
- Hardware Model
- Serial Number
- Last logged on user
- Last logon date & time

This is returned to standard out.
Optionally, the information can be exported to a CSV by supplying a value to -Path.

## EXAMPLES

### EXAMPLE 1
```
Get-ComputerData -ComputerName Computer001
```

### EXAMPLE 2
```
Get-ComputerDate -ComputerName Computer001 -Path C:\Temp
```

### EXAMPLE 3
```
Get-ComputerData -ComputerName Comp
```

## PARAMETERS

### -ComputerName
Required.
The name of the computer for which the script should query for information.
The script does a wildcard lookup so partial names for the parameter are acceptable.

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

### -Path
Path to save an output file.
The script will automatically supply a file name with a *.CSV extension.
Includes datestamp in file name.

```yaml
Type: ParameterAttribute
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
This script pulls custom attributes from AD DS.
The Model, Hardware Vendor, Last Logged On User, and Last Logged On User Date & Time are custom attributes from the AD DS environment the script was composed in.
YMMV when using this script in other environments without these fields.

## RELATED LINKS
