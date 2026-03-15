function Set-PixooBrightness {
    <#
    .SYNOPSIS
        Sets the brightness of the Pixoo64 display.

    .DESCRIPTION
        Adjusts the display brightness to a value between 0 (minimum) and 100 (maximum).

    .PARAMETER Brightness
        Brightness level (0-100).

    .PARAMETER PassThru
        Returns the brightness value after setting.

    .EXAMPLE
        Set-PixooBrightness -Brightness 75

    .EXAMPLE
        Set-PixooBrightness -Brightness 50 -PassThru

    .NOTES
        API Endpoint: Channel/SetBrightness
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateRange(0, 100)]
        [int]$Brightness,

        [Parameter()]
        [switch]$PassThru
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set brightness to $Brightness"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting brightness to $Brightness"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Channel/SetBrightness'
                    Brightness = $Brightness
                }

                Write-Verbose "Brightness set successfully"

                if ($PassThru) {
                    return $Brightness
                }
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
