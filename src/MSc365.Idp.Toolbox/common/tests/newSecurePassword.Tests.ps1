#Requires -Modules Pester

# cSpell: disable

BeforeAll {
    # Import the module for testing
    $moduleName = 'common'
    $modulePath = (Get-Item $PSScriptRoot).Parent.FullName

    # Remove module if already loaded
    if (Get-Module -Name $moduleName -ErrorAction SilentlyContinue) {
        Remove-Module -Name $moduleName -Force
    }

    # Import the module
    Import-Module $modulePath -Force -ErrorAction Stop
}

Describe 'Module: common' -Tags 'Module' {
    Context 'Module Import' {
        It 'Should import successfully' {
            Get-Module -Name $moduleName | Should -Not -BeNullOrEmpty
        }

        It 'Should export expected functions' {
            $exportedFunctions = (Get-Module -Name $moduleName).ExportedFunctions.Keys
            $exportedFunctions | Should -Contain 'New-SecurePassword'
        }

        It 'Should have valid manifest' {
            Test-ModuleManifest -Path ('{0}\{1}.psd1' -f $modulePath, $moduleName) | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Function: New-SecurePassword' -Tags 'Function' {
    Context 'Parameter Validation' {
        It 'Should accept valid length parameter' {
            { New-SecurePassword -Length 16 } | Should -Not -Throw
        }

        It 'Should reject invalid length (zero)' {
            { New-SecurePassword -Length 0 } | Should -Throw
        }

        It 'Should reject invalid length (negative)' {
            { New-SecurePassword -Length -1 } | Should -Throw
        }

        It 'Should reject invalid length (too large)' {
            { New-SecurePassword -Length 999999 } | Should -Throw
        }
    }

    Context 'Default Behavior' {
        It 'Should generate a secure string with default length' {
            $result = New-SecurePassword
            $result | Should -BeOfType 'System.Security.SecureString'
            $result.Length | Should -Be 16
        }

        It 'Should generate different passwords on multiple calls' {
            $password1 = New-SecurePassword
            $password2 = New-SecurePassword

            # Convert to plain text for comparison (only for testing)
            $ptr1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1)
            $ptr2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2)

            try {
                $plain1 = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr1)
                $plain2 = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr2)
                $plain1 | Should -Not -Be $plain2
            } finally {
                [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr1)
                [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr2)
            }
        }
    }

    Context 'Length Specifications' {
        It 'Should generate password with specified length: <Length>' -TestCases @(
            @{ length = 8 }
            @{ length = 16 }
            @{ length = 32 }
            @{ length = 64 }
            @{ length = 128 }
        ) {
            param($length)

            $result = New-SecurePassword -Length $length
            $result.Length | Should -Be $length
            $result | Should -BeOfType 'System.Security.SecureString'
        }
    }

    Context 'Character Type Specifications' {
        It 'Should work with only lowercase characters' {
            $result = New-SecurePassword -Length 16 -IncludeLowercase
            $result | Should -BeOfType 'System.Security.SecureString'
            $result.Length | Should -Be 16
        }

        It 'Should work with only uppercase characters' {
            $result = New-SecurePassword -Length 16 -IncludeUppercase
            $result | Should -BeOfType 'System.Security.SecureString'
            $result.Length | Should -Be 16
        }

        It 'Should work with only numbers' {
            $result = New-SecurePassword -Length 16 -IncludeNumeric
            $result | Should -BeOfType 'System.Security.SecureString'
            $result.Length | Should -Be 16
        }

        It 'Should work with only special characters' {
            $result = New-SecurePassword -Length 16 -IncludeSpecial
            $result | Should -BeOfType 'System.Security.SecureString'
            $result.Length | Should -Be 16
        }

        It 'Should work with combination of character types' {
            $result = New-SecurePassword -Length 16 -IncludeLowercase -IncludeUppercase -IncludeNumeric
            $result | Should -BeOfType 'System.Security.SecureString'
            $result.Length | Should -Be 16
        }
    }

    Context 'Error Handling' {
        It 'Should handle edge cases gracefully' {
            { New-SecurePassword -Length 1 -IncludeLowercase } | Should -Not -Throw
        }
    }
}

AfterAll {
    # Clean up
    if (Get-Module -Name $moduleName -ErrorAction SilentlyContinue) {
        Remove-Module -Name $moduleName -Force
    }
}
