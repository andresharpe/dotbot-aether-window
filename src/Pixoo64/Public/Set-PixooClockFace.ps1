function Set-PixooClockFace {
    <#
    .SYNOPSIS
        Sets the clock face on the Pixoo64 display.

    .DESCRIPTION
        Selects a specific clock face by ID. The device must be on the Faces channel (0).

    .PARAMETER ClockId
        Clock face ID to display.

    .EXAMPLE
        Set-PixooClockFace -ClockId 182

    .NOTES
        API Endpoint: Channel/SetClockSelectId
        Device must be on Faces channel (0) for this to take effect.
        Use Set-PixooChannel -Channel Faces first if needed.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateRange(0, 10000)]
        [int]$ClockId
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set clock face to ID $ClockId"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting clock face to ID $ClockId"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Channel/SetClockSelectId'
                    ClockId = $ClockId
                }

                Write-Verbose "Clock face set successfully"
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
