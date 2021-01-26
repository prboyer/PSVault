# Bitlocker Scripts
A collection of scripts for managing and administering Bitlocker

## Get-BitlockerKey
> [!Important]
> The script needs to be run as a user who has the 
> appropriate ACLs to view Bitlocker Recovery 
> passwords from AD. If possible, try running the script
>at the Domain Admin level or similar.

:::code language="text" source="Get-BitlockerKey.ps1" range="3-30":::

The secret sauce in getting the Bitlocker Recovery Key lies in-
```powershell
(Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $x.DistinguishedName -Properties 'msFVE-RecoveryPassword' | Select-Object -Last 1).'msFVE-RecoveryPassword'
```