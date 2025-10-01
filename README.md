# Internal Developer Platform (IDP) Toolbox for Azure

[![license](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/msc365/az-idp-toolbox?style=flat&logo=github)](https://github.com/msc365/az-idp-toolbox/releases/latest)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/MSc365.Idp.Toolbox.svg)](https://www.powershellgallery.com/packages/MSc365.Idp.Toolbox)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/MSc365.Idp.Toolbox.svg)](https://www.powershellgallery.com/packages/MSc365.Idp.Toolbox)

This is an experimental PowerShell module providing a comprehensive set of tools for Internal Developer Platforms (IDPs) on Azure cloud over time.

> [!WARNING]
> This module provides experimental features, allowing you to test and provide feedback on new functionalities before they become stable. These features are not finalized and may undergo breaking changes, so they are not recommended for production use.

## Installation

### From PowerShell Gallery (Recommended)

```powershell
# Install for current user
Install-Module -Name MSc365.Idp.Toolbox -Scope CurrentUser -AllowPrerelease -Force

# Install for all users (requires admin)
Install-Module -Name MSc365.Idp.Toolbox -Scope AllUsers -AllowPrerelease -Force
```

### From Source

```powershell
# Clone the repository
git clone https://github.com/msc365/az-idp-toolbox.git
cd az-idp-toolbox

# Import the module
Import-Module -Name .\MSc365.Idp.Toolbox

# Verify the module
Get-Module -Name 'MSc365.Idp.Toolbox'
```

<details>
<summary>Example: Get-Module output</summary>

```text
ModuleType Version    PreRelease Name                ExportedCommands
---------- -------    ---------- ----                ----------------
Script     0.1.0                 MSc365.Idp.Toolbox  New-RandomPassword
```
</details>

## Quick Start

```powershell
# Import the module
Import-Module -Name MSc365.Idp.Toolbox

# Generate a random password with default settings (16 characters, all character types)
$defaultPassword = New-RandomPassword

# Generate a random password with custom settings
$customPassword = New-RandomPassword -Length 32 -IncludeLowercase -IncludeUppercase -IncludeNumeric

# Reveal password
ConvertFrom-SecureString -SecureString $customPassword -AsPlainText
```

## Requirements

- **PowerShell**: 7.4 or later

## Development

### Building the Module

```powershell
# Run tests
Invoke-psake .\src\build.ps1 -taskList Test

# Build module
Invoke-psake .\src\build.ps1 -taskList Build

# Build and publish
Invoke-psake .\src\build.ps1 -taskList Publish
```
