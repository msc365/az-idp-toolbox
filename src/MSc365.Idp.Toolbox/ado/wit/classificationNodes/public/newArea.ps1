# cSpell: words classificationnodes
function New-AdoArea {
    <#
    .SYNOPSIS
        Creates a new area classification node for a project in Azure DevOps.

    .DESCRIPTION
        This function creates a new area classification node under a specified path for a project in Azure DevOps using the REST API.

    .PARAMETER Name
        Mandatory. The name of the new area node to create.

    .PARAMETER Path
        Optional. The path under which to create the new area node. If not specified, the node is created at the root level.

    .PARAMETER ProjectId
        Mandatory. The ID or name of the Azure DevOps project.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/classification-nodes/create-or-update

    .NOTES
        - Requires an active connection to Azure DevOps using Connect-AdoOrganization.

    .EXAMPLE
        $newAreaNode = New-AdoArea -Name 'NewArea' -ProjectId 'my-project-001'

        This example creates a new area node named 'NewArea' at the root level of the specified project.

    .EXAMPLE
        $newAreaNode = New-AdoArea -Name 'SubArea' -Path 'ExistingArea' -ProjectId 'my-project-001'

        This example creates a new area node named 'SubArea' under the existing area node 'ExistingArea' in the specified project.
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
        Write-Verbose ('{0} exited' -f $MyInvocation.MyCommand)
    }
}
