#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\src\Pixoo64\Pixoo64.psd1'
    Import-Module $ModulePath -Force

    # Import test helpers
    $TestHelpersPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\TestHelpers.psm1'
    Import-Module $TestHelpersPath -Force
}

Describe 'Invoke-PixooCommand' {
    BeforeEach {
        # Setup mock session
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

                { Invoke-PixooCommand -Command @{ Command = 'Test' } } |
                    Should -Throw -ExpectedMessage '*Not connected*'
            }
        }
    }

    Context 'Successful API Calls' {
        It 'Sends command and returns response' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ error_code = 0; data = 'test' }
                }

                $result = Invoke-PixooCommand -Command @{ Command = 'Channel/GetAllConf' }

                $result.error_code | Should -Be 0
                $result.data | Should -Be 'test'
            }
        }

        It 'Updates LastContact timestamp' {
            InModuleScope Pixoo64 {
                $beforeTime = $script:PixooSession.LastContact

                Mock Invoke-RestMethod {
                    Start-Sleep -Milliseconds 10
                    return [PSCustomObject]@{ error_code = 0 }
                }

                Invoke-PixooCommand -Command @{ Command = 'Test' }

                $script:PixooSession.LastContact | Should -BeGreaterThan $beforeTime
            }
        }
    }

    Context 'API Error Handling' {
        It 'Handles non-zero error_code from API' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ error_code = 1 }
                }

                Mock Write-PixooError { }

                $result = Invoke-PixooCommand -Command @{ Command = 'Test' }

                Should -Invoke Write-PixooError -Times 1
            }
        }
    }

    Context 'Retry Logic' {
        It 'Retries on timeout errors' {
            InModuleScope Pixoo64 {
                $script:callCount = 0

                Mock Invoke-RestMethod {
                    $script:callCount++
                    if ($script:callCount -lt 2) {
                        throw [System.Net.WebException]::new('Timeout')
                    }
                    return [PSCustomObject]@{ error_code = 0 }
                }

                $result = Invoke-PixooCommand -Command @{ Command = 'Test' } -MaxRetries 3

                $script:callCount | Should -Be 2
            }
        }

        It 'Does not retry on 4xx errors' {
            InModuleScope Pixoo64 {
                $script:callCount = 0

                Mock Invoke-RestMethod {
                    $script:callCount++
                    $response = [System.Net.HttpWebResponse]::new()
                    $exception = [System.Net.WebException]::new('Bad Request', $null, [System.Net.WebExceptionStatus]::ProtocolError, $response)

                    # Mock 400 status code
                    Add-Member -InputObject $exception -Name 'Response' -Value ([PSCustomObject]@{ StatusCode = 400 }) -MemberType NoteProperty -Force

                    throw $exception
                }

                { Invoke-PixooCommand -Command @{ Command = 'Test' } -MaxRetries 3 } |
                    Should -Throw

                $script:callCount | Should -Be 1
            }
        }

        It 'Uses exponential backoff between retries' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    throw [System.Net.WebException]::new('Timeout')
                }

                Mock Start-Sleep { }

                { Invoke-PixooCommand -Command @{ Command = 'Test' } -MaxRetries 3 } |
                    Should -Throw

                # Should call Start-Sleep for backoff
                Should -Invoke Start-Sleep -Times 2 -ParameterFilter { $Seconds -in @(1, 2) }
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Accepts valid command hashtable' {
            InModuleScope Pixoo64 {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ error_code = 0 }
                }

                { Invoke-PixooCommand -Command @{ Command = 'Test'; Data = 'Value' } } |
                    Should -Not -Throw
            }
        }

        It 'Validates MaxRetries range' {
            InModuleScope Pixoo64 {
                { Invoke-PixooCommand -Command @{ Command = 'Test' } -MaxRetries 0 } |
                    Should -Throw
            }
        }
    }
}
