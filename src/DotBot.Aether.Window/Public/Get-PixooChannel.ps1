function Get-PixooChannel {
    <#
    .SYNOPSIS
        Gets the current channel of the Pixoo64 display.

    .DESCRIPTION
        Retrieves the currently selected channel index.
        Channels: 0 = Faces, 1 = Cloud, 2 = Visualizer, 3 = Custom

    .EXAMPLE
        Get-PixooChannel

    .OUTPUTS
        PSCustomObject - Channel information with SelectIndex property.

    .NOTES
        API Endpoint: Channel/GetIndex
        Channel values:
        - 0 = Faces (Clock faces)
        - 1 = Cloud (Cloud channel)
        - 2 = Visualizer (Audio visualizer)
        - 3 = Custom (Custom images/animations)
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        try {
            Write-Verbose "Retrieving current channel"

            $response = Invoke-PixooCommand -Command @{
                Command = 'Channel/GetIndex'
            }

            return $response
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
