function Set-PixooTimeFormat {
    <#
    .SYNOPSIS
        Sets the time format on the Pixoo64.

    .DESCRIPTION
        Switches between 12-hour and 24-hour time display.

    .PARAMETER Format
        Time format: 12 or 24.

    .EXAMPLE
        Set-PixooTimeFormat -Format 24

    .EXAMPLE
        Set-PixooTimeFormat -Format 12

    .NOTES
        API Endpoint: Device/SetTime24Flag
        Mode values:
        - 0 = 12-hour format
        - 1 = 24-hour format
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet(12, 24)]
        [int]$Format
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $modeValue = if ($Format -eq 24) { 1 } else { 0 }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set time format to $Format-hour"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting time format to $Format-hour"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/SetTime24Flag'
                    Mode = $modeValue
                }

                Write-Verbose "Time format set successfully"
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
