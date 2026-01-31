function Get-PixooClockInfo {
    <#
    .SYNOPSIS
        Gets information about the current clock face.

    .DESCRIPTION
        Retrieves details about the currently displayed clock face.
        Distinct from Get-PixooConfiguration which returns all device settings.

    .EXAMPLE
        Get-PixooClockInfo

    .OUTPUTS
        PSCustomObject - Clock face information.

    .NOTES
        API Endpoint: Channel/GetClockInfo
        Device should be on Faces channel (0) for meaningful results.
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
            Write-Verbose "Retrieving clock face information"

            $response = Invoke-PixooCommand -Command @{
                Command = 'Channel/GetClockInfo'
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
