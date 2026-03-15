function Set-PixooLocation {
    <#
    .SYNOPSIS
        Sets the geographic location on the Pixoo64 device.

    .DESCRIPTION
        Configures the device's location coordinates for weather display and location-based features.

    .PARAMETER Longitude
        Longitude coordinate (-180 to 180).

    .PARAMETER Latitude
        Latitude coordinate (-90 to 90).

    .EXAMPLE
        Set-PixooLocation -Longitude -122.4194 -Latitude 37.7749
        Sets the location to San Francisco, CA.

    .EXAMPLE
        Set-PixooLocation -Longitude 0 -Latitude 51.5074
        Sets the location to London, UK.

    .NOTES
        API Endpoint: Sys/LogAndLat
        Used for weather display on clock faces.
        The API expects coordinates as string values.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(-180, 180)]
        [double]$Longitude,

        [Parameter(Mandatory)]
        [ValidateRange(-90, 90)]
        [double]$Latitude
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set location to Longitude: $Longitude, Latitude: $Latitude"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting location: Longitude=$Longitude, Latitude=$Latitude"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Sys/LogAndLat'
                    Longitude = $Longitude.ToString()
                    Latitude = $Latitude.ToString()
                }

                Write-Verbose "Location set successfully"
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
