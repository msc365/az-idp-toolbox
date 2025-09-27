#requires -Version 5.1

# Get public and private function definition files
$public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Import all functions
foreach ($import in @($public + $private)) {
    try {
        Write-Verbose "Importing $($import.FullName)"
        . $import.FullName
    } catch {
        Write-Error "Failed to import function $($import.FullName): $_"
        throw
    }
}

# Export only public functions
Export-ModuleMember -Function $public.BaseName -Verbose:$false

# Module cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
    # Cleanup when module is removed
    Write-Verbose 'Cleaning up module resources'
}
