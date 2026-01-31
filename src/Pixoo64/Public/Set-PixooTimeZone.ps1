function Set-PixooTimeZone {
    <#
    .SYNOPSIS
        Sets the time zone on the Pixoo64 device.

    .DESCRIPTION
        Configures the device's time zone for clock displays and time-based features.

    .PARAMETER TimeZone
        Time zone string (e.g., "GMT-5", "GMT+8", "UTC").

    .EXAMPLE
        Set-PixooTimeZone -TimeZone "GMT-5"
        Sets the device to Eastern Standard Time.

    .EXAMPLE
        Set-PixooTimeZone -TimeZone "UTC"
        Sets the device to UTC.

    .EXAMPLE
        Set-PixooTimeZone -TimeZone "GMT+1"
        Sets the device to Central European Time.

    .NOTES
        API Endpoint: Sys/TimeZone
        Format: "GMT+/-N" or "UTC"
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$TimeZone
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set time zone to $TimeZone"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting time zone to: $TimeZone"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Sys/TimeZone'
                    TimeZoneValue = $TimeZone
                }

                Write-Verbose "Time zone set successfully"
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
