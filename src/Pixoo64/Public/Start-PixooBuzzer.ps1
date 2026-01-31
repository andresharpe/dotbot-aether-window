function Start-PixooBuzzer {
    <#
    .SYNOPSIS
        Activates the buzzer on the Pixoo64.

    .DESCRIPTION
        Plays a buzzer pattern with customizable timing.
        Can use preset patterns or custom timing.

    .PARAMETER ActiveTime
        Time buzzer is on in milliseconds (custom pattern).

    .PARAMETER OffTime
        Time buzzer is off in milliseconds (custom pattern).

    .PARAMETER TotalTime
        Total duration in milliseconds (custom pattern).

    .PARAMETER Preset
        Preset buzzer pattern: Short, Long, or Alert.

    .EXAMPLE
        Start-PixooBuzzer -Preset Short

    .EXAMPLE
        Start-PixooBuzzer -Preset Alert

    .EXAMPLE
        Start-PixooBuzzer -ActiveTime 500 -OffTime 500 -TotalTime 3000

    .NOTES
        API Endpoint: Device/PlayBuzzer
        Presets:
        - Short: 100ms on, 100ms off, 500ms total
        - Long: 500ms on, 500ms off, 2000ms total
        - Alert: 200ms on, 200ms off, 3000ms total
    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Preset')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Custom')]
        [ValidateRange(10, 5000)]
        [int]$ActiveTime,

        [Parameter(Mandatory, ParameterSetName = 'Custom')]
        [ValidateRange(10, 5000)]
        [int]$OffTime,

        [Parameter(Mandatory, ParameterSetName = 'Custom')]
        [ValidateRange(100, 10000)]
        [int]$TotalTime,

        [Parameter(Mandatory, ParameterSetName = 'Preset')]
        [ValidateSet('Short', 'Long', 'Alert')]
        [string]$Preset
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Apply preset values if using preset
        if ($PSCmdlet.ParameterSetName -eq 'Preset') {
            switch ($Preset) {
                'Short' {
                    $ActiveTime = 100
                    $OffTime = 100
                    $TotalTime = 500
                }
                'Long' {
                    $ActiveTime = 500
                    $OffTime = 500
                    $TotalTime = 2000
                }
                'Alert' {
                    $ActiveTime = 200
                    $OffTime = 200
                    $TotalTime = 3000
                }
            }
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = if ($PSCmdlet.ParameterSetName -eq 'Preset') {
            "Play buzzer preset '$Preset'"
        }
        else {
            "Play buzzer (Active: ${ActiveTime}ms, Off: ${OffTime}ms, Total: ${TotalTime}ms)"
        }

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Starting buzzer: Active=${ActiveTime}ms, Off=${OffTime}ms, Total=${TotalTime}ms"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/PlayBuzzer'
                    ActiveTimeInCycle = $ActiveTime
                    OffTimeInCycle = $OffTime
                    PlayTotalTime = $TotalTime
                }

                Write-Verbose "Buzzer activated successfully"
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
