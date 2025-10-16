# CSpell: disable

<#PSScriptInfo

.VERSION 1.0

.GUID f09ae93f-fde3-4a29-b018-7118dc21b8bb

.AUTHOR Martin Swinkels

.COMPANYNAME MSc365.eu

.COPYRIGHT 2025 (c) MSc365.eu, Martin Swinkels

.TAGS 'Azure', 'IDP', 'Toolbox', 'Utilities', 'Security', 'Governance', 'DevOps', 'Platform', 'RBAC'

.LICENSEURI https://github.com/msc365/az-idp-toolbox/blob/main/LICENSE

.PROJECTURI https://github.com/msc365/az-idp-toolbox

.ICONURI https://raw.githubusercontent.com/msc365/az-idp-toolbox/main/.assets/icon.png

.EXTERNALMODULEDEPENDENCIES Az.Accounts, Az.Resources, Az.ManagedServiceIdentity, Microsoft.Graph.Authentication, Microsoft.Graph.Groups, Microsoft.Graph.Users
#>

<#
.SYNOPSIS
Invoke bootstrap for end-to-end RBAC governance on an Azure DevOps project.

.DESCRIPTION

This script bootstraps an end-to-end RBAC governance Azure DevOps project, based on a JSON configuration file including:
- Teams
- Entra ID Security Groups
- Azure resources
- Managed Identities
- Service Connections
- Azure Role Assignments

.EXAMPLE
. '.\scripts\Invoke-AdoE2eRbacProject.ps1' -ConfigFileName '.\samples\bootstrapConfig1.json'

This bootstraps an end-to-end RBAC governance Azure DevOps project based on the specified JSON configuration file.

.PARAMETER ConfigFilePath
Required. The path to the JSON configuration file.

.NOTES
Required permissions

- Connect to Azure

$azParams = @{
    TenantId = '<YOUR_TENANT_ID>'
    SubscriptionId = '<YOUR_SUBSCRIPTION_ID>'
}
Connect-AzAccount @azParams

- Connect to Microsoft Graph

$mgParams = @{
    Scopes    = @(
        'User.Read.All'
        'Group.ReadWrite.All'
        'RoleManagement.ReadWrite.Directory'
    ) -join ','
    NoWelcome = $true
}
Connect-MgGraph @mgParams

The subscriptions must be registered to use the 'Microsoft.ManagedIdentity' provider.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '', Justification = 'Write-Host is allowed to display tests status messages') ]
param (
    [Parameter(Mandatory = $true)]
    [string]$ConfigFilePath
)

begin {
    Write-Debug ('{0} entered' -f $MyInvocation.MyCommand.Name)

    $rootPath = (Get-Item $PSScriptRoot).Parent

    if (-not (Test-Path -Path $ConfigFilePath)) {
        throw ('Configuration file not found: {0}' -f $ConfigFilePath)
    }

    # Import required modules
    $modules = @(
        'MSc365.Idp.Toolbox'
    )
    $modules | ForEach-Object {
        if (-not (Get-Module -Name $_ -ListAvailable)) {
            Import-Module ('{0}\src\{1}' -f $rootPath, $_) -Force -Verbose:$false
        }
    }

    # Read content from variables.json file
    $vars = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json

    # Set global variables
    $separator = $vars.global.nameSeparator

    $tags = @{}
    $vars.global.tags.PSObject.Properties | ForEach-Object {
        $tags[$_.Name] = $_.Value
    }

    $ctx = Get-AzContext
    if ($null -eq $ctx) {
        throw 'Not connected to Azure. Please connect using Connect-AzAccount.'
    }

    # Connect to MgGraph
    if ($null -eq (Get-MgContext)) {
        throw 'Not connected to Microsoft Graph. Please connect using Connect-MgGraph.'
    }

    # Connect to Azure DevOps Organization
    Connect-AdoOrganization -Organization $vars.devops.organization -Verbose:$VerbosePreference
}

