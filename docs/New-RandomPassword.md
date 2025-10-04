<!-- document type: cmdlet
external help file: MSc365.Idp.Toolbox-Help.xml
HelpUri: ''
Locale: en-US
Module Name: MSc365.Idp.Toolbox
ms.date: 10/03/2025
PlatyPS schema version: 2024-05-01
title: New-RandomPassword -->

<!--markdownlint-disable no-duplicate-heading-->

# New-RandomPassword

Module: [MSc365.Idp.Toolbox Module](Commands.md)

## SYNOPSIS

Creates a random password

## SYNTAX

### __AllParameterSets

```text
Syntax

New-RandomPassword
  [[-Length] <int>]
  [-IncludeLowercase]
  [-IncludeUppercase]
  [-IncludeNumeric]
  [-IncludeSpecial]
  [<CommonParameters>]
```

<!-- ## ALIASES

This cmdlet has the following aliases,

### None -->

## DESCRIPTION

The New-RandomPassword cmdlet creates a secure random password of specified length and optional characteristics.

## EXAMPLES

### EXAMPLE 1: Create a default password

#### PowerShell
```powershell
$password = New-RandomPassword
```

#### Output
```powershell
[System.Security.SecureString]
```

This example generates a 16-character password with all character types included by default.

### EXAMPLE 2: Create a password with specified character pool

#### PowerShell
```powershell
$password = New-RandomPassword -Length 20 -IncludeLowercase -IncludeUppercase -IncludeNumeric
ConvertFrom-SecureString $password -AsPlainText
```
#### Output
```powershell
'0JppOywZfBz8l1g2DBfu'
```

This example generates a 20-character password with lowercase, uppercase, and numeric characters, and then passes the SecureString to reveal the password as plain text.

## PARAMETERS

### -IncludeLowercase

Include lowercase characters in the password.

#### Parameter properties

```yaml
Type: SwitchParameter
Default value: false
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

### -IncludeNumeric

Include numeric characters in the password.

```yaml
Type: SwitchParameter
Default value: false
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

### -IncludeSpecial

Include special characters in the password.

```yaml
Type: SwitchParameter
Default value: false
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

### -IncludeUppercase

Include uppercase characters in the password.

```yaml
Type: SwitchParameter
Default value: false
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

### -Length

Length of the password to generate.
Default is 16.

```yaml
Type: System.Int32
Default value: 16
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

### None

## RELATED LINKS

### None

