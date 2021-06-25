function Compare-FileHash {
    <#
    .SYNOPSIS
    Quick script to compare file hashes of contents between two directories

    .DESCRIPTION
    Script get the child items in each directory (recursing if necessary) and then hashes each file. Then the two sets of file hashes are compared using
    Compare-Object. The results can be piped out to a file.

    .PARAMETER DifferenceDirectory
    Path to the directory to compare as the right operand (=>)

    .PARAMETER ReferenceDirectory
    Path to the directory to compare as the left operand (<=)

    .PARAMETER Algorithm
    String parameter for which algorithm to use to compute hashes. Accepted values are SHA1, SHA256, SHA384, SHA512, MD5

    .PARAMETER Recurse
    Switch parameter that will cause the reference and difference directories to recurse through all files, not just at the depth that was passed

    .PARAMETER Path
    Path to the output file

    .OUTPUTS
    A .txt file with results of the comparison operations piped out using Tee-Object

    .EXAMPLE
    Compare-FileHash -ReferenceDirectory C:\Windows -DifferenceDirectory D:\Windows -Recurse

    .NOTES

    #>
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DifferenceDirectory,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ReferenceDirectory,
        [Parameter()]
        [ValidateSet("SHA1","SHA256","SHA384","SHA512","MD5")]
        [String]
        $Algorithm,
        [Parameter]
        [switch]
        $Recurse,
        [Parameter()]
        [String]
        $Path
    )

    # Determine the comparison algorithm. Default is MD5
    [String]$Algo = "MD5"
    if($Algorithm -ne ""){
        $Algo = $Algorithm;
    }

    # Check the hashes of the files in each directory
    if($Recurse){
        $DifferenceHashes = Get-ChildItem $DifferenceDirectory -File -Recurse| ForEach-Object{Get-FileHash -Algorithm $Algo -Path $_.FullName}
        $ReferenceHashes = Get-ChildItem $ReferenceDirectory -File -Recurse | ForEach-Object{Get-FileHash -Algorithm $Algo -Path $_.FullName}
    }else{
        $DifferenceHashes = Get-ChildItem $DifferenceDirectory -File | ForEach-Object{Get-FileHash -Algorithm $Algo -Path $_.FullName}
        $ReferenceHashes = Get-ChildItem $ReferenceDirectory -File | ForEach-Object{Get-FileHash -Algorithm $Algo -Path $_.FullName}
    }

    # Display the results of hashing to the Console and pipe to output file
    if($Path -ne ""){
        $DifferenceHashes + $ReferenceHashes | Format-Table -AutoSize | Tee-Object -FilePath $Path -Append
    }else{
        $DifferenceHashes + $ReferenceHashes | Format-Table -AutoSize
    }

    # Perform comparison
    if($Path -ne ""){
        Compare-Object -ReferenceObject $ReferenceHashes -DifferenceObject $DifferenceHashes -Property Hash | Select-Object Hash,Path,SideIndicator | Tee-Object -FilePath $Path -Append
    }else{
        Compare-Object -ReferenceObject $ReferenceHashes -DifferenceObject $DifferenceHashes -Property Hash -PassThru | Select-Object Hash,Path,SideIndicator
    }
}