# cSpell: words classificationnodes
function Get-AdoArea {
    <#
    .SYNOPSIS
        Gets area classification nodes for a project in Azure DevOps.

    .DESCRIPTION
        This function retrieves area classification nodes for a specified project in Azure DevOps using the REST API.

    .PARAMETER Path
        Optional. The path of the area node to retrieve. If not specified, the root area node is returned.

    .PARAMETER Depth
        Optional. The depth of the area nodes to retrieve. If not specified, only the specified node is returned.

    .PARAMETER ProjectId
        Mandatory. The ID or name of the Azure DevOps project.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/classification-nodes/create-or-update

    .NOTES
        - Requires an active connection to Azure DevOps using Connect-AdoOrganization.

    .EXAMPLE
        $areaNode = Get-AdoArea -ProjectId 'my-project-001'

        This example retrieves the root area node for the specified project.

    .EXAMPLE
        $areaNode = Get-AdoArea -ProjectId 'my-project-001' -Path 'Area/SubArea' -Depth 2

        This example retrieves the area node at the specified path with a depth of 2.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [int]$Depth,

        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory = $false)]
        [Alias('api')]
        [ValidateSet('7.1', '7.2-preview.2')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command      : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  Path       : {0}' -f $Path)
        Write-Verbose ('  Depth      : {0}' -f $Depth)
        Write-Verbose ('  ProjectId  : {0}' -f $ProjectId)
        Write-Verbose ('  ApiVersion : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            $uriFormat = '{0}/{1}/_apis/wit/classificationnodes/Areas/{2}?$depth={3}&api-version={4}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), [uri]::EscapeUriString($ProjectId), [uri]::EscapeUriString($Path), $Depth, $ApiVersion)

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
        Write-Verbose ('{0} exited' -f $MyInvocation.MyCommand)
    }
}
