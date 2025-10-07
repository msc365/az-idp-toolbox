<!--
document type: cmdlet
external help file: ado-Help.xml
HelpUri: ''
Locale: en-NL
Module Name: ado
ms.date: 10/06/2025
PlatyPS schema version: 2024-05-01
title: Disconnect-AdoOrganization
-->

<!--markdownlint-disable no-duplicate-heading-->

# Disconnect-AdoOrganization

Module: [MSc365.Idp.Toolbox Module](../../Commands.md)

## SYNOPSIS

Disconnect from the Azure DevOps organization.

## SYNTAX

### __AllParameterSets

```text
Disconnect-AdoOrganization
  [<CommonParameters>]
```

<!-- ## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}} -->

## DESCRIPTION

This command removes global variables related to the Azure DevOps connection, effectively disconnecting the session from the specified organization.

## EXAMPLES

### Example 1: Disconnect

```powershell
Disconnect-AdoOrganization
```

This disconnects from the currently connected Azure DevOps organization by removing the relevant variables.

## PARAMETERS

### None

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

### None

## RELATED LINKS

### None
