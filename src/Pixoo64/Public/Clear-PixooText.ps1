function Clear-PixooText {
    <#
    .SYNOPSIS
        Clears text overlays from the Pixoo64 display.

    .DESCRIPTION
        Removes all text overlays sent via Send-PixooText.

    .EXAMPLE
        Clear-PixooText

    .NOTES
        API Endpoint: Draw/ClearHttpText
        This removes text overlays but does not affect images or other display content.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Clear text overlays"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Clearing text overlays"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Draw/ClearHttpText'
                }

                Write-Verbose "Text cleared successfully"
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
