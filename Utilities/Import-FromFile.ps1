function Import-FromFile {
    <#
    .SYNOPSIS
    Script to standardize importing lists from files.
    
    .DESCRIPTION
    The script will take in either at TXT, CSV, or Excel list and process it for use in Powershell. Using 
    parameters, headers can be stripped from the files as necessary.
    
    .PARAMETER TXT
    Path to a *.txt file to process
    
    .PARAMETER HeaderRows
    Int representing the number of rows to remove from the top of the file
    
    .PARAMETER Header
    Int representing the row number of the header
    
    .PARAMETER Column
    If the file is multidimenstional, the Column integer tells the script what range to process
    
    .PARAMETER CSV
    Path to .csv file
    
    .PARAMETER XLS
    Path to .xls or .xlsx file
    
    .PARAMETER WorkbookName
    The name of the Workbook in the Excel file. Only necessary if different than the default "Sheet1".

    .INPUTS
    A .txt, .csv, or .xls(x) file.

    .OUTPUTS
    A string array 
    
    .EXAMPLE
    Import-FromFile -TXT C:\Temp\list.txt
    
    .NOTES
    Paul Boyer 2-25-21
    #>
    param (
        [Parameter(Mandatory=$true, ParameterSetName="Text")]
        [Alias("Text")]
        [ValidateScript({[System.IO.Path]::GetExtension($_) -eq ".txt"})]
        [String]
        $TXT,
        [ValidateRange(1,[Int32]::MaxValue)]
        [Parameter(ParameterSetName="Text")]
        [Parameter(ParameterSetName="Excel")]
        [Int32]
        $HeaderRows,
        [Parameter(ParameterSetName="CSV")]
        [ValidateRange(1,[Int32]::MaxValue)]
        [Int32]
        $Header,
        [Parameter(ParameterSetName="Excel")]
        [Parameter(ParameterSetName="CSV")]
        [ValidateRange(1,[Int32]::MaxValue)]
        [Int32]
        $Column,
        [Parameter(Mandatory=$true, ParameterSetName="CSV")]
        [ValidateScript({[System.IO.Path]::GetExtension($_) -eq ".csv"})]
        [String]
        $CSV,
        [Parameter(Mandatory=$true, ParameterSetName="Excel")]
        [Alias("Excel","XLSX")]
        [ValidateScript({[System.IO.Path]::GetExtension($_) -eq ".xlsx" -or [System.IO.Path]::GetExtension($_) -eq ".xls"})]
        [String]
        $XLS,
        [Parameter(ParameterSetName="Excel",Mandatory=$false)]
        [String]
        $WorkbookName
    )
    #Requires -Modules ImportExcel
    #Requires -Version 5.1
    Import-Module ImportExcel

    [String[]]$ProcessedArray;

    # Begin processing the text file
    if ($TXT -ne "") {
        # Test path
        if (Test-Path $TXT) {
            # Import content from the text file
            $ProcessedArray = [System.IO.File]::ReadAllLines($TXT);
            
            # remove headings
            if ($HeaderRows -gt 0) {
                for ($t = 0; $t -le $HeaderRows; $t++) {
                    $ProcessedArray[$t] = "";
                }
            }
           
        }else{
            Write-Error "Unable to resolve path for text file input."
        }
    }
    
    # Begin processing CSV file
    if($CSV -ne ""){
        # Test path
        if (Test-Path $CSV) {
            # Import content from the CSV file
            
            # parse the header row as a header, not part of the csv file
            ## get the first 5 lines of the csv file, then read the header names from row specified in parameter
            if($Header -gt 0){
                try{
                    [String[]]$head = (Get-Content -Path $CSV -TotalCount 5)[$Header] -split ","
                }catch{
                    Write-Error "Unable to parse headers in the provided CSV file" -ErrorAction Stop -Category ParserError
                }

                # get the column by specified number after reading the headings
                $ProcessedArray = (Import-Csv -Path $CSV -Header $head) | Select-Object $head[$Column]
            }
        }else{
            Write-Error "Unable to resolve path for CSV file input."
        }
    }

    # Begin processing the Excel file
    if ($XLS -ne "") {
        # Test path
        if (Test-Path $XLS) {
            # Set the name of the worksheet if different from the standard default "Sheet1"
            [String]$worksheet
            if ($WorkbookName -ne "") {
                $worksheet = $WorkbookName
            }else{
                $worksheet = "Sheet1"
            }

            # Import the data using Import-Excel module
            $ProcessedArray = @(Import-Excel -Path $XLS -WorksheetName $worksheet -StartRow $HeaderRows -NoHeader -StartColumn $Column -EndColumn $Column -DataOnly)
            
            # Get the data out of an object and into a string array
            $ProcessedArray = $ProcessedArray.P1            
        }else{
            Write-Error "Unable to resolve path for XLS file input."
        }
    }
    return $ProcessedArray   
}