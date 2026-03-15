function Start-PixooStopwatch {
    <#
    .SYNOPSIS
        Controls the stopwatch on the Pixoo64.

    .DESCRIPTION
        Starts, stops, or resets the stopwatch display.

    .PARAMETER Action
        Stopwatch action: Start, Stop, or Reset.

    .EXAMPLE
        Start-PixooStopwatch -Action Start

    .EXAMPLE
        Start-PixooStopwatch -Action Stop

    .EXAMPLE
        Start-PixooStopwatch -Action Reset

    .NOTES
        API Endpoint: Tools/SetStopWatch
        Action values:
        - Start: Begin counting (Status = 0)
        - Stop: Pause counting (Status = 1)
        - Reset: Reset to zero (Status = 2)
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet('Start', 'Stop', 'Reset')]
        [string]$Action
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert action to API status value
        $statusValue = switch ($Action) {
            'Start' { 0 }
            'Stop' { 1 }
            'Reset' { 2 }
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $actionText = "$Action stopwatch"

        if ($PSCmdlet.ShouldProcess($target, $actionText)) {
            try {
                Write-Verbose "Stopwatch action: $Action"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Tools/SetStopWatch'
                    Status = $statusValue
                }

                Write-Verbose "Stopwatch $Action completed successfully"
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
