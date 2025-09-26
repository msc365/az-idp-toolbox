# PSScriptAnalyzer settings file
@{
    # Severity levels to include
    Severity          = @('Error', 'Warning', 'Information')

    # Rules to exclude (customize as needed)
    ExcludeRules      = @(
        'PSUseShouldProcessForStateChangingFunctions',  # Not needed for utility functions
        'PSAvoidUsingWriteHost',  # Allow Write-Host for user communication
        'PSUseConsistentWhitespace' # Disable consistent whitespace rule due to false positives
    )

    # Paths to exclude from analysis
    ExcludeRulesPaths = @(
        '*.psd1'  # Exclude module manifest files
    )

    # Rules to include (all by default)
    IncludeRules      = @('*')

    # Custom rules settings
    Rules             = @{
        PSProvideCommentHelp       = @{
            Enable                  = $true
            ExportedOnly            = $true
            BlockComment            = $true
            VSCodeSnippetCorrection = $true
            Placement               = 'before'
        }

        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable              = $true
            Kind                = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize     = 4
        }

        PSUseConsistentWhitespace  = @{
            Enable                          = $true
            CheckInnerBrace                 = $true
            CheckOpenBrace                  = $true
            CheckOpenParen                  = $true
            CheckOperator                   = $true
            CheckPipe                       = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator                  = $true
            CheckParameter                  = $false
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing         = @{
            Enable = $true
        }
    }
}
