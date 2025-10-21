<!-- omit from toc -->
# Internal Developer Platform (IDP) Toolbox for Azure

[![GitHub release (latest)](https://img.shields.io/github/v/release/msc365/az-idp-toolbox?include_prereleases&logo=github)](https://github.com/msc365/az-idp-toolbox/releases)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/MSc365.Idp.Toolbox?include_prereleases)](https://www.powershellgallery.com/packages/MSc365.Idp.Toolbox)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/MSc365.Idp.Toolbox.svg)](https://www.powershellgallery.com/packages/MSc365.Idp.Toolbox)
[![license](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

This PowerShell module provides a comprehensive set of commands and scripts for Internal Developer Platforms (IDPs) on Azure. It enables you to bootstrap end-to-end RBAC governance in Azure when using CI/CD pipelines. It provisions and configures Azure DevOps projects, Azure resources, Entra ID security groups, managed identities, service connections, and Azure role assignments based on a JSON configuration file.

> [!NOTE]
> This project is built upon the foundational concepts derived from [DevOps Governance](https://github.com/Azure/devops-governance) by [Julie Ng](https://github.com/julie-ng). I have enhanced it by incorporating the latest best practices. Specifically, I utilized **Bicep** as Infrastructure as Code (IaC) and used custom **PowerShell** modules to bootstrap Azure DevOps projects, Azure resources and Entra identities. Additionally, I implemented [workload identity federation](https://devblogs.microsoft.com/devops/workload-identity-federation-for-azure-deployments-is-now-generally-available/) for Azure Pipelines, moving away from traditional _service principals_ to improve security and manageability.

<!-- > [!NOTE]
> This module provides experimental features, allowing you to test and provide feedback on new functionalities before they become stable. These features are not finalized and may undergo breaking changes, so they are not recommended for production use. -->

<!-- omit from toc -->
## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Bootstrap Script](#bootstrap-script)
- [Command Naming](#command-naming)
- [Requirements](#requirements)
- [Development](#development)

## Installation

### PowerShell Gallery (recommended)

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
  $azAccountSplat = @{
      TenantId = '<YOUR_TENANT_ID>'
      SubscriptionId = '<YOUR_SUBSCRIPTION_ID>'
  }
  Connect-AzAccount @azAccountSplat
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

### Get projects

Get projects including details as `<Object[]>`.

```powershell
Get-AdoProject
```

### Get project details

Get project details as `<PSCustomObject>`.

```powershell
Get-AdoProject -ProjectId 'my-project'
```

### Disconnect

This removes global variables related to the Azure DevOps connection, effectively disconnecting the session from the specified organization.

```powershell
Disconnect-AdoOrganization
```

## Bootstrap Script

The [Invoke-AdoE2eRbacProject.ps1](./scripts/Invoke-AdoE2eRbacProject.ps1) script automates end-to-end RBAC governance in Azure when using CI/CD pipelines. It provisions and configures Azure DevOps projects, Azure resources, Entra ID security groups, managed identities, service connections, and Azure role assignments based on a JSON configuration file.

> [!WARNING]
> Before using the `Invoke-AdoE2eRbacProject.ps1` script, you must first deploy the `iac\authorization\role-definition\deploy.ps1` script once to set up the required role definitions.

### Authentication

<!-- markdownlint-disable-next-line MD024 -->
#### Sign in to Azure

```powershell
$azAccountSplat = @{
    TenantId = '<YOUR_TENANT_ID>'
    SubscriptionId = '<YOUR_SUBSCRIPTION_ID>'
}
Connect-AzAccount @azAccountSplat
```

#### Delegated access to Graph

```powershell
$mgGraphSplat = @{
    Scopes = @(
        'User.Read.All'
        'Group.ReadWrite.All'
        'RoleManagement.ReadWrite.Directory'
    ) -join ','
    NoWelcome = $true
}
Connect-MgGraph @mgGraphSplat
```

### Usage Examples

#### Basic Usage

```powershell
.\scripts\Invoke-AdoE2eRbacProject.ps1 -ConfigFilePath '.\samples\bootstrapConfig1.json'
```

#### With Verbose Output

```powershell
.\scripts\Invoke-AdoE2eRbacProject.ps1 -ConfigFilePath '.\samples\bootstrapConfig1.json' -Verbose
```

## Command Naming

The commands in this module follow a consistent naming pattern that directly aligns with the Azure DevOps REST API structure and operations.

This design approach provides several benefits, see following details for more information.

<details>
<summary>More details</summary>

### Naming Pattern

- **Prefix**  
  All Azure DevOps commands use the `Ado` prefix:
  
  - `Get-AdoProject`

  - `New-AdoRepository`  
- **Verb**  
  Standard PowerShell verbs that map to REST API operations:

  - `Get-` → REST GET operations (retrieve resources)
  
  - `New-` → REST POST operations (create resources)
  
  - `Set-` → REST PUT/PATCH operations (update resources)
  
  - `Remove-` → REST DELETE operations (delete resources)
- **Noun**  
  Resource names that match the Azure DevOps REST API endpoints:
  
  - `Project`
  
  - `Repository`
  
  - `Team`
  
  - `PolicyConfiguration`

### REST API Alignment

Each command corresponds directly to specific Azure DevOps REST API endpoints:

- `Get-AdoProject` → `/_apis/projects` ([API Reference](https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/get))

- `Get-AdoRepository` → `/_apis/git/repositories` ([API Reference](https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/get-repository))

- `Get-AdoTeam` → `/_apis/projects/{projectId}/teams` ([API Reference](https://learn.microsoft.com/en-us/rest/api/azure/devops/core/teams/get-teams))

### Benefits of this Approach

- **Predictable**  
  If you know the Azure DevOps REST API, you can easily predict command names

- **Consistent**  
  All commands follow the same naming convention

- **Discoverable**  
  Use PowerShell's `Get-Command *-Ado*` to explore available commands

- **Documented**  
  Each command includes links to the corresponding REST API documentation

</details>

## Requirements

### To use module

- **PowerShell**: 7.4 or later
- **Az.Accounts**: 3.0.5 or later

### To run bootstrap script

#### Microsoft Azure PowerShell

- **Az.Accounts**: 3.0.5 or later
- **Az.Resources**: 7.6.0 or later
- **Az.ManagedServiceIdentity**: 1.2.1 or later

#### Microsoft Graph

- **Microsoft.Graph.Groups**: 2.31 or later
- **Microsoft.Graph.Users**: 2.31 or later

## Development

### Building the Module

```powershell
# Run tests
Invoke-psake .\src\Build.ps1 -taskList Test

# Build module
Invoke-psake .\src\Build.ps1 -taskList Build

# Build and publish
Invoke-psake .\src\Build.ps1 -taskList Publish
```

### Clean up

```powershell
# Clean up module dir
Invoke-psake .\src\Build.ps1 -taskList Clean
```
