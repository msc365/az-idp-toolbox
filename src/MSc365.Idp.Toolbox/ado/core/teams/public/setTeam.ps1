function Set-AdoTeam {
    <#
    .SYNOPSIS
        Update a team in an Azure DevOps project.

    .DESCRIPTION
        This function updates a team in an Azure DevOps project through REST API.

    .PARAMETER TeamId
        Mandatory. The unique identifier of the team.

    .PARAMETER ProjectId
        Mandatory. The unique identifier or name of the project.

    .PARAMETER Name
        Mandatory. The name of the team.

    .PARAMETER Description
        Optional. The description of the team.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/core/teams/update

    .EXAMPLE
        $team = Set-AdoTeam -TeamId '00000000-0000-0000-0000-000000000000' -ProjectId 'my-project-001' -Name 'my-team-001'
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory)]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('7.1', '7.2-preview.3')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command       : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  TeamId      : {0}' -f $TeamId)
        Write-Verbose ('  ProjectId   : {0}' -f $ProjectId)
        Write-Verbose ('  Name        : {0}' -f $Name)
        Write-Verbose ('  Description : {0}' -f $Description)
        Write-Verbose ('  ApiVersion  : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            $uriFormat = '{0}/_apis/projects/{1}/teams/{2}?api-version={3}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), $ProjectId, $TeamId, $ApiVersion)

            $body = @{
                name = $Name
            }

            if (-not [string]::IsNullOrEmpty($Description)) {
                $body.Description = $Description
            }

            $params = @{
                Method  = 'PATCH'
                Uri     = $azDevOpsUri
                Headers = ((ConvertFrom-SecureString -SecureString $global:AzDevOpsHeaders -AsPlainText) | ConvertFrom-Json -AsHashtable)
                Body    = ($body | ConvertTo-Json)
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
