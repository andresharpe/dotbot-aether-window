function Set-PixooSolidColor {
    <#
    .SYNOPSIS
        Fills the Pixoo64 display with a solid color.

    .DESCRIPTION
        Displays a solid color across the entire 64x64 display.
        Automatically resets the frame buffer unless -AutoReset is $false.

    .PARAMETER Red
        Red channel value (0-255).

    .PARAMETER Green
        Green channel value (0-255).

    .PARAMETER Blue
        Blue channel value (0-255).

    .PARAMETER HexColor
        Color in hex format (e.g., "#FF0000" for red).
        Alternative to RGB parameters.

    .PARAMETER AutoReset
        Automatically call Reset-PixooDisplay before setting color.
        Default is $true. Disable only if you've already called Reset-PixooDisplay.

    .EXAMPLE
        Set-PixooSolidColor -Red 255 -Green 0 -Blue 0

    .EXAMPLE
        Set-PixooSolidColor -HexColor "#00FF00"

    .EXAMPLE
        Set-PixooSolidColor -Red 128 -Green 128 -Blue 255 -AutoReset:$false

    .NOTES
        API Endpoint: Draw/SendHttpGif
        Calls Reset-PixooDisplay first (unless disabled) to avoid buffer issues.
    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'RGB')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'RGB')]
        [ValidateRange(0, 255)]
        [byte]$Red,

        [Parameter(Mandatory, ParameterSetName = 'RGB')]
        [ValidateRange(0, 255)]
        [byte]$Green,

        [Parameter(Mandatory, ParameterSetName = 'RGB')]
        [ValidateRange(0, 255)]
        [byte]$Blue,

        [Parameter(Mandatory, ParameterSetName = 'Hex')]
        [ValidatePattern('^#[0-9A-Fa-f]{6}$')]
        [string]$HexColor,

        [Parameter()]
        [bool]$AutoReset = $true
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert hex to RGB if needed
        if ($PSCmdlet.ParameterSetName -eq 'Hex') {
            $Red = [Convert]::ToByte($HexColor.Substring(1, 2), 16)
            $Green = [Convert]::ToByte($HexColor.Substring(3, 2), 16)
            $Blue = [Convert]::ToByte($HexColor.Substring(5, 2), 16)
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Fill display with RGB($Red, $Green, $Blue)"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                # Reset buffer if enabled
                if ($AutoReset) {
                    Write-Verbose "Auto-resetting frame buffer"
                    Reset-PixooDisplay
                }

                # Generate solid color data
                Write-Verbose "Generating solid color data: R=$Red, G=$Green, B=$Blue"
                $imageData = New-PixooSolidColorData -Red $Red -Green $Green -Blue $Blue

                # Send image
                Write-Verbose "Sending solid color to display"
                $response = Invoke-PixooCommand -Command @{
                    Command = 'Draw/SendHttpGif'
                    PicNum = 1
                    PicWidth = 64
                    PicOffset = 0
                    PicID = 1
                    PicSpeed = 1000
                    PicData = $imageData
                }

                Write-Verbose "Solid color displayed successfully"
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
