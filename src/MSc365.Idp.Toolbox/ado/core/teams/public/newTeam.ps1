function New-AdoTeam {
    <#
    .SYNOPSIS
        Create a new team in an Azure DevOps project.

    .DESCRIPTION
        This function creates a new team in an Azure DevOps project through REST API.

    .PARAMETER Name
        Mandatory. The name of the team to create.

    .PARAMETER Description
        Optional. The description of the team.

    .PARAMETER ProjectId
        Mandatory. The unique identifier or name of the project.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .NOTES
        - The team name must be unique within the project.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/core/teams/create

    .EXAMPLE
        $team = New-AdoTeam -Name 'my-team-001' -ProjectId 'my-project-001'

    .EXAMPLE
        $team = New-AdoTeam -Name 'my-team-001' -Description 'My new team' -ProjectId 'my-project-001'

    #>
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory = $false)]
        [Alias('api')]
        [ValidateSet('5.1', '7.1-preview.4', '7.2-preview.3')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command      : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  Name       : {0}' -f $Name)
        Write-Verbose ('  ProjectId  : {0}' -f $ProjectId)
        Write-Verbose ('  ApiVersion : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            $uriFormat = '{0}/_apis/projects/{1}/teams?api-version={2}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), [uri]::EscapeUriString($ProjectId), $ApiVersion)

            $body = @{
                name        = $Name
                description = $Description
            } | ConvertTo-Json

            $params = @{
                Method  = 'POST'
                Uri     = $azDevOpsUri
                Headers = ((ConvertFrom-SecureString -SecureString $global:AzDevOpsHeaders -AsPlainText) | ConvertFrom-Json -AsHashtable)
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
