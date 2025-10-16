# Invoke-AdoE2eRbacProject.ps1 Script

## Overview

The `Invoke-AdoE2eRbacProject.ps1` script automates the end-to-end RBAC governance setup for Azure DevOps projects. It provisions and configures Azure DevOps projects and teams, Azure resources, Entra ID security groups, managed identities, service connections, and Azure role assignments based on a JSON configuration file.

> [!NOTE]
> Hey there! 👋 I'm actively working on getting everything documented. Thanks for your patience!

<!-- ## Script Metadata

- **Version**: 1.0
- **Author**: Martin Swinkels
- **Company**: MSc365.eu
- **License**: [MIT License](https://github.com/msc365/az-idp-toolbox/blob/main/LICENSE)
- **Tags**: Azure, IDP, Toolbox, Utilities, Security, Governance, DevOps, Platform, RBAC

## Dependencies

### PowerShell Modules
- **Required**: `MSc365.Idp.Toolbox` (loaded from local source)
- **External**: `Az`, `Microsoft.Graph.Authentication`, `Microsoft.Graph.Groups`, `Microsoft.Graph.Users`

### Azure Provider Registration
- Subscriptions must be registered with the `Microsoft.ManagedIdentity` resource provider

## Prerequisites

### Authentication Requirements

1. **Azure Connection**:
   ```powershell
   $azParams = @{
       TenantId = '<YOUR_TENANT_ID>'
       SubscriptionId = '<YOUR_SUBSCRIPTION_ID>'
   }
   Connect-AzAccount @azParams
   ```

2. **Microsoft Graph Connection**:
   ```powershell
   $mgParams = @{
       Scopes = @(
           'User.Read.All'
           'Group.ReadWrite.All'
           'RoleManagement.ReadWrite.Directory'
       ) -join ','
       NoWelcome = $true
   }
   Connect-MgGraph @mgParams
   ```

### Required Permissions

- **Azure**: Subscription Owner or Contributor with User Access Administrator
- **Entra ID**: Global Administrator or privileged role for group and role management
- **Azure DevOps**: Project Collection Administrator

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ConfigFilePath` | String | Yes | Absolute or relative path to the JSON configuration file |

## Functionality

### Core Operations

The script performs these operations in sequence for each project defined in the configuration:

#### 1. Project Management
- **Creates Azure DevOps project** if it doesn't exist
- **Configures project settings**: description, process template, source control, visibility
- **Updates default team name** to match project naming convention
- **Enables/disables project features**: boards, repos, pipelines, test plans, artifacts

#### 2. Resource Group Creation
- **Creates Azure resource groups** for each environment (prod, dev, etc.)
- **Applies standardized naming convention**: `rg-{prefix}-{project}-{environment}-{region}`
- **Assigns resource tags** defined in global configuration

#### 3. Entra ID Security Groups
- **Creates Entra ID security groups** with standardized naming: `sg-{prefix}-{project}-{group}`
- **Configures group properties**:
  - Mail-enabled: false
  - Security-enabled: true
  - Role-assignable: true
  - Visibility: Private
- **Implements 15-second synchronization wait** for Entra ID propagation

#### 4. Managed Identity Provisioning
- **Creates user-assigned managed identities** per environment
- **Naming convention**: `id-{prefix}-{project}-{environment}-{region}`
- **Associates with resource groups** and applies tags

#### 5. Service Connection Configuration
- **Creates Azure DevOps service connections** using Workload Identity Federation
- **Configures federated identity credentials** for OIDC trust
- **Sets appropriate scopes** (subscription or resource group level)
- **Enables secure, keyless authentication** from Azure DevOps to Azure

#### 6. Azure DevOps Group Membership
- **Assigns Entra ID security groups** to Azure DevOps built-in groups:
  - Project Administrators
  - Contributors
  - Readers
- **Enables SSO integration** between Entra ID and Azure DevOps

#### 7. Azure Role Assignments
- **Assigns Azure RBAC roles** to security groups and managed identities
- **Supports multiple object types**: Group, ServicePrincipal
- **Scopes assignments** to resource group level
- **Prevents duplicate role assignments**

#### 8. Team Management
- **Creates custom Azure DevOps teams** within projects
- **Configures team descriptions** and properties

### Naming Conventions

The script implements consistent naming patterns across all resources:

| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Project | `{prefix}{separator}{name}` | `e2egov-avengers` |
| Resource Group | `rg{separator}{project}{separator}{env}-{region}` | `rg-e2egov-avengers-prd-weu` |
| Security Group | `sg{separator}{project}{separator}{group}` | `sg-e2egov-avengers-admins` |
| Managed Identity | `id{separator}{project}{separator}{env}-{region}` | `id-e2egov-avengers-prd-weu` |
| Service Connection | `rg{separator}{project}{separator}{env}-{region}` | `rg-e2egov-avengers-prd-weu` |

## Configuration File Structure

### Global Settings
```json
{
  "global": {
    "prefix": "e2egov",
    "nameSeparator": "-",
    "regions": {
      "westeurope": "weu",
      "northeurope": "neu"
    },
    "tags": {
      "public": "false",
      "service": "demo-e2e-gov",
      "iac": "bicep",
      "ci": "azure-pipelines"
    }
  }
}
```

### DevOps Organization
```json
{
  "devops": {
    "organization": "your-org-name"
  }
}
```

### Project Configuration
```json
{
  "projects": [
    {
      "name": "project-name",
      "description": "Project description",
      "process": "agile",
      "sourceControl": "git",
      "visibility": "private",
      "features": {
        "boards": "enabled",
        "repos": "enabled",
        "pipelines": "enabled",
        "testPlans": "disabled",
        "artifacts": "disabled"
      },
      "groups": [...],
      "teams": [...]
    }
  ]
}
```

### Group Configuration
```json
{
  "groups": [
    {
      "name": "admins",
      "description": "Administrator group",
      "environment": "prd",
      "location": "westeurope",
      "subscriptionId": "subscription-guid",
      "subscriptionName": "subscription-name",
      "groupMembership": ["Project Administrators"],
      "roleAssignments": [
        {
          "objectType": "ServicePrincipal",
          "definitionName": "Contributor",
          "scope": "prd"
        }
      ]
    }
  ]
}
```

## Usage Examples

### Basic Usage
```powershell
.\scripts\Invoke-Bootstrap.ps1 -ConfigFilePath '.\samples\bootstrapConfig1.json'
```

### With Verbose Output
```powershell
.\scripts\Invoke-Bootstrap.ps1 -ConfigFilePath '.\config\myproject.json' -Verbose
```

### Using Relative Path
```powershell
Set-Location 'C:\_git\platform\az-idp-toolbox'
.\scripts\Invoke-Bootstrap.ps1 -ConfigFilePath '.\samples\bootstrapConfig1.json'
```

## Return Value

Returns an array of PowerShell custom objects representing the created/configured projects, including:

- Project metadata (ID, name, description)
- Group configurations with associated Azure resources
- Team information
- Service connection details
- Resource group properties

## Error Handling

### Common Errors

1. **Configuration file not found**: Script validates file existence before processing
2. **Authentication failures**: Validates Microsoft Graph and Azure connectivity
3. **Permission errors**: Requires appropriate Azure and Entra ID permissions
4. **Resource conflicts**: Handles existing resources gracefully
5. **Network timeouts**: Implements retry logic for Azure operations

### Error Recovery

- **Idempotent operations**: Script can be re-run safely
- **Existing resource detection**: Skips creation if resources already exist
- **Partial failure handling**: Continues processing remaining items after individual failures
- **Detailed error reporting**: Provides specific error context and suggestions

## Performance Considerations

- **Parallel processing**: Creates multiple resources simultaneously where possible
- **Synchronization delays**: Implements 15-second wait for Entra ID group synchronization
- **Progress indicators**: Shows completion status for long-running operations
- **Resource validation**: Checks existence before creation to avoid unnecessary operations

## Security Considerations

- **Workload Identity Federation**: Uses OIDC instead of service principal secrets
- **Least privilege access**: Scopes service connections to specific resource groups
- **Role-based access**: Implements proper RBAC assignments
- **Secure group creation**: Creates private, role-assignable security groups
- **Credential management**: Avoids storing secrets in configuration files

## Troubleshooting

### Common Issues

1. **Script execution policy**: Ensure PowerShell execution policy allows script execution
2. **Module dependencies**: Verify all required modules are installed
3. **Authentication timeouts**: Re-authenticate if sessions expire
4. **Resource provider registration**: Ensure Microsoft.ManagedIdentity provider is registered
5. **Permission inheritance**: Allow time for permission propagation in Entra ID

### Validation Steps

1. Verify configuration file syntax using `ConvertFrom-Json`
2. Check authentication status for both Azure and Microsoft Graph
3. Validate subscription access and resource provider registration
4. Confirm Azure DevOps organization connectivity
5. Test permissions by creating test resources manually

## Related Documentation

- [Azure DevOps REST API](https://docs.microsoft.com/en-us/rest/api/azure/devops/)
- [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/api/overview)
- [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/)
- [Workload Identity Federation](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)
- [Azure RBAC](https://docs.microsoft.com/en-us/azure/role-based-access-control/) -->
