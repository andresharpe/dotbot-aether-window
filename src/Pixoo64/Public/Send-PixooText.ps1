function Send-PixooText {
    <#
    .SYNOPSIS
        Displays scrolling text on the Pixoo64.

    .DESCRIPTION
        Sends text to the Pixoo64 display with customizable color, position, speed, and font.

    .PARAMETER Text
        Text to display. Accepts pipeline input.

    .PARAMETER Color
        Text color in hex format (e.g., "#00FF00"). Default is green.

    .PARAMETER Y
        Vertical position (0-63). Default is 24 (center).

    .PARAMETER Speed
        Scroll speed (0-100). Higher = faster. Default is 50.

    .PARAMETER Font
        Font ID (0-7). Default is 2.

    .PARAMETER TextId
        Text layer ID (1-20). Default is 1. Multiple IDs allow multiple text overlays.

    .PARAMETER Direction
        Scroll direction: Left or Right. Default is Left.

    .PARAMETER Align
        Text alignment: Left, Center, or Right. Default is Left.

    .EXAMPLE
        Send-PixooText -Text "Hello World!"

    .EXAMPLE
        Send-PixooText -Text "Temperature: 72°F" -Color "#FF0000" -Speed 30

    .EXAMPLE
        "Line 1", "Line 2" | Send-PixooText -Y 10

    .NOTES
        API Endpoint: Draw/SendHttpText
        IMPORTANT: Text commands only work after an image/animation has been sent to the device.
        Call Set-PixooSolidColor or Send-PixooImage first to initialize the display.
        Most fonts only support left scrolling. Right scrolling is limited.
        Use Clear-PixooText to remove text overlays.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        [Parameter()]
        [ValidatePattern('^#[0-9A-Fa-f]{6}$')]
        [string]$Color = '#00FF00',

        [Parameter()]
        [ValidateRange(0, 63)]
        [int]$Y = 24,

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$Speed = 50,

        [Parameter()]
        [ValidateRange(0, 7)]
        [int]$Font = 2,

        [Parameter()]
        [ValidateRange(1, 20)]
        [int]$TextId = 1,

        [Parameter()]
        [ValidateSet('Left', 'Right')]
        [string]$Direction = 'Left',

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left'
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert direction to API value
        $directionValue = if ($Direction -eq 'Left') { 0 } else { 1 }

        # Convert alignment to API value
        $alignValue = switch ($Align) {
            'Left' { 1 }
            'Center' { 2 }
            'Right' { 3 }
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Display text '$Text'"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Sending text: $Text"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Draw/SendHttpText'
                    TextId = $TextId
                    x = 0
                    y = $Y
                    dir = $directionValue
                    font = $Font
                    TextWidth = 64
                    speed = $Speed
                    TextString = $Text
                    color = $Color
                    align = $alignValue
                }

                Write-Verbose "Text sent successfully"
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
