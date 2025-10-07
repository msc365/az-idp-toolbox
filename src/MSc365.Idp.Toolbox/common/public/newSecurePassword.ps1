function New-SecurePassword {
    <#
    .SYNOPSIS
    Create a secure random password.

    .DESCRIPTION
    This cmdlet creates a secure random password of specified length and optional characteristics.

    .PARAMETER Length
    Length of the password to generate. Default is 16.

    .PARAMETER IncludeLowercase
    Include lowercase characters in the password.

    .PARAMETER IncludeUppercase
    Include uppercase characters in the password.

    .PARAMETER IncludeNumeric
    Include numeric characters in the password.

    .PARAMETER IncludeSpecial
    Include special characters in the password.

    .OUTPUTS
    System.Security.SecureString

    .EXAMPLE
    $password = New-SecurePassword

    This example generates a 16-character password with all character types included by default.

    .EXAMPLE
    $password = New-SecurePassword -Length 20 -IncludeLowercase -IncludeUppercase -IncludeNumeric
    ConvertFrom-SecureString $password -AsPlainText

    This example generates a 20-character password with lowercase, uppercase, and numeric characters, and then passes the SecureString to reveal the password as plain text.

    #>
    [CmdletBinding()]
    [OutputType([System.Security.SecureString])]
    param (
        [Parameter()]
        [ValidateRange(1, 256)]
        [int]$Length = 16,

        [Parameter()]
        [switch]$IncludeLowercase,

        [Parameter()]
        [switch]$IncludeUppercase,

        [Parameter()]
        [switch]$IncludeNumeric,

        [Parameter()]
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
