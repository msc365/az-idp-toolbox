# Internal Developer Platform (IDP) Toolbox for Azure

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/msc365/az-idp-toolbox?style=flat&logo=github)](https://github.com/msc365/az-idp-toolbox/releases/latest)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/MSc365.Idp.Toolbox.svg)](https://www.powershellgallery.com/packages/MSc365.Idp.Toolbox)
[![license](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

This PowerShell module provides a comprehensive set of automation and management tools for Internal Developer Platforms (IDPs) on Azure. It enables you to bootstrap and maintain Azure DevOps projects with end-to-end (e2e) **Role Based Access Control (RBAC)** governance through CI/CD pipelines.

> [!NOTE]
> This module provides experimental features, allowing you to test and provide feedback on new functionalities before they become stable. These features are not finalized and may undergo breaking changes, so they are not recommended for production use.

## Installation

### From PowerShell Gallery (recommended)

```powershell
# Install for current user
Install-Module -Name MSc365.Idp.Toolbox -Scope CurrentUser -Force

# Install prerelease
Install-Module -Name MSc365.Idp.Toolbox -Scope CurrentUser -AllowPrerelease -Force

# Install for all users (requires admin)
Install-Module -Name MSc365.Idp.Toolbox -Scope AllUsers -Force
```

### From Source

```powershell
# Clone the repository
git clone https://github.com/msc365/az-idp-toolbox.git
cd az-idp-toolbox

# Import the module
Import-Module -Name .\src\MSc365.Idp.Toolbox

# Verify the module
Get-Module -Name 'MSc365.Idp.Toolbox'
```

## Quick Start

### Sign in to Azure

To sign in, use the Connect-AzAccount cmdlet. If you're using Cloud Shell, you can skip this step since you're already authenticated for your environment, subscription, and tenant.

```powershell
Connect-AzAccount
```

### Find commands

Explore the documentation [Commands](docs/Commands.md) overview page or discover commands, use the Get-Command cmdlet. For instance, to list all commands related to Azure DevOps:

```powershell
Get-Command *-Ado*
```

Here's a quick reference table of some `ado` functions:

```text
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Connect-AdoOrganization                            0.1.0      MSc365.Idp.Toolbox
Function        Disconnect-AdoOrganization                         0.1.0      MSc365.Idp.Toolbox
Function        Get-AdoAccessToken                                 0.1.0      MSc365.Idp.Toolbox
Function        Get-AdoDescriptor                                  0.1.0      MSc365.Idp.Toolbox
Function        Get-AdoFeatureState                                0.1.0      MSc365.Idp.Toolbox
Function        Get-AdoGroups                                      0.1.0      MSc365.Idp.Toolbox
Function        Get-AdoPolicyConfiguration                         0.1.0      MSc365.Idp.Toolbox
Function        Get-AdoPolicyType                                  0.1.0      MSc365.Idp.Toolbox
Function        Get-AdoProcess                                     0.1.0      MSc365.Idp.Toolbox
Function        Get-AdoProject                                     0.1.0      MSc365.Idp.Toolbox
```

### Connect

Connect to an Azure DevOps organization using a personal access token (PAT). If you don't provide a PAT, the module will attempt to authenticate using the Azure DevOps service principal.

```powershell
Connect-AdoOrganization -Organization 'my-org'
```

### Get project details

```powershell
Get-AdoProject -ProjectId 'my-project'
```

#### Output

```text
id             : 00000000-0000-0000-0000-000000000000
name           : my-project
description    : Some project description
url            : https://dev.azure.com/my-org/_apis/projects/..
collection     : @{id=; name=; url=; collectionUrl=}
state          : wellFormed
defaultTeam    : @{id=; name= Team; url=}
revision       : 740
visibility     : private
lastUpdateTime : 01/01/0001 00:00:00
```

### Disconnect

This removes global variables related to the Azure DevOps connection, effectively disconnecting the session from the specified organization.

```powershell
Disconnect-AdoOrganization
```

## Naming Convention

The commands in this module follow a consistent naming pattern that directly aligns with the Azure DevOps REST API structure and operations.

This design approach provides several benefits:

<details>
<summary>More details</summary>

### Naming Pattern

- **Prefix**: All Azure DevOps commands use the `Ado` prefix (e.g., `Get-AdoProject`, `New-AdoRepository`)
- **Verb**: Standard PowerShell verbs that map to REST API operations:
  - `Get-` → REST GET operations (retrieve resources)
  - `New-` → REST POST operations (create resources)
  - `Set-` → REST PUT/PATCH operations (update resources)
  - `Remove-` → REST DELETE operations (delete resources)
- **Noun**: Resource names that match the Azure DevOps REST API endpoints (e.g., `Project`, `Repository`, `Team`, `PolicyConfiguration`)

### REST API Alignment

Each command corresponds directly to specific Azure DevOps REST API endpoints:

- `Get-AdoProject` → `/_apis/projects` ([API Reference](https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/get))
- `Get-AdoRepository` → `/_apis/git/repositories` ([API Reference](https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/get-repository))
- `Get-AdoTeam` → `/_apis/projects/{projectId}/teams` ([API Reference](https://learn.microsoft.com/en-us/rest/api/azure/devops/core/teams/get-teams))

### Benefits of this Approach

- **Predictable**: If you know the Azure DevOps REST API, you can easily predict command names
- **Consistent**: All commands follow the same naming convention
- **Discoverable**: Use PowerShell's `Get-Command *-Ado*` to explore available commands
- **Documented**: Each command includes links to the corresponding REST API documentation

</details>

## Requirements

- **PowerShell**: 7.4 or later
- **Az.Account**: 3.0 or later

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

### Clean up

```powershell
# Clean up module dir
Invoke-psake .\src\Build.ps1 -taskList Clean
```
