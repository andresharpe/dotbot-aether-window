function Start-PixooTimer {
    <#
    .SYNOPSIS
        Starts a countdown timer on the Pixoo64.

    .DESCRIPTION
        Displays a countdown timer with specified duration.

    .PARAMETER Minutes
        Timer duration in minutes.

    .PARAMETER Seconds
        Additional seconds to add to duration.

    .PARAMETER TotalSeconds
        Total timer duration in seconds (alternative to Minutes/Seconds).

    .EXAMPLE
        Start-PixooTimer -Minutes 5

    .EXAMPLE
        Start-PixooTimer -Minutes 2 -Seconds 30

    .EXAMPLE
        Start-PixooTimer -TotalSeconds 180

    .NOTES
        API Endpoint: Tools/SetTimer
        Timer displays on device in the Tools channel.
    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'MinutesSeconds')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'MinutesSeconds')]
        [ValidateRange(0, 1440)]
        [int]$Minutes,

        [Parameter(ParameterSetName = 'MinutesSeconds')]
        [ValidateRange(0, 59)]
        [int]$Seconds = 0,

        [Parameter(Mandatory, ParameterSetName = 'TotalSeconds')]
        [ValidateRange(1, 86400)]
        [int]$TotalSeconds
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Calculate total seconds
        if ($PSCmdlet.ParameterSetName -eq 'MinutesSeconds') {
            $TotalSeconds = ($Minutes * 60) + $Seconds
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Start timer for $TotalSeconds seconds"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Starting timer: $TotalSeconds seconds"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Tools/SetTimer'
                    Minute = [Math]::Floor($TotalSeconds / 60)
                    Second = $TotalSeconds % 60
                    Status = 1
                }

                Write-Verbose "Timer started successfully"
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
