function Set-PixooChannel {
    <#
    .SYNOPSIS
        Sets the current channel of the Pixoo64 display.

    .DESCRIPTION
        Switches to a different display channel.
        Channels: 0 = Faces, 1 = Cloud, 2 = Visualizer, 3 = Custom

    .PARAMETER Channel
        Channel to switch to (0-3 or name).
        Valid values: 0/Faces, 1/Cloud, 2/Visualizer, 3/Custom

    .EXAMPLE
        Set-PixooChannel -Channel 0

    .EXAMPLE
        Set-PixooChannel -Channel Faces

    .EXAMPLE
        Set-PixooChannel -Channel Custom

    .NOTES
        API Endpoint: Channel/SetIndex
        Channel values:
        - 0 = Faces (Clock faces)
        - 1 = Cloud (Cloud channel)
        - 2 = Visualizer (Audio visualizer)
        - 3 = Custom (Custom images/animations)
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet(0, 1, 2, 3, 'Faces', 'Cloud', 'Visualizer', 'Custom')]
        [object]$Channel
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert channel name to index
        $channelIndex = switch ($Channel) {
            'Faces' { 0 }
            'Cloud' { 1 }
            'Visualizer' { 2 }
            'Custom' { 3 }
            default { [int]$Channel }
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set channel to $Channel"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting channel to $channelIndex"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Channel/SetIndex'
                    SelectIndex = $channelIndex
                }

                Write-Verbose "Channel set successfully"
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
