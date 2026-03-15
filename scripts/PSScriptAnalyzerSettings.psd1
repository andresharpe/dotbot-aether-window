@{
    # Enable all rules by default
    IncludeDefaultRules = $true

    # Severity levels to include
    Severity = @('Error', 'Warning', 'Information')

    # Rules to explicitly include
    IncludeRules = @(
        'PSAvoidDefaultValueForMandatoryParameter'
        'PSAvoidDefaultValueSwitchParameter'
        'PSAvoidGlobalVars'
        'PSAvoidInvokingEmptyMembers'
        'PSAvoidNullOrEmptyHelpMessageAttribute'
        'PSAvoidShouldContinueWithoutForce'
        'PSAvoidTrailingWhitespace'
        'PSAvoidUsingCmdletAliases'
        'PSAvoidUsingComputerNameHardcoded'
        'PSAvoidUsingConvertToSecureStringWithPlainText'
        'PSAvoidUsingDeprecatedManifestFields'
        'PSAvoidUsingEmptyCatchBlock'
        'PSAvoidUsingInvokeExpression'
        'PSAvoidUsingPlainTextForPassword'
        'PSAvoidUsingPositionalParameters'
        'PSAvoidUsingWMICmdlet'
        'PSAvoidUsingWriteHost'
        'PSDSCDscExamplesPresent'
        'PSDSCDscTestsPresent'
        'PSMisleadingBacktick'
        'PSMissingModuleManifestField'
        'PSPlaceCloseBrace'
        'PSPlaceOpenBrace'
        'PSPossibleIncorrectComparisonWithNull'
        'PSPossibleIncorrectUsageOfAssignmentOperator'
        'PSPossibleIncorrectUsageOfRedirectionOperator'
        'PSProvideCommentHelp'
        'PSReservedCmdletChar'
        'PSReservedParams'
        'PSReturnCorrectTypesForDSCFunctions'
        'PSShouldProcess'
        'PSStandardDSCFunctionsInResource'
        'PSUseApprovedVerbs'
        'PSUseBOMForUnicodeEncodedFile'
        'PSUseCmdletCorrectly'
        'PSUseCompatibleCmdlets'
        'PSUseCompatibleCommands'
        'PSUseCompatibleSyntax'
        'PSUseCompatibleTypes'
        'PSUseConsistentIndentation'
        'PSUseConsistentWhitespace'
        'PSUseCorrectCasing'
        'PSUseDeclaredVarsMoreThanAssignments'
        'PSUseLiteralInitializerForHashtable'
        'PSUseOutputTypeCorrectly'
        'PSUseProcessBlockForPipelineCommand'
        'PSUsePSCredentialType'
        'PSUseShouldProcessForStateChangingFunctions'
        'PSUseSingularNouns'
        'PSUseSupportsShouldProcess'
        'PSUseToExportFieldsInManifest'
        'PSUseUsingScopeModifierInNewRunspaces'
        'PSUseUTF8EncodingForHelpFile'
    )

    # Rules to exclude (with justification)
    ExcludeRules = @(
        # We intentionally use Write-Host for colored console output in examples
        # and user-facing messages in public functions
        # 'PSAvoidUsingWriteHost'

        # Allow positional parameters in simple cases (common PowerShell idiom)
        'PSAvoidUsingPositionalParameters'
    )

    # Code formatting rules
    Rules = @{
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $false
        }

        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator = $true
            CheckParameter = $false
        }

        PSAlignAssignmentStatement = @{
            Enable = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing = @{
            Enable = $true
        }

        # Comment-based help requirement for exported functions
        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $true
            BlockComment = $true
            VSCodeSnippetCorrection = $false
            Placement = 'before'
        }

        # ShouldProcess for state-changing functions
        PSUseShouldProcessForStateChangingFunctions = @{
            Enable = $true
        }

        # Compatibility checks
        PSUseCompatibleSyntax = @{
            Enable = $true
            TargetVersions = @('5.1', '7.0')
        }

        PSUseCompatibleCmdlets = @{
            Enable = $true
            Compatibility = @('desktop-5.1.14393.206-windows', 'core-7.0.0-windows')
        }

        PSUseCompatibleCommands = @{
            Enable = $false
            # Disabled: Missing compatibility profile files on this system
            # TargetProfiles = @(
            #     'win-8_x64_10.0.14393.0_5.1.14393.2791_x64_4.0.30319.42000_framework'
            #     'win-8_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core'
            # )
        }
    }
}
