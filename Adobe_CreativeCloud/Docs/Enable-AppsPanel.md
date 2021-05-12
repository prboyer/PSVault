---
Author: Paul Boyer
external help file: PSVault-Adobe_CreativeCloud-help.xml
Module Guid: 4308007e-471a-43bb-a4a2-95c3ec3bf358
Module Name: PSVault-Adobe_CreativeCloud
online version:
schema: 2.0.0
---

# Enable-AppsPanel

## SYNOPSIS
Quickly resolve the Adobe Creative Cloud Desktop app displaying a "You don't have access to manage apps" message

## SYNTAX

```
Enable-AppsPanel [-Disable] [-NoRevert] [<CommonParameters>]
```

## DESCRIPTION
Script automates the process of updating the configuration XML file or DB file (version dependent) to resolve the apps list issue.
This is accomplished
    with some simple string manipulation and content get/set methods (or forced regeneration of the database file).

## EXAMPLES

### EXAMPLE 1
```
Enable-AppsPanel -Disable
```

### EXAMPLE 2
```
Enable-AppsPanel -NoRevert
```

## PARAMETERS

### -Disable
Parameter that is used to modify behavior of the XML file manipulaiton.
When specified, the parameter will cause the script to disable the apps panel rather
than enable it.

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

### -NoRevert
Changes the behavior of the DB file manipulation.
Rather than appending a ".old" to the DB file in %LOCALAPPDATA%, the switch will cause the old DB file to be removed.

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
Script written by Paul B 10-16-2020

## RELATED LINKS

[https://helpx.adobe.com/uk/creative-cloud/kb/apps-panel-reflect-creative-cloud.html](https://helpx.adobe.com/uk/creative-cloud/kb/apps-panel-reflect-creative-cloud.html)

[https://kb.wisc.edu/page.php?id=99743](https://kb.wisc.edu/page.php?id=99743)

