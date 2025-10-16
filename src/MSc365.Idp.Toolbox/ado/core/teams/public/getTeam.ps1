function Get-AdoTeam {
    <#
    .SYNOPSIS
        Get teams or the team details for a given Azure DevOps project.

    .DESCRIPTION
        This function retrieves all teams or the team details for a given Azure DevOps project through REST API.

    .PARAMETER TeamId
        Optional. The unique identifier of the team.

    .PARAMETER ProjectId
        Mandatory. The unique identifier or name of the project.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .NOTES
        - If TeamId is not provided, all teams for the project are returned.
        - If TeamId is provided, the team details are returned.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/core/teams/get

    .EXAMPLE
        $teams = Get-AdoTeam -ProjectName 'my-project-001'

    .EXAMPLE
        $team = Get-AdoTeam -TeamId '00000000-0000-0000-0000-000000000000' -ProjectName 'my-project-001'
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory = $false)]
        [Alias('TeamName')]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [Alias('ProjectName')]
        [string]$ProjectId,

        [Parameter(Mandatory = $false)]
        [Alias('api')]
        [ValidateSet('5.1', '7.1-preview.4', '7.2-preview.3')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command       : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  TeamId      : {0}' -f $TeamId)
        Write-Verbose ('  ProjectId   : {0}' -f $ProjectId)
        Write-Verbose ('  ApiVersion  : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            if (-not $TeamId) {
                $uriFormat = '{0}/_apis/projects/{1}/teams/{2}?api-version={3}'
                $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), [uri]::EscapeUriString($ProjectId), $TeamId, $ApiVersion)

            } else {
                $uriFormat = '{0}/_apis/projects/{1}/teams?api-version={2}'
                $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), [uri]::EscapeUriString($ProjectId), $ApiVersion)
            }

            $params = @{
                Method  = 'GET'
                Uri     = $azDevOpsUri
                Headers = ((ConvertFrom-SecureString -SecureString $global:AzDevOpsHeaders -AsPlainText) | ConvertFrom-Json -AsHashtable)
            }

            $response = Invoke-RestMethod @params -Verbose:$VerbosePreference

            if (-not $TeamId) {
                return $response.value
            } else {
                return $response
            }

        } catch {
            if ($_.Exception.StatusCode -eq 'NotFound') {
                Write-Verbose 'Team not found.'
                return $null
            }
            throw $_
        }
    }

    end {
        Write-Verbose ('Exit : {0}' -f $MyInvocation.MyCommand.Name)
    }
}
