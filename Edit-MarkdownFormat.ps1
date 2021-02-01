function Edit-MarkdownFormat {
    param (
        [Parameter (Mandatory=$true)][String]$MarkdownFile,
        [Parameter (Mandatory=$false)][String]$OutputFile
    )

    $file = Get-Content -Raw $MarkdownFile 
    #$file = $file.Remove($file.IndexOf('---'),3);
    $file = $file.Remove($file.IndexOf('---'),3)
    $file = $file.Remove(0,$file.IndexOf('---')+3).TrimStart('`n')

    $file 

    
    
}
Edit-MarkdownFormat -MarkdownFile .\test_md_file.md