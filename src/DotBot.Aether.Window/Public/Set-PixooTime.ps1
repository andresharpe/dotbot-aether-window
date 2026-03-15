function Set-PixooTime {
    <#
    .SYNOPSIS
        Sets the system time on the Pixoo64 device.

    .DESCRIPTION
        Synchronizes the device clock using a Unix epoch timestamp (UTC).
        Can accept either a raw Unix timestamp or a DateTime object.

    .PARAMETER Utc
        Unix epoch timestamp in seconds (UTC).

    .PARAMETER DateTime
        A DateTime object to set. Will be converted to UTC epoch seconds.

    .EXAMPLE
        Set-PixooTime -DateTime (Get-Date)
        Sets the device time to the current local time.

    .EXAMPLE
        Set-PixooTime -Utc 1672531200
        Sets the device time using a Unix timestamp.

    .EXAMPLE
        Get-Date | Set-PixooTime
        Sets the device time via pipeline.

    .NOTES
        API Endpoint: Device/SetUTC
        The device uses this time for clock faces and time-based features.
    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'DateTime')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Utc', ValueFromPipelineByPropertyName)]
        [ValidateRange(0, [long]::MaxValue)]
        [long]$Utc,

        [Parameter(Mandatory, ParameterSetName = 'DateTime', ValueFromPipeline)]
        [DateTime]$DateTime
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert DateTime to Unix epoch if needed
        if ($PSCmdlet.ParameterSetName -eq 'DateTime') {
            $epoch = [DateTime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
            $Utc = [long]($DateTime.ToUniversalTime() - $epoch).TotalSeconds
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set device time to UTC $Utc"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting device time to UTC: $Utc"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/SetUTC'
                    Utc = $Utc
                }

                Write-Verbose "Device time set successfully"
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
