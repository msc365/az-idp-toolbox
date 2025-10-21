# cSpell: words classificationnodes
function Set-AdoArea {
    <#
    .SYNOPSIS
        Updates an area classification node for a project in Azure DevOps.

    .DESCRIPTION
        This function updates the name of an area classification node for a specified project in Azure DevOps using the REST API.

    .PARAMETER Name
        Mandatory. The new name for the area node.

    .PARAMETER Path
        Optional. The path of the area node to update. If not specified, the root area node is updated.

    .PARAMETER ProjectId
        Mandatory. The ID or name of the Azure DevOps project.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/classification-nodes/create-or-update

    .NOTES
        - Requires an active connection to Azure DevOps using Connect-AdoOrganization.

    .EXAMPLE
        $updatedAreaNode = Set-AdoArea -ProjectId 'my-project-001' -Name 'New Area Name' -Path 'Area/SubArea'

        This example updates the name of the specified area node.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory = $false)]
        [Alias('api')]
        [ValidateSet('7.1', '7.2-preview.2')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command      : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  Name       : {0}' -f $Name)
        Write-Verbose ('  Path       : {0}' -f $Path)
        Write-Verbose ('  ProjectId  : {0}' -f $ProjectId)
        Write-Verbose ('  ApiVersion : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            $uriFormat = '{0}/{1}/_apis/wit/classificationnodes/Areas/{2}?api-version={3}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), [uri]::EscapeUriString($ProjectId), [uri]::EscapeUriString($Path), $ApiVersion)

            $body = @{
                name = $Name
            } | ConvertTo-Json

            $params = @{
                Method  = 'PATCH'
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
        Write-Verbose ('{0} exited' -f $MyInvocation.MyCommand)
    }
}
