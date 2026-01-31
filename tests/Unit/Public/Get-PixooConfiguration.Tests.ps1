#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\src\Pixoo64\Pixoo64.psd1'
    Import-Module $ModulePath -Force

    # Import test helpers
    $TestHelpersPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\TestHelpers.psm1'
    Import-Module $TestHelpersPath -Force
}

Describe 'Get-PixooConfiguration' {
    BeforeEach {
        InModuleScope Pixoo64 {
            $script:PixooSession = @{
                Uri = 'http://192.168.0.73:80/post'
                IPAddress = '192.168.0.73'
                Connected = $true
                LastContact = [DateTime]::Now
            }
        }
    }

    AfterEach {
        InModuleScope Pixoo64 {
            $script:PixooSession = $null
        }
    }

    Context 'Session Validation' {
        It 'Throws error when not connected' {
            InModuleScope Pixoo64 {
                $script:PixooSession = $null

                { Get-PixooConfiguration } |
                    Should -Throw -ExpectedMessage '*Not connected*'
            }
        }
    }

    Context 'Successful Retrieval' {
        It 'Returns configuration object' {
            InModuleScope Pixoo64 {
                Mock Invoke-PixooCommand {
                    return [PSCustomObject]@{
                        error_code = 0
                        Brightness = 75
                        LightSwitch = 1
                        CurClockId = 182
                        DeviceName = 'Test Pixoo'
                    }
                }

                $result = Get-PixooConfiguration

                $result | Should -Not -BeNullOrEmpty
                $result.Brightness | Should -Be 75
                $result.DeviceName | Should -Be 'Test Pixoo'
            }
        }

        It 'Calls correct API endpoint' {
            InModuleScope Pixoo64 {
                Mock Invoke-PixooCommand {
                    param($Command)
                    $Command.Command | Should -Be 'Channel/GetAllConf'
                    return [PSCustomObject]@{ error_code = 0 }
                }

                Get-PixooConfiguration

                Should -Invoke Invoke-PixooCommand -Times 1
            }
        }
    }

    Context 'Refresh Parameter' {
        It 'Accepts Refresh switch' {
            InModuleScope Pixoo64 {
                Mock Invoke-PixooCommand {
                    return [PSCustomObject]@{ error_code = 0 }
                }

                { Get-PixooConfiguration -Refresh } | Should -Not -Throw
            }
        }
    }
}
