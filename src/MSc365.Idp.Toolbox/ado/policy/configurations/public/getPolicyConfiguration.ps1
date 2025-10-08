function Get-AdoPolicyConfiguration {
    <#
    .SYNOPSIS
        Gets policy configurations for an Azure DevOps project.

    .DESCRIPTION
        This function retrieves policy configurations for an Azure DevOps project through REST API.

    .PARAMETER ProjectId
        Mandatory. The unique identifier or name of the project.

    .PARAMETER PolicyType
        Optional. The type of policy to retrieve.

    .NOTES
        - If PolicyType is not specified, all policy configurations are returned.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/policy/configurations/get

    .EXAMPLE
        $configurations = Get-AdoPolicyConfiguration -ProjectName 'my-project-001'

    .EXAMPLE
        $configuration = Get-AdoPolicyConfiguration -ProjectName 'my-project-001' -PolicyType '00000000-0000-0000-0000-000000000000'

    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory)]
        [Alias('ProjectName')]
        [string]$ProjectId,

        [Parameter(Mandatory = $false)]
        [string]$PolicyType,

        [Parameter(Mandatory = $false)]
        [Alias('api')]
        [ValidateSet('7.1', '7.2-preview.1')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command       : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  ProjectId   : {0}' -f $ProjectId)
        Write-Verbose ('  PolicyType  : {0}' -f $PolicyType)
        Write-Verbose ('  ApiVersion  : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            if (-not $PolicyType) {
                $uriFormat = '{0}/{1}/_apis/policy/configurations?api-version={2}'
                $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), $ProjectId, $ApiVersion)
            } else {
                $uriFormat = '{0}/{1}/_apis/policy/configurations?policyType={2}&api-version={3}'
                $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), $ProjectId, [uri]::EscapeUriString($PolicyType), $ApiVersion)
            }

            $params = @{
                Method  = 'GET'
                Uri     = $azDevOpsUri
                Headers = (ConvertFrom-SecureString -SecureString $global:AzDevOpsHeaders -AsPlainText) | ConvertFrom-Json -AsHashtable
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
