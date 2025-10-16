function Get-AdoGroup {
    <#
    .SYNOPSIS
        Get groups in an Azure DevOps organization.

    .DESCRIPTION
        This function retrieves groups in an Azure DevOps organization through REST API.

    .PARAMETER ScopeDescriptor
        Specify a non-default scope (collection, project) to search for groups.

    .PARAMETER SubjectTypes
        A comma separated list of user subject subtypes to reduce the retrieved results, e.g. Microsoft.IdentityModel.Claims.ClaimsIdentity

    .PARAMETER ContinuationToken
        An opaque data blob that allows the next page of data to resume immediately after where the previous page ended.
        The only reliable way to know if there is more data left is the presence of a continuation token.

    .PARAMETER ApiVersion
        The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/graph/groups/list

    .EXAMPLE
        $groups = Get-AdoGroup -ScopeDescriptor $projectDescriptor -SubjectTypes 'vssgp', 'aadgp'

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ScopeDescriptor,

        [Parameter(Mandatory = $false)]
        [ValidateSet('vssgp', 'aadgp')]
        [string[]]$SubjectTypes,

        [Parameter(Mandatory = $false)]
        [string]$ContinuationToken,

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('7.1-preview', '7.1-preview.1', '7.2-preview.1')]
        [string]$ApiVersion = '7.1-preview'
    )

    begin {
        Write-Verbose ('Command           : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  ScopeDescriptor : {0}' -f $ScopeDescriptor)
        Write-Verbose ('  SubjectTypes    : {0}' -f [string]::Join(',', $SubjectTypes))
        Write-Verbose ('  ApiVersion      : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            $AzDevOpsOrganization = $global:AzDevOpsOrganization -replace 'https://', 'https://vssps.'

            if (-not $ContinuationToken) {
                $uriFormat = '{0}/_apis/graph/groups?scopeDescriptor={1}&SubjectTypes={2}&api-version={3}'
                $azDevOpsUri = ($uriFormat -f [uri]::new($AzDevOpsOrganization), $ScopeDescriptor, [string]::Join(',', $SubjectTypes), $ApiVersion)
            } else {
                $uriFormat = '{0}/_apis/graph/groups?scopeDescriptor={1}&SubjectTypes={2}&continuationToken={3}&api-version={4}'
                $azDevOpsUri = ($uriFormat -f [uri]::new($AzDevOpsOrganization), $ScopeDescriptor, [string]::Join(',', $SubjectTypes), $ContinuationToken, $ApiVersion)
            }

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
