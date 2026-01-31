function Set-PixooTemperatureUnit {
    <#
    .SYNOPSIS
        Sets the temperature unit on the Pixoo64.

    .DESCRIPTION
        Switches between Celsius and Fahrenheit temperature display.

    .PARAMETER Unit
        Temperature unit: Celsius or Fahrenheit.

    .EXAMPLE
        Set-PixooTemperatureUnit -Unit Celsius

    .EXAMPLE
        Set-PixooTemperatureUnit -Unit Fahrenheit

    .NOTES
        API Endpoint: Device/SetDisTempMode
        Mode values:
        - 0 = Celsius
        - 1 = Fahrenheit
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet('Celsius', 'Fahrenheit')]
        [string]$Unit
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $modeValue = if ($Unit -eq 'Fahrenheit') { 1 } else { 0 }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set temperature unit to $Unit"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting temperature unit to $Unit"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/SetDisTempMode'
                    Mode = $modeValue
                }

                Write-Verbose "Temperature unit set successfully"
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
