<#
.SYNOPSIS
Deploy Role Definitions at Management Group scope.

.DESCRIPTION
This script deploys custom Role Definitions to a specified Management Group using a Bicep template.

.PARAMETER ManagementGroupId
The ID of the Management Group where the Role Definitions will be deployed. For example 'mg-alz-intermediate-stg'.

.PARAMETER Location
The Azure region where the deployment metadata will be stored. Default is 'westeurope'.

.PARAMETER TemplateFile
The path to the Bicep template file that defines the Role Definitions. Default is 'iac\authorization\role-definition\main.bicep'.

.PARAMETER TemplateParameterFile
The path to the Bicep parameter file that provides parameters for the template. Default is 'iac\authorization\role-definition\main.bicepparam'.

.EXAMPLE
.\iac\authorization\role-definition\deploy.ps1 -ManagementGroupId 'mg-alz-intermediate-stg' -Verbose

This deploys the Role Definitions to the 'mg-alz-intermediate-stg' Management Group with verbose output.
#>
[CmdletBinding(SupportsShouldProcess)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '', Justification = 'Write-Host is allowed to display tests status messages') ]
param (
    [Parameter(Mandatory = $true)]
    [String]$ManagementGroupId,

    [Parameter()]
    [string]$Location = 'westeurope',

    [Parameter()]
    [String]$TemplateFile = 'iac\authorization\role-definition\main.bicep',

    [Parameter()]
    [string]$TemplateParameterFile = 'iac\authorization\role-definition\main.bicepparam'
)

begin {
    Write-Debug ('{0} entered' -f $MyInvocation.MyCommand.Name)
    Write-Verbose '------ START SCRIPT ------' -Verbose
}

process {
    try {

        $ctx = Get-AzContext
        Write-Host 'Context'
        Write-Host ('- Account      : {0}' -f $ctx.Account)
        Write-Host ('- Tenant       : {0}' -f $ctx.Tenant.Id)
        Write-Host ('- Subscription : {0}' -f $ctx.Subscription.Name)

        Write-Verbose '------------------------------' -Verbose
        Write-Verbose 'Deploy [Role Definitions]     ' -Verbose
        Write-Verbose '------------------------------' -Verbose

        $params = @{
            Name                  = -join ('e2egov-cpdfs-deploy-{0}' -f (Get-Date -Format 'yyyyMMdd-hhmmss'))[0..63]
            Location              = $Location
            ManagementGroupId     = $ManagementGroupId
            TemplateFile          = $TemplateFile
            TemplateParameterFile = $TemplateParameterFile
            Verbose               = $VerbosePreference
            WhatIf                = $WhatIfPreference
        }

        New-AzManagementGroupDeployment @params -Verbose

    } catch {
        throw $_
    }
}

end {
    Write-Verbose '------- END SCRIPT -------' -Verbose
    Write-Debug ('{0} exited' -f $MyInvocation.MyCommand.Name)
}
