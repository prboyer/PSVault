---
Author: Paul Boyer
external help file:
Module Guid: 2e905317-62e7-4b00-bc0e-a8039e418e68
Module Name: PSVault-Windows10
online version:
schema: 2.0.0
---

# Update-Windows10

## SYNOPSIS
Script that facilitates an online (running OS) upgrade of Windows 10 given a setup file from an expanded ISO

## SYNTAX

### Update
```
Update-Windows10 -SetupFile <String> [-LogDir <String>] [-NoDynamicUpdate] [-AnswerFile <String>]
 [-ConfigFile <String>] [-Quiet] [-BitLocker <String>] [<CommonParameters>]
```

### ScanCompat
```
Update-Windows10 -SetupFile <String> [-LogDir <String>] [-ScanCompat] [-Quiet] [<CommonParameters>]
```

### AnswerFile
```
Update-Windows10 -SetupFile <String> [-LogDir <String>] [-NoDynamicUpdate] -AnswerFile <String> [-Quiet]
 [-BitLocker <String>] [<CommonParameters>]
```

### ConfigFile
```
Update-Windows10 -SetupFile <String> [-LogDir <String>] [-NoDynamicUpdate] -ConfigFile <String> [-Quiet]
 [-BitLocker <String>] [<CommonParameters>]
```

## DESCRIPTION
After extracting the contents of an ISO of a new version of Windows 10, this script can utilize the setup.exe file to perform
and upgrade to an online (running) system.

## EXAMPLES

### EXAMPLE 1
```
Update-Windows10 -SetupFile "D:\Setup.exe" -ScanCompat
```

### EXAMPLE 2
```
Update-Windows10 -SetupFile "D:\Setup.exe"
```

### EXAMPLE 3
```
Update-Windows10 -SetupFile "D:\Setup.exe" -Quiet -LogDir "\\fs1\share\Logs\Update"
```

### EXAMPLE 4
```
Update-Windows10 -SetupFile "D:\Setup.exe" -NoDynamicUpdate -ConfigFile "\\fs1\share\UpdateConfig.ini" -BitLocker "ForceKeepActive" -Quiet
```

## PARAMETERS

### -SetupFile
Path to the "Setup.exe" file extracted from the ISO.

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

### -LogDir
Path to a directory where logs from the upgrade process should be copied.

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

### -ScanCompat
Switch to scan for current machine's compatibility with the upgrade.
Provides a report of any incompatibilities.
This does not perform the upgrade.

```yaml
Type: SwitchParameter
Parameter Sets: ScanCompat
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoDynamicUpdate
Switch to disable Dynamic Update functionality during the upgrade process.
By default, new updates will be installed at upgrade time.

```yaml
Type: SwitchParameter
Parameter Sets: Update, AnswerFile, ConfigFile
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AnswerFile
To use an AnswerFile and perform the update in unattended mode, supply the path to the XML answer file.

```yaml
Type: String
Parameter Sets: Update
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: AnswerFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigFile
To use a configuration file, provide the path to the INI config file.
Settings in the config file will override those specified in the command line

```yaml
Type: String
Parameter Sets: Update
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ConfigFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
Switch parameter to perform the upgrade silently without user interaction.

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

### -BitLocker
String parameter as to how the upgrade should handle machines protected by BitLocker.
By default, the upgrade will try to keep BitLocker active.

```yaml
Type: String
Parameter Sets: Update, AnswerFile, ConfigFile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Paul Boyer - 2-11-2021

## RELATED LINKS

[https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options)

