<#
.SYNOPSIS
    Build script for PowerShell module.

.DESCRIPTION
    This script uses the PSake build automation tool to define tasks for building, testing,
    and publishing PowerShell modules. It includes tasks for cleaning the build directory,
    running unit tests, and packaging the module for release. The script also handles
    versioning and publishing to the PowerShell Gallery.

.NOTES
    Requires PSake module: Install-Module -Name PSake -Scope CurrentUser -Force
    Requires Pester module: Install-Module -Name Pester -Scope  CurrentUser -Force
#>

# // ----------------- //
# // Module properties //
# // ----------------- //

Properties {
    # The current release version of the module.
    $script:buildVersion = [System.Version]'0.2.0'

    # Pre-release label (e.g. 'alpha1', 'beta1', 'rc1'). Set to $null for stable releases.
    $script:prerelease = $null # 'alpha1'

    # The root path of the repository.
    $script:rootPath = (Get-Item $PSScriptRoot).Parent.FullName

    # The root path of the source files.
    $script:sourcePath = ('{0}\src' -f $script:rootPath)

    # The name of your module should match the basename of the PSD1 file.
    $validManifest = Get-Item -Path ('{0}\**\*.psd1' -f $script:sourcePath) |
        ForEach-Object {
            $null = Test-ModuleManifest -Path $_ -ErrorAction SilentlyContinue
            if ($?) { $_ }
        }

    if ($validManifest.Length -gt 0) {
        $script:moduleName = $validManifest[0].BaseName
    } else {
        throw ('No valid PowerShell module manifest (.psd1) found in {0}' -f $script:modulePath)
    }

    # The root path of the module to be built.
    $script:modulePath = Join-Path $script:sourcePath -ChildPath $script:moduleName

    # Path to public function script files.
    # Remarks: Set to $null functions reside in the manifest file.
    $script:publicFunctionsPath = Join-Path -Path $script:modulePath -ChildPath 'Public'

    # The directory used to publish the module from.
    $script:releasePath = Join-Path -Path $script:rootPath -ChildPath 'release'
    $script:releaseModulePath = Join-Path -Path $script:releasePath -ChildPath $script:moduleName

    # The path to the module manifest to be built.
    $script:moduleManifestPath = Join-Path -Path $script:modulePath -ChildPath ('{0}.psd1' -f $script:moduleName)

    # The following items will not be copied to the $outputPath.
    # Add items that should not be published with the module.
    $script:exclude = @(
        (Split-Path $PSCommandPath -Leaf),
        # Folders
        'Tests',
        # Files
        'Build.ps1',
        'Settings.ps1',
        'PSScriptAnalyzerSettings.psd1'
    )

    # Repository to publish to, defaults to PSGallery
    $script:repository = 'PSGallery' # or 'LocalGallery'

    # API Key for PowerShell Gallery
    $script:apiKey = $env:PSGalleryApiKey
}

# // ---------------------------- //
# // Publish task implementations //
# // ---------------------------- //

Task PrePublish {
    # Ask feedback before publishing
    $confirmation = Read-Host 'Are you sure you want to publish the module? (Y/N)'
    if ($confirmation -ne 'Y') {
        Write-Information 'Publishing aborted by user.' -InformationAction Continue
        exit 0
    }
}

Task PublishToGallery -RequiredVariables releaseModulePath, repository, apiKey {

    if (-not $script:apiKey) {
        throw 'API Key is required for publishing to PowerShell Gallery'
    }

    $publishParams = @{
        Path        = $script:releaseModulePath
        Repository  = $script:repository
        NuGetApiKey = $script:apiKey
    }

    try {
        Publish-Module @publishParams
    } catch {
        throw $_
    }
}

Task PostPublish {

    $findParams = @{
        Name       = $script:moduleName
        Repository = $script:repository
    }

    # Determine if the version is a prerelease
    if ($null -ne $script:prerelease) {
        $findParams['AllowPrerelease'] = $true
    }

    # Check if module is published
    $cmdlet = Find-Module @findParams -ErrorAction SilentlyContinue

    if ($null -ne $cmdlet) {
        # Verify the published version matches the built version
        $checkVersion = $null -eq $script:prerelease ? $script:buildVersion : ('{0}-{1}' -f $script:buildVersion, $script:prerelease)

        if ($cmdlet.Version -ne $checkVersion) {
            throw ('Published version {0} does not match built version {1}' -f $cmdlet.Version, $checkVersion)
        }
    }
}

# // ------------------------- //
# // Core task implementations //
# // ------------------------- //

Task default -Depends Build

Task Publish -Depends Test, PrePublish, PublishToGallery, PostPublish

Task Test -Depends Build {
    Import-Module Pester -PassThru | Out-Null
    Invoke-Pester (Join-Path $script:modulePath -ChildPath 'Tests') -Output Detailed
}

Task Build -Depends Clean, Init -RequiredVariables sourcePath, releasePath, exclude, moduleName, buildVersion {

    # Copy all items except excluded files and folders
    Get-ChildItem -Path ('{0}\*' -f $script:sourcePath) -Exclude $script:exclude | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $script:releaseModulePath -Recurse -Force
    }

    # Update version, prerelease, and functionToExport in manifest
    if ($script:publicFunctionsPath) {
        if ((Test-Path -Path $script:publicFunctionsPath) -and ($publicFunctionNames = Get-ChildItem -Path ('{0}\*.ps1' -f $script:publicFunctionsPath) |
                    Select-Object -ExpandProperty BaseName)) {
            $functionsToExport = $publicFunctionNames
        } else {
            $functionsToExport = $null
        }
    }

    $updateParams = @{
        Path              = (Join-Path -Path $script:releaseModulePath -ChildPath ('{0}.psd1' -f $script:moduleName))
        ModuleVersion     = $script:buildVersion
        FunctionsToExport = $functionsToExport
    }

    if ($null -ne $script:prerelease) {
        $updateParams['Prerelease'] = $script:prerelease
    }

    Update-PSModuleManifest @updateParams -ErrorAction Stop
}

Task Clean -RequiredVariables releasePath {
    # Sanity check the dir we are about to "clean".  If $releasePath were to
    # inadvertently get set to $null, the Remove-Item command removes the
    # contents of \*.  That's a bad day!
    if ((Test-Path $releasePath) -and $releasePath.Contains($rootPath)) {
        Remove-Item $releasePath -Recurse -Force
    }
}

Task Init -Depends Validate -RequiredVariables releasePath {
    if (!(Test-Path $releasePath)) {
        New-Item $releasePath -ItemType Directory | Out-Null
    }
}

Task Validate {
    Assert ($buildVersion -ne $null) 'buildVersion should not be null'
    Assert ($rootPath -ne $null) 'rootPath should not be null'
    Assert ($moduleName -ne $null) 'moduleName should not be null'
}
