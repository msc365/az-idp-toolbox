<#
.SYNOPSIS
Build and optionally publish a PowerShell module to PowerShell Gallery.

.DESCRIPTION
This script builds a PowerShell module, validates its manifest, runs tests, packages it, and optionally publishes it to the PowerShell Gallery.

.PARAMETER Version
The version to build, following semantic versioning (e.g., 1.0.0 or 1.0.0-beta1).

.PARAMETER Repository
The repository to publish to. Defaults to 'PSGallery'.

.PARAMETER ApiKey
The API key for the PowerShell Gallery. Required if publishing.

.PARAMETER Publish
Switch to indicate whether to publish the module after building.

.OUTPUTS
None. Outputs status messages to the console.

.EXAMPLE
    .\build\build.ps1 -Version 0.1.0-prev1
#>
[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Version to build (e.g., 1.0.0, 1.0.0-rc1, 1.0.0-beta).')]
    [string]$Version,

    [Parameter(HelpMessage = 'Repository to publish to, defaults: PSGallery')]
    [string]$Repository = 'PSGallery',

    [Parameter(HelpMessage = 'API Key for PowerShell Gallery')]
    [string]$ApiKey = $env:PSGalleryApiKey,

    [Parameter(HelpMessage = 'Publish to PowerShell Gallery')]
    [switch]$Publish
)

begin {
    Write-Debug ('{0} entered' -f $MyInvocation.MyCommand)

    # Module information
    $rootPath = (Get-Item -Path $PSScriptRoot).Parent.FullName

    $moduleName = 'MSc365.Idp.Toolbox'
    $modulePath = Join-Path -Path $rootPath -ChildPath $moduleName
    $manifestPath = Join-Path -Path $modulePath -ChildPath ('{0}.psd1' -f $moduleName)
    $outputPath = (Join-Path -Path $rootPath -ChildPath 'output')
}