process {
    try {
        $ErrorActionPreference = 'Stop'
        $Error.Clear()

        # Create an array to store projects
        $projects = @()

        # Iterate through json project objects
        Write-Host 'Starting bootstrap process.' -ForegroundColor Magenta

        foreach ($p in $vars.projects) {
            #region project

            # Set project name
            $projectName = '{1}{0}{2}' -f $separator, $vars.global.prefix, $p.name # "e2egov-avengers"
            Write-Host ('Processing {0} project' -f $projectName) -ForegroundColor Magenta

            # Check if project exists
            $project = Get-AdoProject -ProjectName $projectName -Verbose:$VerbosePreference

            if ($null -eq $project) {
                # Create new project
                $params = @{
                    Name          = $projectName
                    Description   = $p.description
                    Process       = $p.process
                    SourceControl = $p.sourceControl
                    Visibility    = $p.visibility
                }

                $project = New-AdoProject @params -Verbose:$VerbosePreference

                # Get project with all relevant data
                $project = Get-AdoProject -ProjectName $projectName -Verbose:$VerbosePreference
            }

            # Update project default team name
            $tmParams = @{
                ProjectId = $project.Id
                TeamId    = $project.DefaultTeam.Id
                Name      = ((($projectName -replace $vars.global.prefix, '') -replace $separator, ' ') -replace '\b(\w)', { $_.Value.ToUpper() }).Trim()
            }

            Set-AdoTeam @tmParams -Verbose:$VerbosePreference | Out-Null

            # Get project with all up-to-date data
            $project = Get-AdoProject -ProjectName $projectName -Verbose:$VerbosePreference

            #endregion

            #region project features

            foreach ($f in $p.features.PSObject.Properties) {

                $ftrParams = @{
                    ProjectId    = $project.id
                    Feature      = ($f.Name -replace '_', '')
                    FeatureState = $f.Value
                }

                # Set feature state
                Set-AdoFeatureState @ftrParams -Verbose:$VerbosePreference | Out-Null
            }

            #endregion

            #region project built-in groups

            $descriptor = Get-AdoDescriptor -StorageKey $project.id -Verbose:$VerbosePreference
            $builtInGroups = (Get-AdoGroup -ScopeDescriptor $descriptor.value -SubjectTypes 'vssgp' -Verbose:$VerbosePreference).value

            $builtInProjectAdministrators = ($builtInGroups | Where-Object displayName -EQ 'Project Administrators')
            $builtInContributors = ($builtInGroups | Where-Object displayName -EQ 'Contributors')
            $builtInReaders = ($builtInGroups | Where-Object displayName -EQ 'Readers')

            #endregion

            #region project groups

            # Create arrays to store group data
            $groups = @()

            # Get initial subscription context
            $tenantId = $ctx.Tenant.Id
            $subId = $ctx.Subscription.Id

            # Create environment, security group, identity and service connection
            $syncGroups = $false
            foreach ($g in $p.groups) {
                # Set subscription context
                Set-AzContext -Tenant $tenantId -SubscriptionId $g.subscriptionId | Out-Null

                #region [1-8] initial variables

                $environment = $null
                $securityGroup = $null
                $managedIdentity = $null
                $serviceConnection = $null

                # Generate resource names
                $groupName = 'sg{0}{1}{0}{2}' -f $separator, $projectName, $g.name                     # "sg-e2egov-avengers-admins"
                $regionCode = $vars.global.regions.PSObject.Properties[$g.location].Value              # 'weu'
                $resourceSuffix = '{1}{0}{2}' -f $separator, $g.environment, $regionCode               # 'prd-weu'
                $identityName = 'id{0}{1}{0}{2}' -f $separator, $projectName, $resourceSuffix          # 'id-e2egov-avengers-prd-weu'
                $resourceGroupName = 'rg{0}{1}{0}{2}' -f $separator, $projectName, $resourceSuffix     # 'rg-e2egov-avengers-prd-weu'
                $serviceConnectionName = 'rg{0}{1}{0}{2}' -f $separator, $projectName, $resourceSuffix # 'rg-e2egov-avengers-prd-weu'

                $writeHostSplat = @{
                    NoNewline = (-not $VerbosePreference)
                }
                Write-Host ('  Processing {0} group' -f $g.name) @writeHostSplat

                #endregion

                #region [2-8] environment

                if ($g.environment -ne '{none}') {

                    # Check if resource group exists
                    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue -Verbose:$VerbosePreference

                    if ($null -eq $resourceGroup) {

                        # Create new resource group as environment
                        $rgParams = @{
                            Name     = $resourceGroupName
                            Location = $g.location
                            Tags     = $tags
                        }

                        $resourceGroup = New-AzResourceGroup @rgParams -Verbose:$VerbosePreference
                    }

                    $environment = [pscustomobject]@{
                        name     = $resourceGroup.ResourceGroupName
                        location = $resourceGroup.Location
                        tags     = $resourceGroup.Tags
                    }
                }

                #endregion

                #region [3-8] security group

                # Check if group exists
                $grp = Get-MgGroup -Filter "mailNickname eq '$($groupName)'" -ErrorAction SilentlyContinue -Verbose:$VerbosePreference

                if ($null -eq $grp) {
                    # Create new group
                    $sgParams = @{
                        DisplayName        = $groupName
                        MailNickname       = $groupName
                        Description        = $g.description
                        MailEnabled        = $false
                        SecurityEnabled    = $true
                        IsAssignableToRole = $true
                        Visibility         = 'Private'
                    }

                    $grp = New-MgGroup @sgParams -Verbose:$VerbosePreference

                    $syncGroups = $true
                }

                $securityGroup = [pscustomobject]@{
                    objectId        = $grp.Id
                    displayName     = $grp.DisplayName
                    mailNickname    = $grp.MailNickname
                    createdDateTime = $grp.CreatedDateTime
                }

                #endregion

                #region [4-8] managed identity

                if ($g.environment -ne '{none}') {
                    $uaiParams = @{
                        Name              = $identityName
                        ResourceGroupName = $resourceGroupName
                        SubscriptionId    = $g.subscriptionId
                    }

                    # Check if managed identity exists
                    $identity = Get-AzUserAssignedIdentity @uaiParams -ErrorAction SilentlyContinue -Verbose:$VerbosePreference

                    if ($null -eq $identity) {
                        $uaiParams += @{
                            Location = $g.location
                            Tag      = $tags
                        }

                        # Create new managed identity
                        $identity = New-AzUserAssignedIdentity @uaiParams -Verbose:$VerbosePreference
                    }

                    $managedIdentity = [pscustomobject]@{
                        name        = $identity.Name
                        clientId    = $identity.ClientId
                        principalId = $identity.PrincipalId
                        tenantId    = $identity.TenantId
                    }
                }

                #endregion

                #region [5-8] service connection

                if ($g.environment -ne '{none}') {

                    # Check if service connection exists
                    $scParams = @{
                        ProjectId    = $project.id
                        EndPointName = $serviceConnectionName
                    }

                    $serviceEndpoint = Get-AdoServiceEndpoint @scParams -Verbose:$VerbosePreference

                    if ($null -eq $serviceEndpoint) {

                        $data = [ordered]@{
                            creationMode     = 'Manual'
                            environment      = 'AzureCloud'
                            scopeLevel       = 'Subscription'
                            subscriptionId   = $g.subscriptionId
                            subscriptionName = $g.subscriptionName
                        }

                        $endpointConfig = [ordered]@{
                            data                             = $data
                            name                             = $serviceConnectionName
                            type                             = 'AzureRM'
                            url                              = 'https://management.azure.com/'
                            authorization                    = [ordered]@{
                                parameters = [ordered]@{
                                    serviceprincipalid = $managedIdentity.clientId
                                    tenantid           = $managedIdentity.tenantId
                                    scope              = ('/subscriptions/{0}/resourcegroups/{1}' -f $g.subscriptionId, $resourceGroupName)
                                }
                                scheme     = 'WorkloadIdentityFederation'
                            }
                            isShared                         = $false
                            isReady                          = $true
                            serviceEndpointProjectReferences = @(
                                [ordered]@{
                                    name             = $serviceConnectionName
                                    projectReference = [ordered]@{
                                        id   = $project.id
                                        name = $project.name
                                    }
                                }
                            )
                        }

                        # Create new service connection
                        $params = @{
                            Configuration = ($endpointConfig | ConvertTo-Json -Depth 4)
                        }

                        $serviceEndpoint = New-AdoServiceEndpoint @params -ErrorAction Stop -Verbose:$VerbosePreference
                    }

                    # Verify if federated identity credential exists
                    $credParams = @{
                        IdentityName      = $identityName
                        SubscriptionId    = $g.subscriptionId
                        ResourceGroupName = $resourceGroupName
                    }
                    $credential = Get-AzFederatedIdentityCredential @credParams -ErrorAction SilentlyContinue -Verbose:$VerbosePreference

                    # Set credential name
                    $credentialName = 'cred-{0}' -f $serviceConnectionName.Substring(3)

                    # Add credential parameters
                    $credParams += @{
                        Name    = $credentialName
                        Issuer  = $serviceEndpoint.authorization.parameters.workloadIdentityFederationIssuer
                        Subject = $serviceEndpoint.authorization.parameters.workloadIdentityFederationSubject
                    }

                    # Create/update federated identity credential
                    if ($null -eq $credential) {
                        New-AzFederatedIdentityCredential @credParams -Verbose:$VerbosePreference | Out-Null
                    } else {
                        Update-AzFederatedIdentityCredential @credParams -Verbose:$VerbosePreference | Out-Null
                    }

                    $serviceConnection = [pscustomobject]@{
                        id            = $serviceEndpoint.id
                        name          = $serviceEndpoint.name
                        authorization = $serviceEndpoint.authorization
                        creationDate  = $serviceEndpoint.creationDate
                    }
                }

                #endregion

                #region [6-8] build group object summary +1

                $group = [pscustomobject]@{
                    subscriptionId    = $g.subscriptionId
                    subscriptionName  = $g.subscriptionName
                    environment       = $environment
                    securityGroup     = $securityGroup
                    managedIdentity   = $managedIdentity
                    serviceConnection = $serviceConnection
                    roleAssignments   = $g.roleAssignments
                }

                # Add team to teams array
                $groups += $group

                # Add group to project object
                $project | Add-Member -MemberType NoteProperty -Name $g.name -Value $group

                #endregion

                Write-Host ' ✓ done' -ForegroundColor DarkGray
            }

            #region [7-8] sync groups

            if ($syncGroups) {
                # Wait 15 seconds for Entra ID security group synchronization
                for ($i = 0; $i -le 15; $i++) {
                    Write-Progress -Activity 'Waiting Entra ID Sync' -Status ('{0} seconds remaining' -f (15 - $i)) -PercentComplete (($i / 15) * 100)
                    Start-Sleep -Seconds 1
                }

                Write-Progress -Activity 'Waiting Entra ID Sync' -Status 'Completed' -Completed
            }

            #endregion

            #region [8-8] devops group membership

            Write-Host '  Processing group memberships' -NoNewline

            foreach ($g in $groups) {
                foreach ($m in $g.groupMembership) {
                    switch ($m) {
                        'Project Administrators' {
                            New-AdoGroupMembership -GroupDescriptor $builtInProjectAdministrators.descriptor `
                                -GroupId $g.securityGroup.objectId -Verbose:$VerbosePreference
                        }
                        'Contributors' {
                            New-AdoGroupMembership -GroupDescriptor $builtInContributors.descriptor `
                                -GroupId $g.securityGroup.objectId -Verbose:$VerbosePreference
                        }
                        'Readers' {
                            New-AdoGroupMembership -GroupDescriptor $builtInReaders.descriptor `
                                -GroupId $g.securityGroup.objectId -Verbose:$VerbosePreference
                        }
                        default {}
                    }
                }
            }

            Write-Host ' ✓ done' -ForegroundColor DarkGray

            #endregion

            #region [9-8] azure role assignments

            Write-Host '  Processing role assignments' -NoNewline

            foreach ($g in $groups) {
                foreach ($r in $g.roleAssignments) {
                    $scope = ('/subscriptions/{0}/resourcegroups/{1}' -f
                        $g.subscriptionId, $g.environment.name)

                    $roleParams = @{
                        Scope              = $scope
                        RoleDefinitionName = $r.definitionName
                    }

                    if ($r.objectType -eq 'Group') {
                        $roleParams += @{
                            ObjectId = $g.securityGroup.objectId
                        }
                    } elseif ($r.objectType -eq 'ServicePrincipal') {
                        $roleParams += @{
                            ObjectId = $g.managedIdentity.principalId
                        }
                    }

                    $roleAssignment = Get-AzRoleAssignment -Scope $roleParams.Scope | Where-Object {
                        $_.ObjectId -eq $roleParams.ObjectId -and
                        $_.RoleDefinitionName -eq $roleParams.RoleDefinitionName
                    }

                    if ($null -eq $roleAssignment) {
                        # New role assignment
                        $roleAssignment = New-AzRoleAssignment @roleParams -ErrorAction Stop
                    }
                }
            }

            Write-Host ' ✓ done' -ForegroundColor DarkGray

            #endregion

            # Reset subscription context
            Set-AzContext -SubscriptionId $subId | Out-Null

            #endregion

            #region project teams

            # Create array to store teams
            $teams = @()
            foreach ($t in $p.teams) {
                Write-Host ('  Processing {0} team' -f $t.name) -NoNewline

                $tmParams = @{
                    ProjectId = $project.Id
                }

                # Check if team exists
                $response = Get-AdoTeam @tmParams -Verbose:$VerbosePreference
                $team = $response | Where-Object { $_.name -eq $t.name }

                if ($null -eq $team) {
                    # create new team
                    $tmParams += @{
                        Name        = $t.name
                        Description = $t.description
                    }

                    $team = New-AdoTeam @tmParams -Verbose:$VerbosePreference
                }

                # Add team to teams array
                $teams += [pscustomobject]@{
                    id   = $team.id
                    name = $team.name
                }

                Write-Host ' ✓ done' -ForegroundColor DarkGray
            }

            # Add team to project object
            $project | Add-Member -MemberType NoteProperty -Name teams -Value $teams

            #endregion

            # Add project to the array
            $projects += $project

            Write-Host '  ✓ Completed' -ForegroundColor Green
        }

        Write-Host "`nBootstrap process completed." -ForegroundColor Green

        return $projects

    } catch {
        Write-Host '  ✕ Failure' -ForegroundColor Red
        throw $_
    }

    finally {
        Write-Progress -Activity 'Progress' -Status 'Completed' -Completed
    }
}

end {
    Write-Debug ('{0} exited' -f $MyInvocation.MyCommand.Name)
}
