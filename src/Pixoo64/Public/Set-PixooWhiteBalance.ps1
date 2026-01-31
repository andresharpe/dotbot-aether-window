function Set-PixooWhiteBalance {
    <#
    .SYNOPSIS
        Sets the white balance on the Pixoo64 display.

    .DESCRIPTION
        Adjusts the RGB white balance values to calibrate display colors.

    .PARAMETER Red
        Red channel value (0-100).

    .PARAMETER Green
        Green channel value (0-100).

    .PARAMETER Blue
        Blue channel value (0-100).

    .EXAMPLE
        Set-PixooWhiteBalance -Red 100 -Green 100 -Blue 100
        Sets neutral white balance.

    .EXAMPLE
        Set-PixooWhiteBalance -Red 100 -Green 90 -Blue 80
        Sets a warmer white balance.

    .EXAMPLE
        Set-PixooWhiteBalance -Red 80 -Green 90 -Blue 100
        Sets a cooler white balance.

    .NOTES
        API Endpoint: Device/SetWhiteBalance
        Values are typically 0-100 (may vary by firmware).
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 100)]
        [int]$Red,

        [Parameter(Mandatory)]
        [ValidateRange(0, 100)]
        [int]$Green,

        [Parameter(Mandatory)]
        [ValidateRange(0, 100)]
        [int]$Blue
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set white balance to R:$Red G:$Green B:$Blue"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting white balance: R=$Red, G=$Green, B=$Blue"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/SetWhiteBalance'
                    RValue = $Red
                    GValue = $Green
                    BValue = $Blue
                }

                Write-Verbose "White balance set successfully"
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
