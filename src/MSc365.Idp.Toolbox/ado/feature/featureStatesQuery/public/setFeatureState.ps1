﻿function Set-AdoFeatureState {
    <#
    .SYNOPSIS
        Set the feature state for an Azure DevOps project feature.

    .DESCRIPTION
        This function sets the feature state for an Azure DevOps project feature through REST API.

    .PARAMETER ProjectId
        Mandatory. The unique identifier or name of the project.

    .PARAMETER Feature
        Mandatory. The feature to set the state for. Valid values are 'Boards', 'Repos', 'Pipelines', 'TestPlans', 'Artifacts'.

    .PARAMETER FeatureState
        Optional. The state to set the feature to. Default is 'Disabled'.

    .NOTES
        - Turning off a feature hides this service for all members of this project.
          If you choose to enable this service later, all your existing data will be available.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/feature-management/featurestatesquery

    .EXAMPLE
        $featureState = Set-AdoFeatureState -ProjectName 'my-project-002' -Feature 'Boards' -FeatureState 'Disabled'
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory)]
        [Alias('ProjectName')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [ValidateSet('boards', 'repos', 'pipelines', 'testPlans', 'artifacts')]
        [string]$Feature,

        [Parameter(Mandatory = $false)]
        [ValidateSet('enabled', 'disabled')]
        [string]$FeatureState = 'disabled',

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('4.1-preview.1')]
        [string]$ApiVersion = '4.1-preview.1'
    )

    begin {
        Write-Verbose ('Command        : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  ProjectId    : {0}' -f $ProjectId)
        Write-Verbose ('  Feature      : {0}' -f $Feature)
        Write-Verbose ('  FeatureState : {0}' -f $FeatureState)
        Write-Verbose ('  ApiVersion   : {0}' -f $ApiVersion)
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

            # Get the feature ID
            $featureId = switch ($Feature.ToLower()) {
                'boards' { 'ms.vss-work.agile' }
                'repos' { 'ms.vss-code.version-control' }
                'pipelines' { 'ms.vss-build.pipelines' }
                'testPlans' { 'ms.vss-test-web.test' }
                'artifacts' { 'ms.azure-artifacts.feature' }
            }

            $uriFormat = '{0}/_apis/FeatureManagement/FeatureStates/host/project/{1}/{2}?api-version={3}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), $ProjectId, $featureId, $ApiVersion)

            $body = @{
                featureId = $featureId
                scope     = @{
                    settingScope = 'project'
                    userScoped   = $false
                }
                state     = ($FeatureState -eq 'enabled' ? 1 : 0)
            } | ConvertTo-Json

            $params = @{
                Method  = 'PATCH'
                Uri     = $azDevOpsUri
                Headers = (ConvertFrom-SecureString -SecureString $global:AzDevOpsHeaders -AsPlainText) | ConvertFrom-Json -AsHashtable
                Body    = $body
            }

            $response = Invoke-RestMethod @params -ContentType 'application/json' -Verbose:$VerbosePreference

            return $response

        } catch {
            throw $_
        }
    }

    end {
        Write-Verbose ('Exit : {0}' -f $MyInvocation.MyCommand.Name)
    }
}
