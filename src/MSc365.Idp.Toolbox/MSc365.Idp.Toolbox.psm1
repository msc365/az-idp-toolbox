[CmdletBinding()]
param()

Write-Verbose $PSScriptRoot
Write-Verbose 'Import all modules in sub folders'

foreach ($folder in @('private', 'public')) {
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder

    if (Test-Path -Path $root) {
        Write-Verbose ('  Processing folder {0}' -f $folder)
        $files = Get-ChildItem -Path $root -Filter *.ps1

        # dot source each file
        $files | Where-Object { $_.name -notlike '*.Tests.ps1' } |
            ForEach-Object { Write-Verbose ('  - {0}' -f $_.basename); . $_.FullName }
    }
}
