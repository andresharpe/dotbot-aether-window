function Get-PixooConfiguration {
    <#
    .SYNOPSIS
        Retrieves current configuration from the Pixoo64 device.

    .DESCRIPTION
        Queries the device for all current settings including brightness, channel,
        screen state, clock ID, temperature unit, time format, etc.

    .PARAMETER Refresh
        Forces a fresh query to the device instead of using cached data.

    .EXAMPLE
        Get-PixooConfiguration

    .EXAMPLE
        $config = Get-PixooConfiguration -Refresh
        Write-Host "Current brightness: $($config.Brightness)"

    .OUTPUTS
        PSCustomObject - Device configuration with all settings.

    .NOTES
        API Endpoint: Channel/GetAllConf
        Always queries device (no caching) to ensure current state.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [switch]$Refresh
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        try {
            Write-Verbose "Retrieving device configuration"

            $response = Invoke-PixooCommand -Command @{
                Command = 'Channel/GetAllConf'
            }

            # Return configuration object
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
