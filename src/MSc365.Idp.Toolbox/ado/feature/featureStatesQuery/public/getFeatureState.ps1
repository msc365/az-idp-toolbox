function Get-AdoFeatureState {
    <#
    .SYNOPSIS
        Get the feature states for an Azure DevOps project.

    .DESCRIPTION
        This function retrieves the feature states for an Azure DevOps project through REST API.

    .PARAMETER ProjectId
        Mandatory. The unique identifier or name of the project.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/feature-management/featurestatesquery

    .EXAMPLE
        $featureState = Get-AdoFeatureState -ProjectName 'my-project-002'

    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory)]
        [Alias('ProjectName')]
        [string]$ProjectId,

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('4.1-preview.1')]
        [string]$ApiVersion = '4.1-preview.1'
    )

    begin {
        Write-Verbose ('Command      : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  Projectid  : {0}' -f $ProjectId)
        Write-Verbose ('  ApiVersion : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            try {
                [System.Guid]::Parse($ProjectId) | Out-Null
            } catch {
                $ProjectId = (Get-AdoProject -ProjectName $ProjectId).Id
            }

            $uriFormat = '{0}/_apis/FeatureManagement/FeatureStatesQuery/host/project/{1}?api-version={2}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), $ProjectId, $ApiVersion)

            $body = @{
                featureIds    = @(
                    'ms.vss-work.agile'           # Boards
                    'ms.vss-code.version-control' # Repos
                    'ms.vss-build.pipelines'      # Pipelines
                    'ms.vss-test-web.test'        # Test Plans
                    'ms.azure-artifacts.feature'  # Artifacts
                )
                featureStates = @{}
                scopeValues   = @{
                    project = $ProjectId
                }
            } | ConvertTo-Json

            $params = @{
                Method  = 'POST'
                Uri     = $azDevOpsUri
                Headers = ((ConvertFrom-SecureString -SecureString $global:AzDevOpsHeaders -AsPlainText) | ConvertFrom-Json -AsHashtable)
                Body    = $body
            }

            $featureStates = Invoke-RestMethod @params -ContentType 'application/json' -Verbose:$VerbosePreference

            return $featureStates

        } catch {
            throw $_
        }
    }

    end {
        Write-Verbose ('Exit : {0}' -f $MyInvocation.MyCommand.Name)
    }
}
