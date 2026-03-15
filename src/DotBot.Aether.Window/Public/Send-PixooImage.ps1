function Send-PixooImage {
    <#
    .SYNOPSIS
        Sends a static image to the Pixoo64 display.

    .DESCRIPTION
        Displays a 64x64 RGB image on the Pixoo64. Image data can be provided as
        a byte array or Base64 string. Automatically resets the frame buffer unless disabled.

    .PARAMETER ImageData
        Raw RGB byte array (12,288 bytes for 64x64x3).

    .PARAMETER Base64Data
        Base64-encoded RGB image data.

    .PARAMETER AutoReset
        Automatically call Reset-PixooDisplay before sending image.
        Default is $true. Disable only if you've already called Reset-PixooDisplay.

    .PARAMETER PicID
        Picture ID for tracking (1-999). Default is 1.

    .EXAMPLE
        Send-PixooImage -Base64Data $imageBase64

    .EXAMPLE
        $rgbData = [byte[]]::new(12288)
        Send-PixooImage -ImageData $rgbData

    .NOTES
        API Endpoint: Draw/SendHttpGif
        Image format: 64x64 pixels, RGB (3 bytes per pixel), total 12,288 bytes
        Calls Reset-PixooDisplay first (unless disabled) to avoid buffer issues.
    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Base64')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ByteArray', ValueFromPipeline)]
        [ValidateCount(12288, 12288)]
        [byte[]]$ImageData,

        [Parameter(Mandatory, ParameterSetName = 'Base64', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Base64Data,

        [Parameter()]
        [bool]$AutoReset = $true,

        [Parameter()]
        [ValidateRange(1, 999)]
        [int]$PicID = 1
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert byte array to Base64 if needed
        if ($PSCmdlet.ParameterSetName -eq 'ByteArray') {
            Write-Verbose "Converting byte array to Base64"
            $Base64Data = [Convert]::ToBase64String($ImageData)
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Send image (PicID: $PicID)"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                # Reset buffer if enabled
                if ($AutoReset) {
                    Write-Verbose "Auto-resetting frame buffer"
                    Reset-PixooDisplay
                }

                # Send image
                Write-Verbose "Sending image to display (PicID: $PicID)"
                $response = Invoke-PixooCommand -Command @{
                    Command = 'Draw/SendHttpGif'
                    PicNum = 1
                    PicWidth = 64
                    PicOffset = 0
                    PicID = $PicID
                    PicSpeed = 1000
                    PicData = $Base64Data
                }

                Write-Verbose "Image sent successfully"
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
