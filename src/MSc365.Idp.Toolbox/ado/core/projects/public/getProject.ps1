function Get-AdoProject {
    <#
    .SYNOPSIS
        Get projects or the project details.

    .DESCRIPTION
        This function retrieves all projects or the project details for a given Azure DevOps project through REST API.

    .PARAMETER ProjectId
        Optional. Project ID or project name.

    .PARAMETER IncludeCapabilities
        Optional. Include capabilities (such as source control) in the team project result. Default is 'false'.

    .PARAMETER IncludeHistory
        Optional. Search within renamed projects (that had such name in the past). Default is 'false'.

    .PARAMETER ApiVersion
        Optional. The API version to use.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/get?view=azure-devops

    .NOTES
        - If ProjectId is not provided, all projects are returned.
        - If ProjectId is provided, the project details are returned.

    .EXAMPLE
        $project = Get-AdoProject

    .EXAMPLE
        $project = Get-AdoProject -ProjectName 'my-project-001'

    .EXAMPLE
        $project =  Get-AdoProject -ProjectName 'my-project-001' -Capabilities -History
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory = $false)]
        [Alias('ProjectName')]
        [string]$ProjectId,

        [Parameter(Mandatory = $false)]
        [Alias('Capabilities')]
        [switch]$IncludeCapabilities,

        [Parameter(Mandatory = $false)]
        [Alias('History')]
        [switch]$IncludeHistory,

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('7.1', '7.2-preview.1')]
        [string]$ApiVersion = '7.1'
    )

    begin {
        Write-Verbose ('Command               : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  ProjectId           : {0}' -f $ProjectId)
        Write-Verbose ('  IncludeCapabilities : {0}' -f $IncludeCapabilities)
        Write-Verbose ('  IncludeHistory      : {0}' -f $IncludeHistory)
        Write-Verbose ('  ApiVersion          : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            if (-not $ProjectId) {
                $uriFormat = '{0}/_apis/projects?includeCapabilities={1}&includeHistory={2}&api-version={3}'
                $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), $IncludeCapabilities, $IncludeHistory, $ApiVersion)
            } else {
                $uriFormat = '{0}/_apis/projects/{1}?includeCapabilities={2}&includeHistory={3}&api-version={4}'
                $azDevOpsUri = ($uriFormat -f [uri]::new($global:AzDevOpsOrganization), [uri]::EscapeUriString($ProjectId),
                    $IncludeCapabilities, $IncludeHistory, $ApiVersion)
            }

            $params = @{
                Method  = 'GET'
                Uri     = $azDevOpsUri
                Headers = ((ConvertFrom-SecureString -SecureString $global:AzDevOpsHeaders -AsPlainText) | ConvertFrom-Json -AsHashtable)
            }

            $response = Invoke-RestMethod @params -Verbose:$VerbosePreference

            if (-not $ProjectId) {
                return $response.value
            } else {
                return $response
            }

        } catch {
            if ($_.Exception.StatusCode -eq 'NotFound') {
                Write-Verbose 'Project not found.'
                return $null
            }
            throw $_
        }
    }

    end {
        Write-Verbose ('Exit : {0}' -f $MyInvocation.MyCommand.Name)
    }

}
