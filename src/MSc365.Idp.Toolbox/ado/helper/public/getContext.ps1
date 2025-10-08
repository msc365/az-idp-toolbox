function Get-AdoContext {
    <#
    .SYNOPSIS
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

            $isConnected = Get-Variable -Name 'AzDevOpsIsConnected' -Scope Global -ErrorAction SilentlyContinue
            $organization = Get-Variable -Name 'AzDevOpsOrganization' -Scope Global -ErrorAction SilentlyContinue

            if ($null -ne $isConnected -and $isConnected.Value -and $null -ne $organization) {
                return @{
                    Connected    = $isConnected.Value
                    Organization = $organization.Value
                }
            } else {
                return $null
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug ('{0} exited' -f $MyInvocation.MyCommand)
    }
}
