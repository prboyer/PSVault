function Compare-FileHash {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER DifferenceDirectory
    Parameter description
    
    .PARAMETER ReferenceDirectory
    Parameter description
    
    .PARAMETER Algorithm
    Parameter description
    
    .PARAMETER Recurse
    Parameter description
    
    .PARAMETER Path
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
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
        $DifferenceHashes = Get-ChildItem $DifferenceDirectory -File -Recurse| %{Get-FileHash -Algorithm $Algo -Path $_.FullName}
        $ReferenceHashes = Get-ChildItem $ReferenceDirectory -File -Recurse | %{Get-FileHash -Algorithm $Algo -Path $_.FullName}
    }else{
        $DifferenceHashes = Get-ChildItem $DifferenceDirectory -File | %{Get-FileHash -Algorithm $Algo -Path $_.FullName}
        $ReferenceHashes = Get-ChildItem $ReferenceDirectory -File | %{Get-FileHash -Algorithm $Algo -Path $_.FullName}
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