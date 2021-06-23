## [Import_GPOs.ps1](https://github.com/AntonyNolan/LegacyPowershellScripts/blob/16ec0ff4d0260923a04be1c3cb231ed89ab11a2a/Import_GPOs.ps1)

### SYNOPSIS
Imports all GPOs from a backup folder into a test domain. Additional GPO information can be imported.
### DESCRIPTION
The script is intended to import backed up GPOs to a test domain. For the additional GPO information
functionality, a backup created by the partner BackUp_GPOs script should be used.
Details:
* Can use a Migration Table to translate domain specific information
* Can import SOM (Scope of Management) Path, Block Inheritance, Link Enabled, Link Order and Enforced
    settings
* Can import and link WMI filters
* If set by the script, 'Block Inheritance' and 'Enforced' settings are highlighted as warnings (yellow) 
    in the script log
Requirements:
* PowerShell GroupPolicy Module
* PowerShell ActiveDirectory Module
* A backup created by partner BackUp_GPOs.ps1 script
* Trace32.exe (SMS Trace) or CMTrace.exe (Configuration Manager Trace Log Tool) to view script log
* SOM paths, e.g. OU heirachy, in target domain matches source domain to reinstate additional information