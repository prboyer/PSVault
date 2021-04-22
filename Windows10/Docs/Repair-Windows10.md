---
Author: Paul Boyer
external help file: PSVault-Windows10-help.xml
Module Guid: 6d706293-1871-4665-9352-f76639c14553
Module Name: PSVault-Windows10
online version: https://support.microsoft.com/en-us/topic/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files-79aa86cb-ca52-166a-92a3-966e85d4094e
schema: 2.0.0
---

# Repair-Windows10

## SYNOPSIS
Script of repair tools and their appropriate parameters for diagnosing Windows 10 issues

## SYNTAX

### dism
```
Repair-Windows10 [-DISM] [-Check] [-Source <String>] [-NoWU] [<CommonParameters>]
```

### defrag
```
Repair-Windows10 [-Check] [-Defrag] [<CommonParameters>]
```

### sfc
```
Repair-Windows10 [-SFC] [<CommonParameters>]
```

### clean
```
Repair-Windows10 [-CleanUp] [-Silent] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
Repair-Windows10 -DISM -SFC
```

## PARAMETERS

### -DISM
Switch to tell the script to run DISM

```yaml
Type: SwitchParameter
Parameter Sets: dism
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Check
When used with -DISM, it will use DISM.exe to check the health of the image.
When used with -Defrag it will check the status of the system drive

```yaml
Type: SwitchParameter
Parameter Sets: dism, defrag
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
File path to a Windows installation directory for system repair.
This is not a path to the online system's Windows directory.

```yaml
Type: String
Parameter Sets: dism
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoWU
Switch when used with -DISM that will prevent downloading repair files from Windows Update

```yaml
Type: SwitchParameter
Parameter Sets: dism
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SFC
Switch to run System File Check

```yaml
Type: SwitchParameter
Parameter Sets: sfc
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CleanUp
Switch to run the system disk cleanup tool

```yaml
Type: SwitchParameter
Parameter Sets: clean
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Silent
Switch to run the system disk cleanup tool silently

```yaml
Type: SwitchParameter
Parameter Sets: clean
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Defrag
Switch to defragment/optimize drives

```yaml
Type: SwitchParameter
Parameter Sets: defrag
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
General notes

## RELATED LINKS

[https://support.microsoft.com/en-us/topic/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files-79aa86cb-ca52-166a-92a3-966e85d4094e](https://support.microsoft.com/en-us/topic/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files-79aa86cb-ca52-166a-92a3-966e85d4094e)

[https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-8.1-and-8/hh824869(v=win.10)?redirectedfrom=MSDN](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-8.1-and-8/hh824869(v=win.10)?redirectedfrom=MSDN)

[https://www.nextofwindows.com/running-disk-cleanup-tool-in-command-line-in-windows-10](https://www.nextofwindows.com/running-disk-cleanup-tool-in-command-line-in-windows-10)

[https://www.geeksinphoenix.com/blog/post/2015/07/19/how-to-defragment-and-optimize-your-drive-in-windows-10.aspx](https://www.geeksinphoenix.com/blog/post/2015/07/19/how-to-defragment-and-optimize-your-drive-in-windows-10.aspx)