process {
    try {
        $ErrorActionPreference = 'Stop'

        # Validate semantic versioning format
        $versionRegex = '^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)(?:-(?<prerelease>[\w\d\-\.]+))?$'
        if ($Version -notmatch $versionRegex) {
            throw 'Invalid version format. Use semantic versioning (e.g., 1.0.0 or 1.0.0-beta1)'
        }

        $prereleaseTag = $Matches.prerelease
        $isPrerelease = $null -ne $prereleaseTag

        Write-Host '[-- Build Script for PowerShell Module --]' -ForegroundColor Yellow
        Write-Host ('Module.....: {0}' -f $moduleName) -ForegroundColor Cyan
        Write-Host ('Version....: {0}' -f $Version) -ForegroundColor Cyan
        Write-Host ''

        # Validate module structure
        if (-not (Test-Path $manifestPath)) {
            throw ('Module manifest not found: {0}' -f $manifestPath)
        }

        # Test module manifest
        Test-ModuleManifest -Path $manifestPath -ErrorAction Stop | Out-Null
        Write-Host '✓ Module manifest is valid' -ForegroundColor Green

        # Run Pester tests
        $testsPath = ('{0}\Tests' -f $modulePath)
        if (Test-Path $testsPath) {
            $testResults = Invoke-Pester -Path $testsPath -PassThru -Verbose:$false

            if ($testResults.FailedCount -gt 0) {
                throw ('Tests failed: {0} failed out of {1}' -f $testResults.FailedCount, $testResults.TotalCount)
            }

            Write-Host ('✓ All tests passed ({0} tests)' -f $testResults.TotalCount) -ForegroundColor Green
        } else {
            Write-Warning ('No tests found in {0}' -f $testsPath)
        }

        # Handle prerelease in PrivateData
        if ($isPrerelease) {
            # Check if prerelease tag is available in manifest
            $manifestContent = Get-Content -Path $manifestPath -Raw

            # Check if any prerelease (uncommented only) is available
            $hasAnyPrerelease = $manifestContent -match "(?m)^\s*Prerelease\s*=\s*'[^']*'"

            if (-not $hasAnyPrerelease) {
                Write-Error 'Prerelease tag is missing in manifest'
                throw
            }

            # Check if there's an active (uncommented) prerelease and validate tag match
            if ($manifestContent -match "(?m)^\s*Prerelease\s*=\s*'(?<tag>.*)'") {
                $existingTag = $Matches.tag
                if ($existingTag -ne $prereleaseTag) {
                    Write-Error ('Prerelease tag mismatch, manifest has "{0}", but version specified "{1}"' -f $existingTag, $prereleaseTag)
                    throw
                }
            }
            # If prerelease is only commented out, we allow the build to proceed
            Write-Host '✓ Prerelease tag is valid and matches the specified version' -ForegroundColor Green
        }

        # Create output directory
        if (-not (Test-Path $outputPath)) {
            New-Item -Path $outputPath -ItemType Directory -Force | Out-Null
        }

        # Clean up output directory
        if (Test-Path $outputPath) {
            Remove-Item -Path ('{0}\*' -f $outputPath) -Recurse -Force
        }

        # Copy module files to output directory (excluding Tests folder)
        $outputModulePath = ('{0}\{1}' -f $outputPath, $moduleName)

        # Create the output module directory
        New-Item -Path $outputModulePath -ItemType Directory -Force | Out-Null

        # Build exclude list - always exclude Tests, conditionally exclude empty Private folder
        $excludeList = @('Tests')
        $privateFolderPath = Join-Path -Path $modulePath -ChildPath 'Private'
        if ((Test-Path $privateFolderPath) -and ((Get-ChildItem -Path $privateFolderPath -Recurse).Count -eq 0)) {
            $excludeList += 'Private'
        }

        # Copy all items except excluded folders
        Get-ChildItem -Path $modulePath -Exclude $excludeList | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $outputModulePath -Recurse -Force
        }

        Write-Host '✓ Module files copied' -ForegroundColor Green

        # Validate final module
        Test-ModuleManifest -Path ('{0}\{1}.psd1' -f $outputModulePath, $moduleName) -ErrorAction Stop | Out-Null
        Write-Host '✓ Final module manifest is valid' -ForegroundColor Green

        # Package the module
        Compress-Archive -Path ('{0}\*' -f $outputModulePath) -DestinationPath ('{0}\{1}.zip' -f $outputPath, $moduleName) -Force
        Write-Host ('✓ Created module packaged: {0}.zip' -f $moduleName) -ForegroundColor Green

        # Publish to PowerShell Gallery
        if ($Publish) {
            if (-not $ApiKey) {
                throw 'API Key is required for publishing to PowerShell Gallery'
            }

            $publishParams = @{
                Path        = $outputModulePath
                Repository  = $Repository
                NuGetApiKey = $ApiKey
            }

            # Add AllowPrerelease for prerelease versions
            Write-Host "Publishing to $Repository..." -ForegroundColor Yellow
            if ($isPrerelease) {
                Write-Warning "Publishing PRERELEASE version $Version"
                Write-Host 'Users will need to use -AllowPrerelease flag to install this version' -ForegroundColor Yellow
            }

            try {
                Publish-Module @publishParams
                Write-Host '✓ Module published successfully!' -ForegroundColor Green
            } catch {
                Write-Error "Failed to publish: $_"
                throw
            }
        }

        Write-Host '[-- Build completed successfully! --]' -ForegroundColor Yellow

        # Show installation commands
        if ($Version) {
            Write-Host ''
            Write-Host ('{0} installation commands:' -f $Repository) -ForegroundColor Cyan
            if ($isPrerelease) {
                Write-Host '  # Install latest prerelease:' -ForegroundColor Gray
                Write-Host ('  Install-Module -Name {0} -AllowPrerelease' -f $moduleName) -ForegroundColor White
                Write-Host ''
                Write-Host '  # Install specific version:' -ForegroundColor Gray
                Write-Host ('  Install-Module -Name {0} -RequiredVersion {1} -AllowPrerelease' -f $moduleName, $Version) -ForegroundColor White
            } else {
                Write-Host '  # Install latest stable:' -ForegroundColor Gray
                Write-Host ('  Install-Module -Name {0}' -f $moduleName) -ForegroundColor White
                Write-Host ''
                Write-Host '  # Install specific version:' -ForegroundColor Gray
                Write-Host ('  Install-Module -Name {0} -RequiredVersion {1}' -f $moduleName, $Version) -ForegroundColor White
            }

            Write-Host ''
            Write-Host 'Local import commands:' -ForegroundColor Cyan
            Write-Host '  # Import from local path:' -ForegroundColor Gray
            Write-Host ('  Import-Module -Name .\output\{0} -Force' -f $moduleName) -ForegroundColor White
            Write-Host ''
            Write-Host '  # Verify module import:' -ForegroundColor Gray
            Write-Host ('  Get-Module -Name {0}' -f $moduleName) -ForegroundColor White
            Write-Host ''
            Write-Host '  # Remove module:' -ForegroundColor Gray
            Write-Host ('  Remove-Module -Name {0} -Force' -f $moduleName) -ForegroundColor White
        }
        Write-Host ''

    } catch {
        throw $_
    }
}

end {
    Write-Debug ('{0} exited' -f $MyInvocation.MyCommand)
}
