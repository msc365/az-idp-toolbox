# Internal Developer Platform (IDP) Toolbox for Azure

[![license](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/az.idp.toolbox.svg)](https://www.powershellgallery.com/packages/az.idp.toolbox)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/az.idp.toolbox.svg)](https://www.powershellgallery.com/packages/az.idp.toolbox)

An experimental PowerShell module providing a comprehensive set of tools for Internal Developer Platforms (IDPs) on Azure cloud.

> [!WARNING]
> This module provides experimental features, allowing you to test and provide feedback on new functionalities before they become stable. These features are not finalized and may undergo breaking changes, so they are not recommended for production use.

## Installation

### From PowerShell Gallery (Recommended)

```powershell
# Install for current user
Install-Module -Name Az.Idp.Toolbox -Scope CurrentUser -AllowPrerelease -Force

# Install for all users (requires admin)
Install-Module -Name Az.Idp.Toolbox -Scope AllUsers -AllowPrerelease -Force
```

### From Source

```powershell
# Clone the repository
git clone https://github.com/msc365/az-idp-toolbox.git
cd az-idp-toolbox

# Import the module
Import-Module -Name .\Az.Idp.Toolbox

# Verify the module
Get-Module -Name 'Az.Idp.Toolbox'
```

<details>
<summary>Example: Get-Module output</summary>

```text
ModuleType Version    PreRelease Name            ExportedCommands
---------- -------    ---------- ----            ----------------
Script     0.1.0      prev1      Az.Idp.Toolbox  New-RandomPassword
```
</details>

## Quick Start

```powershell
# Import the module
Import-Module -Name Az.Idp.Toolbox

# Generate a random password with default settings (16 characters, all character types)
$defaultPassword = New-RandomPassword

# Generate a random password with custom settings
$customPassword = New-RandomPassword -Length 32 -IncludeLowercase -IncludeUppercase -IncludeNumeric

# Reveal password
ConvertFrom-SecureString -SecureString $customPassword -AsPlainText
```

## Requirements

- **PowerShell**: 5.1 or later
- **OS**: Windows, Linux, macOS
- **.NET Framework**: 4.7.2 or later (Windows PowerShell)
- **.NET Core**: 2.0 or later (PowerShell Core)

## Development

### Building the Module

```powershell
# Run tests
Invoke-Pester -Path .\Az.Idp.Toolbox\Tests\

# Build module
.\build\build.ps1

# Build and publish
.\build\build.ps1 -Version '0.1.0-prev1' -Publish -ApiKey $ApiKey
```
