<!--
document type: cmdlet
external help file: ado-Help.xml
HelpUri: ''
Locale: en-NL
Module Name: ado
ms.date: 10/06/2025
PlatyPS schema version: 2024-05-01
title: Get-AdoAccessToken
-->

<!--markdownlint-disable no-duplicate-heading-->

# Get-AdoAccessToken

Module: [MSc365.Idp.Toolbox Module](../../Commands.md)

## SYNOPSIS

Get secure access token for Azure DevOps service principal.

## SYNTAX

### __AllParameterSets

```text
Get-AdoAccessToken
  [[-TenantId] <string>]
  [<CommonParameters>]
```

<!-- ## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}} -->

## DESCRIPTION

This command gets an access token for the Azure DevOps service principal using the current Azure context or a specified tenant ID.

## EXAMPLES

### EXAMPLE 1: Get access token using Azure context

#### PowerShell
```powershell
Get-AdoAccessToken
```

This example retrieves an access token for Azure DevOps using the tenant ID from the current Azure context.

### EXAMPLE 2: Get access token using tenant ID

#### PowerShell
```powershell
Get-AdoAccessToken -TenantId "00000000-0000-0000-0000-000000000000"
```

This example retrieves an access token for Azure DevOps using the specified tenant ID.

## PARAMETERS

### -TenantId

The tenant ID to use for retrieving the access token. If not specified, the tenant ID from the current Azure context is used.

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
