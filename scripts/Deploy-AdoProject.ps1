<#PSScriptInfo

.VERSION 1.0

.GUID 732c55d7-902b-46ac-ab28-5d8dc9ea5bb3

.AUTHOR Martin Swinkels

.COMPANYNAME MSc365.eu

.COPYRIGHT 2025 (c) MSc365.eu, Martin Swinkels

.TAGS 'Azure', 'IDP', 'Toolbox', 'Utilities', 'Security', 'Governance', 'DevOps', 'Platform', 'RBAC'

.LICENSEURI https://github.com/msc365/az-idp-toolbox/blob/main/LICENSE

.PROJECTURI https://github.com/msc365/az-idp-toolbox

.ICONURI https://raw.githubusercontent.com/msc365/az-idp-toolbox/main/.assets/icon.png

.EXTERNALMODULEDEPENDENCIES Az.Accounts
#>
<#
.SYNOPSIS
Create or update an Azure DevOps Project with specified settings.

.DESCRIPTION
This script creates or updates an Azure DevOps Project within a specified organization.
It allows you to set project properties such as name, description, process template, source control type, visibility, and feature states.
If the project already exists, it updates the properties and feature states as needed.

.PARAMETER Organization
The name of the Azure DevOps organization where the project will be created or updated.

.PARAMETER ProjectName
The name of the Azure DevOps project to create or update.

.PARAMETER TeamName
The name of the default team for the project.

.PARAMETER Description
A description for the Azure DevOps project.

.PARAMETER Process
The process template to use for the project. Valid values are 'Agile', 'Scrum', 'CMMI', and 'Basic'.

.PARAMETER SourceControl
The type of source control to use for the project. Valid values are 'Git' and 'Tfvc'.

.PARAMETER Visibility
The visibility of the project. Valid values are 'Private' and 'Public'.

.PARAMETER Features
A hashtable defining the feature states for the project. Valid features are 'Boards', 'Repos', 'Pipelines', 'TestPlans', and 'Artifacts' with states 'enabled' or 'disabled'.

.EXAMPLE

.\Deploy-AdoProject.ps1 `
    -Organization 'MyOrg' `
    -ProjectName 'MyProject' `
    -DefaultTeamName 'MyTeam' `
    -Description 'My project description' `
    -Process 'Agile' `
    -SourceControl 'Git' `
    -Visibility 'Private' `
    -Features @{
        'Boards' = 'enabled'
        'Repos' = 'enabled'
        'Pipelines' = 'enabled'
        'TestPlans' = 'disabled'
        'Artifacts' = 'enabled'
    }

This example deploys or updates a project named 'MyProject' in the 'MyOrg' organization with the specified settings.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter()]
    [string]$ProjectName = 'e2egov-fantastic-four',

    [Parameter()]
    [string]$DefaultTeamName = 'Fantastic Four',

    [Parameter()]
    [string]$Description = 'One project multiple teams, e2e governance demo',

    [Parameter()]
    [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
    [string]$Process = 'Agile',

    [Parameter()]
    [ValidateSet('Git', 'Tfvc')]
    [string]$SourceControl = 'Git',

    [Parameter()]
    [ValidateSet('Private', 'Public')]
    [string]$Visibility = 'Private',

    [Parameter()]
    [hashtable]$Features = @{
        'Boards'    = 'enabled'
        'Repos'     = 'enabled'
        'Pipelines' = 'enabled'
        'TestPlans' = 'disabled'
        'Artifacts' = 'enabled'
    }
)

begin {
    $rootPath = (Get-Item $PSScriptRoot).Parent

    # Import required modules
    $modules = @(
        'MSc365.Idp.Toolbox'
    )
    $modules | ForEach-Object {
        if (-not (Get-Module -Name $_ -ListAvailable)) {
            Import-Module ('{0}\src\{1}' -f $rootPath, $_) -Force -Verbose:$false
        }
    }

    # Connect to Azure DevOps Organization
    if ($null -eq (Get-AdoContext)) {
        Connect-AdoOrganization -Organization $Organization -Verbose:$VerbosePreference
    }
}

process {
    try {
        $ErrorActionPreference = 'Stop'
        $Error.Clear()

        $projectSplat = @{
            ProjectId     = $ProjectName
            Description   = $Description
            Process       = $Process
            SourceControl = $SourceControl
            Visibility    = $Visibility
        }

        # Initialize refresh flag
        $refreshProject = $false

        # Check if project exists
        Write-Verbose ("Checking if project '{0}' exists in organization '{1}'..." -f $ProjectName, $Organization)
        $project = Get-AdoProject -ProjectId $ProjectName -Verbose:$VerbosePreference

        if ($null -eq $project) {
            # Create new project
            Write-Verbose ("Project '{0}' does not exist. Creating new project..." -f $ProjectName)
            $project = New-AdoProject @projectSplat -Verbose:$VerbosePreference

            $refreshProject = $true
        } else {
            # Update existing project
            # Write-Verbose ("Project '{0}' exists. Updating project properties if necessary..." -f $ProjectName)
            # $project = Set-AdoProject @projectSplat -Verbose:$VerbosePreference

            $refreshProject = $true
        }

        # Set default team name if different
        if ($project.defaultTeam.name -ne $DefaultTeamName) {
            $defaultTeamSplat = @{
                ProjectId = $project.Id
                TeamId    = $project.DefaultTeam.Id
                Name      = $DefaultTeamName
            }

            Write-Verbose ("Updating default team name for project to '{0}'..." -f $DefaultTeamName)
            Set-AdoTeam @defaultTeamSplat -Verbose:$VerbosePreference | Out-Null

            $refreshProject = $true
        }

        # Update project feature states
        $currentFeatureStates = Get-AdoFeatureState -ProjectName $ProjectName -Verbose:$VerbosePreference

        foreach ($currentFeatureId in $currentFeatureStates.featureIds) {
            # Map feature ID to feature name
            $featureId = switch ($currentFeatureId) {
                'ms.vss-work.agile' { 'Boards' }
                'ms.vss-code.version-control' { 'Repos' }
                'ms.vss-build.pipelines' { 'Pipelines' }
                'ms.vss-test-web.test' { 'TestPlans' }
                'ms.azure-artifacts.feature' { 'Artifacts' }
            }

            if ($Features.ContainsKey($featureId)) {
                $currentFeatureState = $currentFeatureStates.featureStates.$currentFeatureId.state

                # Compare and only update if different
                if ($Features[$featureId] -ne $currentFeatureState) {

                    $featureSplat = @{
                        ProjectId    = $project.id
                        Feature      = $featureId
                        FeatureState = $Features[$featureId]
                    }
                    Write-Verbose ("Updating feature '{0}' to state '{1}'..." -f $featureId, $Features[$featureId])
                    Set-AdoFeatureState @featureSplat -Verbose:$VerbosePreference | Out-Null
                }
            }
        }

        # Get updated project including all relevant data
        if ($refreshProject) {
            Write-Verbose ("Refreshing project '{0}' data..." -f $ProjectName)
            $project = Get-AdoProject -ProjectId $ProjectName -Verbose:$VerbosePreference
        }

        return $project

    } catch {
        throw $_
    }
}

end {
    Write-Debug ('Exit : {0}' -f $MyInvocation.MyCommand.Name)
}
