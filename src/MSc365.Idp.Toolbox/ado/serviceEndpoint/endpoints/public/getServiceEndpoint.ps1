function Get-AdoServiceEndpoint {
    <#
    .SYNOPSIS
        Get the service endpoint details for an Azure DevOps service endpoint.

    .DESCRIPTION
        This function retrieves the service endpoint details for an Azure DevOps service endpoint through REST API.

    .PARAMETER ProjectId
        Mandatory. The unique identifier or name of the project.

    .PARAMETER EndpointName
        Mandatory. The name the service endpoint.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/endpoints/get?view=azure-devops

    .EXAMPLE
        $endpoint = Get-AdoServiceEndpoint -ProjectName 'my-project-001' -EndPointName 'id-my-adortagent'

    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory)]
        [Alias('ProjectName')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [string]$EndpointName,

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('7.1', '7.2-preview.4')]
        [string]$ApiVersion = '7.2-preview.4'
    )

    begin {
        Write-Verbose ('Command      : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  ProjectId  : {0}' -f $ProjectId)
        Write-Verbose ('  ApiVersion : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            $uriFormat = '{0}/{1}/_apis/serviceendpoint/endpoints?endpointNames={2}&api-version={3}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), [uri]::EscapeDataString($ProjectId), [uri]::EscapeDataString($EndpointName), $ApiVersion)

            $params = @{
                Method  = 'GET'
                Uri     = $azDevOpsUri
                Headers = $global:AzDevOpsHeaders
            }

            $response = (Invoke-RestMethod @params -Verbose:$VerbosePreference ).value

            return $response

        } catch {
            throw $_
        }
    }

    end {
        Write-Verbose ('Exit : {0}' -f $MyInvocation.MyCommand.Name)
    }
}
