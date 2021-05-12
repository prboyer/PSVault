---
Author: Paul Boyer
external help file: PSVault-Bitlocker-help.xml
Module Guid: 096fdbd4-6b80-4ec9-9a6f-0cabd9c44496
Module Name: PSVault-Bitlocker
online version:
schema: 2.0.0
---

# Activate-BitLocker

## SYNOPSIS
Script for manually activating BitLocker on Windows 10 machines

## SYNTAX

```
Activate-BitLocker [-ComputerNames] <String[]> [[-Credential] <PSCredential>] [[-LogFile] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Runs the BitLocker PowerShell cmdlet on each machine in the -ComptuerNames string array as a remote job.

## EXAMPLES

### EXAMPLE 1
```
Activate-BitLocker -ComputerNames "desktop01","desktop02" -LogFile "\\winfs1\share1\log.txt"
```

## PARAMETERS

### -ComputerNames
String array of computer names for which BitLocker needs to be enabled

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
A PSCredential object for authenticating remote sessions

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFile
Path to write out the log file.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Paul Boyer - 2-24-21

## RELATED LINKS

[https://docs.microsoft.com/en-us/powershell/module/bitlocker/enable-bitlocker?view=win10-ps](https://docs.microsoft.com/en-us/powershell/module/bitlocker/enable-bitlocker?view=win10-ps)

[https://docs.microsoft.com/en-us/powershell/module/bitlocker/enable-bitlocker?view=win10-ps](https://docs.microsoft.com/en-us/powershell/module/bitlocker/enable-bitlocker?view=win10-ps)

[https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_remote_jobs?view=powershell-7.1](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_remote_jobs?view=powershell-7.1)

