﻿function Disconnect-AdoOrganization {
    <#
    .SYNOPSIS
    Disconnect from the Azure DevOps organization.

    .DESCRIPTION
    This function removes global variables related to the Azure DevOps connection, effectively disconnecting the session from the specified organization.

    .EXAMPLE
    Disconnect-AdoOrganization

    This disconnects from the currently connected Azure DevOps organization by removing the relevant variables.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param ()

    begin {
        Write-Debug ('{0} entered' -f $MyInvocation.MyCommand)
    }

    process {
        try {
            $ErrorActionPreference = 'Stop'

            $adoContext = Get-AdoContext

            Remove-Variable -Name 'AzDevOpsIsConnected' -Scope Global -ErrorAction SilentlyContinue
            Remove-Variable -Name 'AzDevOpsOrganization' -Scope Global -ErrorAction SilentlyContinue
            Remove-Variable -Name 'AzDevOpsHeaders' -Scope Global -ErrorAction SilentlyContinue

            return $null -ne $adoContext ? @{
                Organization = $adoContext.Organization
                Connected    = $false
            } : $null

        } catch {
            throw $_
        }
    }

    end {
        Write-Debug ('{0} exited' -f $MyInvocation.MyCommand)
    }
}
