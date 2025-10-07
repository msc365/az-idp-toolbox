<!--
document type: cmdlet
external help file: ado-Help.xml
HelpUri: ''
Locale: en-NL
Module Name: ado
ms.date: 10/06/2025
PlatyPS schema version: 2024-05-01
title: Connect-AdoOrganization
-->

<!--markdownlint-disable no-duplicate-heading-->

# Connect-AdoOrganization

Module: [MSc365.Idp.Toolbox Module](../../Commands.md)

## SYNOPSIS

Connect to an Azure DevOps organization.

## SYNTAX

### __AllParameterSets

```text
Connect-AdoOrganization
  [-Organization] <string>
  [[-PersonalAccessToken] <securestring>]
  [[-ApiVersion] <string>]
  [<CommonParameters>]
```

<!-- ## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}} -->

## DESCRIPTION

This command connects to an Azure DevOps organization using a personal access token (PAT) or a service principal when no PAT is provided.

## EXAMPLES

### EXAMPLE 1: Connect to organization

```powershell
Connect-AdoOrganization -Organization 'my-org'
```

Connects to the specified Azure DevOps organization using a service principal.

### EXAMPLE 2: Connect to organization with PAT

```powershell
Connect-AdoOrganization -Organization 'my-org' -PersonalAccessToken $PAT
```

Connects to the specified Azure DevOps organization using the provided personal access token (PAT).

## PARAMETERS

### -ApiVersion

The API version to use.

```yaml
Type: System.String
Default value: '7.2-preview.1'
Supports wildcards: false
Aliases: Api
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

### -Organization

The name of the Azure DevOps organization.

```yaml
Type: System.String
Default value: ''
Supports wildcards: false
Aliases: Org
```

#### Parameter sets

<details>
<summary>(All)</summary>

```yaml
Mandatory: true
Value from pipeline: false
Value from pipeline by property name: false
Value from remaining arguments: false
```
</details>

### -PersonalAccessToken

The personal access token (PAT) to use for the authentication. If not provided, the token is retrieved using Get-Token.

```yaml
Type: System.Security.SecureString
Default value: ''
Supports wildcards: false
Aliases: PAT
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

### System.String

```text
Connected to https://dev.azure.com/my-org
```

## NOTES

This function requires the Az.Accounts cmdlet.

## RELATED LINKS

### None
