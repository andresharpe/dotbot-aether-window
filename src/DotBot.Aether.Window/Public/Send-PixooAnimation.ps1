function Send-PixooAnimation {
    <#
    .SYNOPSIS
        Sends a multi-frame animation to the Pixoo64 display.

    .DESCRIPTION
        Displays an animated sequence of 64x64 RGB images. Each frame is sent separately
        with an offset. Maximum ~40 frames (varies by firmware version).

    .PARAMETER Frames
        Array of Base64-encoded frame data or byte arrays.

    .PARAMETER FrameDelay
        Delay between frames in milliseconds. Default is 100ms.

    .PARAMETER AutoReset
        Automatically call Reset-PixooDisplay before sending animation.
        Default is $true.

    .PARAMETER PicID
        Picture ID for tracking (1-999). Default is 1.

    .EXAMPLE
        $frames = @($frame1Base64, $frame2Base64, $frame3Base64)
        Send-PixooAnimation -Frames $frames -FrameDelay 200

    .NOTES
        API Endpoint: Draw/SendHttpGif (called multiple times)
        WARNING: Device limited to ~40 frames. Exact limit varies by firmware.
        Exceeding this limit may cause the animation to fail or freeze.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Frames,

        [Parameter()]
        [ValidateRange(10, 10000)]
        [int]$FrameDelay = 100,

        [Parameter()]
        [bool]$AutoReset = $true,

        [Parameter()]
        [ValidateRange(1, 999)]
        [int]$PicID = 1
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
        $frameList = [System.Collections.ArrayList]::new()
    }

    process {
        # Collect frames from pipeline
        foreach ($frame in $Frames) {
            [void]$frameList.Add($frame)
        }
    }

    end {
        $frameCount = $frameList.Count

        # Warn if approaching frame limit
        if ($frameCount -gt 35) {
            Write-Warning "Approaching frame limit (~40 frames). Animation with $frameCount frames may fail on some firmware versions."
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Send animation ($frameCount frames, ${FrameDelay}ms delay)"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                # Reset buffer if enabled
                if ($AutoReset) {
                    Write-Verbose "Auto-resetting frame buffer"
                    Reset-PixooDisplay
                }

                # Send each frame
                for ($i = 0; $i -lt $frameCount; $i++) {
                    Write-Verbose "Sending frame $($i + 1) of $frameCount"

                    $response = Invoke-PixooCommand -Command @{
                        Command = 'Draw/SendHttpGif'
                        PicNum = $frameCount
                        PicWidth = 64
                        PicOffset = $i
                        PicID = $PicID
                        PicSpeed = $FrameDelay
                        PicData = $frameList[$i]
                    }
                }

                Write-Verbose "Animation sent successfully ($frameCount frames)"
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }

        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
