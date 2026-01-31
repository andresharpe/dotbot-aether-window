function Reset-PixooDisplay {
    <#
    .SYNOPSIS
        Resets the Pixoo64 frame buffer.

    .DESCRIPTION
        Clears the internal frame buffer and resets the GIF ID counter.
        CRITICAL: Always call this before sending new images to avoid "stuck" buffer issues.

    .EXAMPLE
        Reset-PixooDisplay

    .EXAMPLE
        Reset-PixooDisplay
        Set-PixooSolidColor -Red 255 -Green 0 -Blue 0

    .NOTES
        API Endpoint: Draw/ResetHttpGifId
        This is a known workaround for the Pixoo64's buffer management issues.
        Without this, new images may not display correctly.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Reset frame buffer"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Resetting frame buffer"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Draw/ResetHttpGifId'
                }

                Write-Verbose "Frame buffer reset successfully"
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
