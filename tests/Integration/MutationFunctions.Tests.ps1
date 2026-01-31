#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\Pixoo64\Pixoo64.psd1'
    Import-Module $ModulePath -Force

    $script:TestDeviceIP = $env:PIXOO_TEST_IP

    if (-not $script:TestDeviceIP) {
        Write-Warning "Integration tests skipped: No device configured (set PIXOO_TEST_IP or use run-integration-tests.ps1)"
    }
}

Describe 'Pixoo Mutation Functions Integration Tests' -Tag 'Integration' {
    BeforeAll {
        if ($env:PIXOO_TEST_IP) {
            $null = Connect-Pixoo -IPAddress $env:PIXOO_TEST_IP
        }
    }

    AfterAll {
        if ($env:PIXOO_TEST_IP) {
            # Reset to reasonable state
            Set-PixooBrightness -Brightness 50 -ErrorAction SilentlyContinue
            Set-PixooRotation -Angle 0 -ErrorAction SilentlyContinue
            Set-PixooChannel -Channel 0 -ErrorAction SilentlyContinue
            Clear-PixooText -ErrorAction SilentlyContinue
            Disconnect-Pixoo -ErrorAction SilentlyContinue
        }
    }

    Context 'Display Settings' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Set-PixooBrightness sets brightness' {
            { Set-PixooBrightness -Brightness 50 } | Should -Not -Throw
        }

        It 'Set-PixooBrightness accepts pipeline input' {
            { 75 | Set-PixooBrightness } | Should -Not -Throw
        }

        It 'Set-PixooBrightness -PassThru returns value' {
            $result = Set-PixooBrightness -Brightness 60 -PassThru
            $result | Should -Be 60
        }

        It 'Get-PixooChannel retrieves current channel' {
            $result = Get-PixooChannel
            $result | Should -Not -BeNullOrEmpty
            $result.error_code | Should -Be 0
        }

        It 'Set-PixooChannel switches to Faces channel' {
            { Set-PixooChannel -Channel Faces } | Should -Not -Throw
        }

        It 'Set-PixooChannel switches by index' {
            { Set-PixooChannel -Channel 0 } | Should -Not -Throw
        }

        It 'Set-PixooScreenState turns screen on' {
            { Set-PixooScreenState -State On } | Should -Not -Throw
        }

        It 'Set-PixooClockFace sets clock face' {
            { Set-PixooClockFace -ClockId 182 } | Should -Not -Throw
        }

        It 'Get-PixooClockInfo retrieves clock information' {
            $result = Get-PixooClockInfo
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Drawing & Display' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Reset-PixooDisplay resets frame buffer' {
            { Reset-PixooDisplay } | Should -Not -Throw
        }

        It 'Send-PixooText displays text' {
            { Send-PixooText -Text "Test" -Color "#00FF00" } | Should -Not -Throw
        }

        It 'Send-PixooText accepts pipeline input' {
            { "Pipeline Test" | Send-PixooText } | Should -Not -Throw
        }

        It 'Send-PixooText with custom parameters' {
            { Send-PixooText -Text "Custom" -Color "#FF0000" -Y 32 -Speed 30 -Font 4 } | Should -Not -Throw
        }

        It 'Clear-PixooText clears text overlay' {
            { Clear-PixooText } | Should -Not -Throw
        }

        It 'Set-PixooSolidColor with RGB values' {
            { Set-PixooSolidColor -Red 255 -Green 0 -Blue 0 } | Should -Not -Throw
        }

        It 'Set-PixooSolidColor with hex color' {
            { Set-PixooSolidColor -HexColor "#00FF00" } | Should -Not -Throw
        }

        It 'Get-PixooGifId retrieves current GIF ID' {
            $result = Get-PixooGifId
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Device Settings' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Set-PixooRotation sets 0 degrees' {
            { Set-PixooRotation -Angle 0 } | Should -Not -Throw
        }

        It 'Set-PixooRotation sets 90 degrees' {
            { Set-PixooRotation -Angle 90 } | Should -Not -Throw
            # Reset immediately
            Set-PixooRotation -Angle 0
        }

        It 'Set-PixooMirrorMode enables mirror' {
            { Set-PixooMirrorMode -Enabled $true } | Should -Not -Throw
            # Reset immediately
            Set-PixooMirrorMode -Enabled $false
        }

        It 'Set-PixooMirrorMode disables mirror' {
            { Set-PixooMirrorMode -Enabled $false } | Should -Not -Throw
        }

        It 'Set-PixooTimeFormat sets 24-hour format' {
            { Set-PixooTimeFormat -Format 24 } | Should -Not -Throw
        }

        It 'Set-PixooTimeFormat sets 12-hour format' {
            { Set-PixooTimeFormat -Format 12 } | Should -Not -Throw
        }

        It 'Set-PixooTemperatureUnit sets Celsius' {
            { Set-PixooTemperatureUnit -Unit Celsius } | Should -Not -Throw
        }

        It 'Set-PixooTemperatureUnit sets Fahrenheit' {
            { Set-PixooTemperatureUnit -Unit Fahrenheit } | Should -Not -Throw
        }

        It 'Set-PixooHighLightMode can be toggled' {
            { Set-PixooHighLightMode -Enabled $false } | Should -Not -Throw
        }

        It 'Set-PixooCustomPageIndex sets page index' {
            { Set-PixooCustomPageIndex -PageIndex 0 } | Should -Not -Throw
        }
    }

    Context 'Tools' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Start-PixooTimer starts timer with minutes' {
            { Start-PixooTimer -Minutes 1 } | Should -Not -Throw
        }

        It 'Start-PixooTimer starts timer with total seconds' {
            { Start-PixooTimer -TotalSeconds 30 } | Should -Not -Throw
        }

        It 'Start-PixooStopwatch starts stopwatch' {
            { Start-PixooStopwatch -Action Start } | Should -Not -Throw
        }

        It 'Start-PixooStopwatch stops stopwatch' {
            { Start-PixooStopwatch -Action Stop } | Should -Not -Throw
        }

        It 'Start-PixooStopwatch resets stopwatch' {
            { Start-PixooStopwatch -Action Reset } | Should -Not -Throw
        }

        It 'Set-PixooScoreboard sets scores' {
            { Set-PixooScoreboard -RedScore 5 -BlueScore 3 } | Should -Not -Throw
        }

        It 'Set-PixooScoreboard resets scores to zero' {
            { Set-PixooScoreboard -RedScore 0 -BlueScore 0 } | Should -Not -Throw
        }

        It 'Start-PixooBuzzer activates buzzer briefly' {
            # Short duration to not be annoying
            { Start-PixooBuzzer -ActiveTime 100 -OffTime 100 -TotalTime 200 } | Should -Not -Throw
        }

        It 'Set-PixooNoiseMeter activates noise meter' {
            { Set-PixooNoiseMeter -Enabled $true } | Should -Not -Throw
        }

        It 'Set-PixooNoiseMeter deactivates noise meter' {
            { Set-PixooNoiseMeter -Enabled $false } | Should -Not -Throw
        }
    }

    Context 'Batch Commands' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Invoke-PixooCommandBatch sends multiple commands' {
            $commands = @(
                @{ Command = 'Channel/SetBrightness'; Brightness = 50 }
                @{ Command = 'Draw/ResetHttpGifId' }
            )
            { Invoke-PixooCommandBatch -Commands $commands } | Should -Not -Throw
        }
    }

    Context 'WhatIf Support' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Set-PixooBrightness supports -WhatIf' {
            $originalConfig = Get-PixooConfiguration
            Set-PixooBrightness -Brightness 10 -WhatIf
            $newConfig = Get-PixooConfiguration
            # Brightness should be unchanged
            $newConfig.Brightness | Should -Be $originalConfig.Brightness
        }

        It 'Send-PixooText supports -WhatIf' {
            { Send-PixooText -Text "WhatIf Test" -WhatIf } | Should -Not -Throw
        }

        It 'Set-PixooChannel supports -WhatIf' {
            { Set-PixooChannel -Channel 3 -WhatIf } | Should -Not -Throw
        }
    }

    Context 'Error Handling' -Skip:(-not $env:PIXOO_TEST_IP) {
        It 'Functions throw when not connected' {
            Disconnect-Pixoo
            { Set-PixooBrightness -Brightness 50 } | Should -Throw
            # Reconnect for remaining tests
            $null = Connect-Pixoo -IPAddress $env:PIXOO_TEST_IP
        }
    }
}
