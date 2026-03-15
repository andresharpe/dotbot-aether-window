function Get-PixooGifId {
    <#
    .SYNOPSIS
        Gets the current GIF frame ID from the Pixoo64.

    .DESCRIPTION
        Retrieves the current frame buffer ID. Useful for debugging frame buffer state
        and understanding what's currently displayed.

    .EXAMPLE
        Get-PixooGifId

    .OUTPUTS
        PSCustomObject - Response containing current GIF ID.

    .NOTES
        API Endpoint: Draw/GetHttpGifId
        Helpful for troubleshooting display issues and buffer management.
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
            Write-Verbose "Retrieving current GIF frame ID"

            $response = Invoke-PixooCommand -Command @{
                Command = 'Draw/GetHttpGifId'
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
