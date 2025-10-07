function New-AdoProject {
    <#
    .SYNOPSIS
        Create a new project in an Azure DevOps organization.

    .DESCRIPTION
        This function creates a new project in an Azure DevOps organization through REST API.

    .PARAMETER Name
        Mandatory. The name of the project to create.

    .PARAMETER Description
        Optional. The description of the project.

    .PARAMETER Process
        Optional. The process to use for the project. Default is 'Agile'.

    .PARAMETER SourceControl
        Optional. The source control type to use for the project. Default is 'Git'.

    .PARAMETER Visibility
        Optional. The visibility of the project. Default is 'Private'.

    .PARAMETER ApiVersion
        Optional. The API version to use. Default is '7.1'.

    .LINK
        https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/create

    .EXAMPLE
        $project = New-AdoProject -Name 'my-project-002' -Description 'My new project'
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [Alias('Desc')]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
        [string]$Process = 'Agile',

        [Parameter(Mandatory = $false)]
        [Alias('Source')]
        [ValidateSet('Git', 'Tfvc')]
        [string]$SourceControl = 'Git',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Private', 'Public')]
        [string]$Visibility = 'Private',

        [Parameter(Mandatory = $false)]
        [Alias('Api')]
        [ValidateSet('7.1', '7.2-preview.1')]
        [string]$ApiVersion = '7.2-preview.1'
    )

    begin {
        Write-Verbose ('Command       : {0}' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('  Name        : {0}' -f $Name)
        Write-Verbose ('  Description : {0}' -f $Description)
        Write-Verbose ('  Process     : {0}' -f $Process)
        Write-Verbose ('  Visibility  : {0}' -f $Visibility)
        Write-Verbose ('  ApiVersion  : {0}' -f $ApiVersion)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            if (-not $global:AzDevOpsIsConnected) {
                throw 'Not connected to Azure DevOps. Please connect using Connect-AdoOrganization.'
            }

            $processTemplate = Get-AdoProcess -process $Process

            $uriFormat = '{0}/_apis/projects?api-version={1}'
            $azDevOpsUri = ($uriFormat -f [uri]::new($AzDevOpsOrganization), $ApiVersion)

            $body = @{
                name         = $Name
                description  = $Description
                capabilities = @{
                    versioncontrol  = @{
                        sourceControlType = $SourceControl
                    }
                    processTemplate = @{
                        templateTypeId = $processTemplate.id
                    }
                }
                visibility   = $Visibility

            } | ConvertTo-Json -Depth 5 -Compress

            $params = @{
                Method  = 'POST'
                Uri     = $azDevOpsUri
                Headers = $global:AzDevOpsHeaders
                Body    = $body
            }

            $response = Invoke-RestMethod @params -ContentType 'application/json' -Verbose:$VerbosePreference

            $status = $response.status

            while ($status -ne 'succeeded') {
                Write-Host 'Checking project creation status...'
                Start-Sleep -Seconds 2

                $response = Invoke-RestMethod -Method GET -Uri $response.url -Headers $global:AzDevOpsHeaders
                $status = $response.status

                if ($status -eq 'failed') {
                    Write-Error -Message ('Project creation failed {0}' -f $PSItem.Exception.Message)
                }
            }

            return $response

        } catch {
            throw $_
        }
    }

    end {
        Write-Verbose ('Exit : {0}' -f $MyInvocation.MyCommand.Name)
    }
}
