#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\Pixoo64\Pixoo64.psd1'
    Import-Module $ModulePath -Force

    # Use environment variable set by runner script (supports discovery)
    $script:TestDeviceIP = $env:PIXOO_TEST_IP

    if (-not $script:TestDeviceIP) {
        Write-Warning "Integration tests skipped: No device configured (set PIXOO_TEST_IP or use run-integration-tests.ps1)"
    }
}

Describe 'Basic Connectivity Integration Tests' -Tag 'Integration' {
    BeforeAll {
        if ($env:PIXOO_TEST_IP) {
            # Disconnect any existing session
            Disconnect-Pixoo -ErrorAction SilentlyContinue
        }
    }

    AfterAll {
        if ($env:PIXOO_TEST_IP) {
            # Clean up
            Disconnect-Pixoo -ErrorAction SilentlyContinue
        }
    }

    Context 'Find-Pixoo Discovery' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Discovers devices via ARP cache' {
            $devices = Find-Pixoo -LocalOnly

            $devices | Should -Not -BeNullOrEmpty
        }

        It 'Returns device objects with required properties' {
            $devices = Find-Pixoo -LocalOnly

            $devices[0].PSObject.Properties.Name | Should -Contain 'IP'
            $devices[0].PSObject.Properties.Name | Should -Contain 'Name'
            $devices[0].PSObject.Properties.Name | Should -Contain 'DeviceId'
        }
    }

    Context 'Connection Management' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Connects to device successfully' {
            $result = Connect-Pixoo -IPAddress $env:PIXOO_TEST_IP

            $result | Should -Be $true
        }

        It 'Test-PixooConnection returns true when connected' {
            Connect-Pixoo -IPAddress $env:PIXOO_TEST_IP

            $result = Test-PixooConnection -Quiet

            $result | Should -Be $true
        }

        It 'Disconnects successfully' {
            Connect-Pixoo -IPAddress $env:PIXOO_TEST_IP

            { Disconnect-Pixoo } | Should -Not -Throw

            $result = Test-PixooConnection -Quiet

            $result | Should -Be $false
        }
    }

    Context 'Pipeline from Find-Pixoo to Connect-Pixoo' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Connects via pipeline' {
            Disconnect-Pixoo -ErrorAction SilentlyContinue

            $result = Find-Pixoo -LocalOnly | Select-Object -First 1 | Connect-Pixoo

            $result | Should -Be $true
        }
    }

    Context 'Get-PixooConfiguration' -Skip:(-not $env:PIXOO_TEST_IP) {
        BeforeAll {
            $null = Connect-Pixoo -IPAddress $env:PIXOO_TEST_IP
        }

        It 'Retrieves device configuration' {
            $config = Get-PixooConfiguration

            $config | Should -Not -BeNullOrEmpty
            $config.error_code | Should -Be 0
        }

        It 'Returns expected properties' {
            $config = Get-PixooConfiguration

            # Check for actual properties returned by GetAllConf
            $config.PSObject.Properties.Name | Should -Contain 'Brightness'
            $config.PSObject.Properties.Name | Should -Contain 'RotationFlag'
            $config.PSObject.Properties.Name | Should -Contain 'LightSwitch'
        }
    }
}
