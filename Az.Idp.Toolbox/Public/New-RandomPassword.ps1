<#PSScriptInfo

.VERSION 1.0

.GUID 21e37b80-3a9d-46c2-94cc-a755629a6ef3

.AUTHOR martin.swinkels@msc365.eu

#>
function New-RandomPassword {
    <#
    .SYNOPSIS
    Creates a random password.

    .DESCRIPTION
    Creates a secure random password of specified length and optional characteristics.

    .EXAMPLE

    .OUTPUTS
    System.Security.SecureString

    .EXAMPLE
    #>
    [CmdletBinding()]
    [OutputType([System.Security.SecureString])]
    param (
        [Parameter(HelpMessage = 'Length of the password to generate')]
        [ValidateRange(1, 256)]
        [int]$Length = 16,

        [Parameter(HelpMessage = 'Include lowercase characters')]
        [switch]$IncludeLowercase,

        [Parameter(HelpMessage = 'Include uppercase characters')]
        [switch]$IncludeUppercase,

        [Parameter(HelpMessage = 'Include numeric characters')]
        [switch]$IncludeNumeric,

        [Parameter(HelpMessage = 'Include special characters')]
        [switch]$IncludeSpecial
    )

    begin {
        Write-Debug ('{0} entered' -f $MyInvocation.MyCommand)

        $lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz'
        $upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        $numberChars = '0123456789'
        $specialChars = '!@#$%^&*()-_=+[]{}|;:,.<>?/~'
    }

    process {
        try {
            # If no character types specified, include all by default
            if (-not ($IncludeLowercase -or $IncludeUppercase -or $IncludeNumeric -or $IncludeSpecial)) {
                $IncludeLowercase = $true
                $IncludeUppercase = $true
                $IncludeNumeric = $true
                $IncludeSpecial = $true

                Write-Verbose 'No character types specified, using all character types'
            }

            $charPool = ''
            if ($IncludeLowercase) {
                $charPool += $lowerCaseChars
                Write-Verbose 'Including lowercase characters'
            }
            if ($IncludeUppercase) {
                $charPool += $upperCaseChars
                Write-Verbose 'Including uppercase characters'
            }
            if ($IncludeNumeric) {
                $charPool += $numberChars
                Write-Verbose 'Including numeric characters'
            }
            if ($IncludeSpecial) {
                $charPool += $specialChars
                Write-Verbose 'Including special characters'
            }

            # Create a secure string object
            $secureString = New-Object System.Security.SecureString

            # Generate a random number
            $rand = New-Object System.Random

            # Generate the password
            for ($i = 0; $i -lt $Length; $i++) {
                $index = $rand.Next(0, $charPool.Length)
                $char = $charPool[$index]
                $secureString.AppendChar($char)
            }

            # Return the secure string
            Write-Verbose 'Password generation completed successfully'
            return $secureString

        } catch {
            throw $_
        }
    }

    end {
        Write-Debug ('{0} exited' -f $MyInvocation.MyCommand)
    }
}
