function Get-AdoDescriptor {
    <#
    .SYNOPSIS
        Resolve a storage key to a descriptor.

    .DESCRIPTION
        This function resolves a storage key to a descriptor through REST API.

    .PARAMETER StorageKey
        Mandatory. Storage key of the subject (user, group, scope, etc.) to resolve

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/graph/descriptors/get

    .EXAMPLE
        $descriptor = Get-AdoDescriptor -StorageKey '00000000-0000-0000-0000-000000000000'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$StorageKey,

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('7.1', '7.2-preview.1')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command      : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  StorageKey : {0}' -f $StorageKey)
        Write-Verbose ('  ApiVersion : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            $uriFormat = '{0}/_apis/graph/descriptors/{1}?api-version={2}'
            $AzDevOpsOrganization = $global:AzDevOpsOrganization -replace 'https://', 'https://vssps.'
            $azDevOpsUri = ($uriFormat -f [uri]::new($AzDevOpsOrganization) , $StorageKey, $ApiVersion)

            $params = @{
                Method  = 'GET'
                Uri     = $azDevOpsUri
                Headers = ((ConvertFrom-SecureString -SecureString $global:AzDevOpsHeaders -AsPlainText) | ConvertFrom-Json -AsHashtable)
            }

            $response = Invoke-RestMethod @params -Verbose:$VerbosePreference

            return $response

        } catch {
            throw $_
        }
    }

    end {
        Write-Verbose ('Exit : {0}' -f $MyInvocation.MyCommand.Name)
    }
}
