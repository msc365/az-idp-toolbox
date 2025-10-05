<!-- document type: cmdlet
external help file: MSc365.Idp.Toolbox-Help.xml
HelpUri: ''
Locale: en-US
Module Name: MSc365.Idp.Toolbox
ms.date: 10/05/2025
PlatyPS schema version: 2024-05-01
title: Get-AzDevOpsAccessToken -->

<!--markdownlint-disable no-duplicate-heading-->

# Get-AzDevOpsAccessToken

Module: [MSc365.Idp.Toolbox Module](Commands.md)

## SYNOPSIS

Get secure access token for Azure DevOps service principal.

## SYNTAX

### __AllParameterSets

```text
Get-AzDevOpsAccessToken
  [[-TenantId] <string>]
  [<CommonParameters>]
```

<!-- ## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}} -->

## DESCRIPTION

The Get-AzDevOpsAccessToken cmdlet gets an access token for the Azure DevOps service principal using the current Azure context or a specified tenant ID.

## EXAMPLES

### EXAMPLE 1: Get the access token

```powershell
Get-AzDevOpsAccessToken
```

This example retrieves an access token for Azure DevOps using the tenant ID from the current Azure context.

### EXAMPLE 2: Get the access token for a specified tenant

```powershell
Get-AzDevOpsAccessToken -TenantId "00000000-0000-0000-0000-000000000000"
```

This example retrieves an access token for Azure DevOps using the specified tenant ID.

## PARAMETERS

### -TenantId

The tenant ID to use for retrieving the access token.
If not specified, the tenant ID from the current Azure context is used.

#### Parameter properties

```yaml
Type: System.String
Default value: ''
Supports wildcards: false
```

#### Parameter sets

<details>
<summary>(All)</summary>

```yaml
Mandatory: false
Value from pipeline: false
Value from pipeline by property name: false
Value from remaining arguments: false
```
</details>

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### [System.Security.SecureString](https://learn.microsoft.com/en-us/dotnet/api/system.security.securestring)

## NOTES

> [!NOTE]
> Please make sure the context matches the current Azure environment. You may refer to the value of `(Get-AzContext).Environment`.

## RELATED LINKS

### None
