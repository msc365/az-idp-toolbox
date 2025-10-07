﻿function New-AdoRepository {
    <#
    .SYNOPSIS
        Create a new repository in an Azure DevOps project.

    .DESCRIPTION
        This function creates a new repository in an Azure DevOps project through REST API.

    .PARAMETER ProjectId
        Mandatory. The unique identifier or name of the project.

    .PARAMETER Name
        Mandatory. The name of the repository.

    .PARAMETER SourceRef
        Optional. Specify the source refs to use while creating a fork repo.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/create?view=azure-devops

    .EXAMPLE
        $repo = New-AdoRepository -ProjectId $project.id -Name 'my-other-001'
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory)]
        [Alias('ProjectName')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$SourceRef,

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('7.1', '7.2-preview.2')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command      : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  ProjectId  : {0}' -f $ProjectId)
        Write-Verbose ('  Name       : {0}' -f $Name)
        Write-Verbose ('  SourceRef  : {0}' -f $SourceRef)
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
                $ProjectId = (Get-AdoProject -ProjectName $ProjectId).id
            }

            $uriFormat = '{0}/{1}/_apis/git/repositories?sourceRef={2}&api-version={3}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), $ProjectId, $SourceRef, $ApiVersion)

            $body = @{
                name    = $Name
                project = @{
                    id = $ProjectId
                }
            } | ConvertTo-Json -Depth 5

            $params = @{
                Method  = 'POST'
                Uri     = $azDevOpsUri
                Headers = $global:AzDevOpsHeaders
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
