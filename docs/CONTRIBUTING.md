# Contributing to Pixoo64 PowerShell Module

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)

## Code of Conduct

This project follows a simple code of conduct: **Be respectful and constructive**.

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Accept constructive criticism gracefully
- Focus on what's best for the community

## Getting Started

### Prerequisites

- PowerShell 5.1 or later (Windows) or PowerShell 7+ (cross-platform)
- Pester 5.x for testing
- PSScriptAnalyzer for linting
- Git for version control
- Pixoo64 device (optional, for integration testing)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```powershell
   git clone https://github.com/yourusername/Pixoo.git
   cd Pixoo
   ```

## Development Setup

### 1. Install Development Dependencies

```powershell
# Install Pester (testing framework)
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck

# Install PSScriptAnalyzer (linting)
Install-Module -Name PSScriptAnalyzer -Force
```

### 2. Import the Module

```powershell
Import-Module .\src\Pixoo64\Pixoo64.psd1 -Force
```

### 3. Verify Setup

```powershell
# Check module loaded
Get-Command -Module Pixoo64

# Run linter
Invoke-ScriptAnalyzer -Path .\src\Pixoo64 -Recurse

# Run unit tests
Invoke-Pester -Path .\tests\Unit\
```

## Coding Standards

### PowerShell Best Practices

1. **Function Naming**
   - Use approved verbs: `Get-Verb` to see list
   - Always prefix nouns with `Pixoo` (e.g., `Set-PixooBrightness`)
   - Use PascalCase for function names

2. **Parameter Naming**
   - Use PascalCase for parameter names
   - Use descriptive names
   - Add validation attributes where appropriate

3. **Comment-Based Help**
   - All public functions MUST have complete CBH
   - Include: SYNOPSIS, DESCRIPTION, PARAMETER, EXAMPLE, NOTES
   - Provide at least 2 examples

4. **Error Handling**
   - Use `try/catch` blocks
   - Call `$PSCmdlet.ThrowTerminatingError()` for proper error propagation
   - Provide descriptive error messages

5. **Code Style**
   - Use 4-space indentation (not tabs)
   - Opening braces on same line
   - Closing braces on new line
   - Use `Write-Verbose` for debugging output

### Example Function Template

```powershell
function Verb-PixooNoun {
    <#
    .SYNOPSIS
        Brief description

    .DESCRIPTION
        Detailed description

    .PARAMETER ParameterName
        Parameter description

    .EXAMPLE
        Verb-PixooNoun -ParameterName Value

    .NOTES
        API Endpoint: Category/Command
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$ParameterName
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Perform action"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                $response = Invoke-PixooCommand -Command @{
                    Command = 'Category/Command'
                    Parameter = $ParameterName
                }
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
```

## Testing

### Writing Unit Tests

1. **Create test file** in `tests/Unit/Public/` or `tests/Unit/Private/`
2. **Name convention**: `FunctionName.Tests.ps1`
3. **Use Pester 5.x syntax**
4. **Mock external dependencies** (use `InModuleScope` for internal state)

Example unit test:

```powershell
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\src\Pixoo64\Pixoo64.psd1'
    Import-Module $ModulePath -Force
}

Describe 'Set-PixooBrightness' {
    BeforeEach {
        InModuleScope Pixoo64 {
            $script:PixooSession = @{
                Uri = 'http://192.168.0.73:80/post'
                Connected = $true
            }
        }
    }

    It 'Sets brightness correctly' {
        InModuleScope Pixoo64 {
            Mock Invoke-PixooCommand {
                return [PSCustomObject]@{ error_code = 0 }
            }

            { Set-PixooBrightness -Brightness 50 } | Should -Not -Throw
        }
    }

    It 'Validates brightness range' {
        InModuleScope Pixoo64 {
            { Set-PixooBrightness -Brightness 150 } | Should -Throw
        }
    }
}
```

### Writing Integration Tests

1. **Create test file** in `tests/Integration/`
2. **Tag with `'Integration'`** for easy filtering
3. **Check for `$env:PIXOO_TEST_IP`** and skip if not set
4. **Clean up after tests** (restore original settings)

Example integration test:

```powershell
Describe 'Brightness Integration' -Tag 'Integration' {
    BeforeAll {
        if (-not $env:PIXOO_TEST_IP) {
            Set-ItResult -Skipped -Because "PIXOO_TEST_IP not set"
        }
        Connect-Pixoo -IPAddress $env:PIXOO_TEST_IP
        $originalBrightness = (Get-PixooConfiguration).Brightness
    }

    AfterAll {
        Set-PixooBrightness -Brightness $originalBrightness
        Disconnect-Pixoo
    }

    It 'Changes brightness' {
        Set-PixooBrightness -Brightness 75
        $config = Get-PixooConfiguration
        $config.Brightness | Should -Be 75
    }
}
```

### Running Tests

```powershell
# Unit tests only
Invoke-Pester -Path .\tests\Unit\

# Integration tests (requires device)
$env:PIXOO_TEST_IP = "192.168.0.73"
Invoke-Pester -Path .\tests\Integration\

# All tests with coverage
Invoke-Pester -Path .\tests\ -CodeCoverage .\src\**\*.ps1
```

## Pull Request Process

### Before Submitting

1. **Run PSScriptAnalyzer** - Zero errors required
   ```powershell
   Invoke-ScriptAnalyzer -Path .\src\Pixoo64 -Recurse
   ```

2. **Run all unit tests** - All must pass
   ```powershell
   Invoke-Pester -Path .\tests\Unit\
   ```

3. **Update documentation** if adding/changing features
4. **Add examples** if adding new functions
5. **Update CHANGELOG.md** with your changes

### PR Checklist

- [ ] Code follows PowerShell best practices
- [ ] All functions have comment-based help
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated (if applicable)
- [ ] PSScriptAnalyzer shows zero errors
- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated

### Submitting

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Commit your changes: `git commit -am 'Add some feature'`
3. Push to branch: `git push origin feature/my-feature`
4. Open a Pull Request on GitHub
5. Wait for review and address feedback

## Reporting Bugs

### Before Reporting

1. Check [existing issues](https://github.com/yourusername/Pixoo/issues)
2. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Test with latest version

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Import module
2. Run command: `Set-PixooBrightness -Brightness 50`
3. See error

**Expected behavior**
What you expected to happen.

**Actual behavior**
What actually happened (include error messages).

**Environment:**
- PowerShell version: [e.g., 7.4.0]
- Module version: [e.g., 0.1.0]
- OS: [e.g., Windows 11, Ubuntu 22.04]
- Pixoo64 firmware: [if known]

**Additional context**
Any other relevant information.
```

## Suggesting Enhancements

### Enhancement Request Template

```markdown
**Feature description**
Clear description of the proposed feature.

**Use case**
Why is this feature needed? What problem does it solve?

**Proposed solution**
How should this feature work?

**Alternatives considered**
Other approaches you've thought about.

**Additional context**
Any other relevant information, examples, or mockups.
```

## Questions?

- Open a [GitHub Discussion](https://github.com/yourusername/Pixoo/discussions)
- File an [issue](https://github.com/yourusername/Pixoo/issues)

Thank you for contributing! 🎉
