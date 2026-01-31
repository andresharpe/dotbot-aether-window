#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\src\Pixoo64\Pixoo64.psd1'
    Import-Module $ModulePath -Force

    # Import test helpers
    $TestHelpersPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\TestHelpers.psm1'
    Import-Module $TestHelpersPath -Force
}

Describe 'Connect-Pixoo' {
    BeforeEach {
        InModuleScope Pixoo64 {
            $script:PixooSession = $null
        }
    }

    AfterEach {
        InModuleScope Pixoo64 {
            $script:PixooSession = $null
        }
    }

    Context 'Parameter Validation' {
        It 'Requires IPAddress parameter' {
            # Use $null to test mandatory parameter validation without prompting
            { Connect-Pixoo -IPAddress $null } | Should -Throw
        }

        It 'Accepts IPAddress from pipeline' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        error_code = 0
                        DeviceId = 'TEST-123'
                        DeviceName = 'Test Device'
                    }
                }

                $device = [PSCustomObject]@{ IP = '192.168.0.50' }

                $result = $device | Connect-Pixoo

                $result | Should -Be $true
            }
        }

        It 'Accepts IP alias for IPAddress' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        error_code = 0
                        DeviceId = 'TEST-123'
                        DeviceName = 'Test Device'
                    }
                }

                $device = [PSCustomObject]@{ IP = '192.168.0.50' }

                { $device | Connect-Pixoo } | Should -Not -Throw
            }
        }

        It 'Validates Port range' {
            InModuleScope Pixoo64 {
                { Connect-Pixoo -IPAddress '192.168.0.1' -Port 0 } | Should -Throw
                { Connect-Pixoo -IPAddress '192.168.0.1' -Port 70000 } | Should -Throw
            }
        }

        It 'Validates TimeoutSec range' {
            InModuleScope Pixoo64 {
                { Connect-Pixoo -IPAddress '192.168.0.1' -TimeoutSec 0 } | Should -Throw
                { Connect-Pixoo -IPAddress '192.168.0.1' -TimeoutSec 40 } | Should -Throw
            }
        }
    }

    Context 'Successful Connection' {
        It 'Creates session on successful connection' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        error_code = 0
                        DeviceId = 'TEST-123'
                        DeviceName = 'Test Pixoo'
                    }
                }

                $result = Connect-Pixoo -IPAddress '192.168.0.73'

                $result | Should -Be $true
                $script:PixooSession | Should -Not -BeNullOrEmpty
                $script:PixooSession.IPAddress | Should -Be '192.168.0.73'
                $script:PixooSession.Connected | Should -Be $true
            }
        }

        It 'Sets correct URI with custom port' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        error_code = 0
                        DeviceId = 'TEST-123'
                        DeviceName = 'Test Pixoo'
                    }
                }

                Connect-Pixoo -IPAddress '192.168.0.73' -Port 8080

                $script:PixooSession.Uri | Should -Be 'http://192.168.0.73:8080/post'
            }
        }

        It 'Stores device info in session' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        error_code = 0
                        DeviceId = 'TEST-123'
                        DeviceName = 'Test Pixoo'
                    }
                }

                Connect-Pixoo -IPAddress '192.168.0.73'

                $script:PixooSession.DeviceInfo.DeviceId | Should -Be 'TEST-123'
                $script:PixooSession.DeviceInfo.DeviceName | Should -Be 'Test Pixoo'
            }
        }

        It 'Returns true on success' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        error_code = 0
                        DeviceId = 'TEST-123'
                        DeviceName = 'Test Pixoo'
                    }
                }

                $result = Connect-Pixoo -IPAddress '192.168.0.73'

                $result | Should -Be $true
            }
        }
    }

    Context 'Connection Failures' {
        It 'Returns false on network error' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    throw [System.Net.WebException]::new('Connection refused')
                }

                $result = Connect-Pixoo -IPAddress '192.168.0.99' -ErrorAction SilentlyContinue

                $result | Should -Be $false
            }
        }

        It 'Returns false on API error' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        error_code = 1
                    }
                }

                $result = Connect-Pixoo -IPAddress '192.168.0.73' -ErrorAction SilentlyContinue

                $result | Should -Be $false
            }
        }

        It 'Does not create session on failure' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    throw [System.Net.WebException]::new('Connection refused')
                }

                Connect-Pixoo -IPAddress '192.168.0.99' -ErrorAction SilentlyContinue

                $script:PixooSession | Should -BeNullOrEmpty
            }
        }
    }

    Context 'WhatIf Support' {
        It 'Supports -WhatIf' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod { }

                Connect-Pixoo -IPAddress '192.168.0.73' -WhatIf

                Should -Not -Invoke Invoke-RestMethod
                $script:PixooSession | Should -BeNullOrEmpty
            }
        }
    }
}
