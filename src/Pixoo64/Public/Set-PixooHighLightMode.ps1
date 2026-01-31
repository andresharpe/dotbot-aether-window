function Set-PixooHighLightMode {
    <#
    .SYNOPSIS
        Enables or disables high brightness mode on the Pixoo64.

    .DESCRIPTION
        Enables ultra-bright display mode. REQUIRES 5V 3A power supply.
        Using high brightness mode with insufficient power may cause instability.

    .PARAMETER Enabled
        Enable ($true) or disable ($false) high brightness mode.

    .EXAMPLE
        Set-PixooHighLightMode -Enabled $true

    .EXAMPLE
        Set-PixooHighLightMode -Enabled $false

    .NOTES
        API Endpoint: Device/SetHighLightMode
        WARNING: Requires 5V 3A power supply. Using with lower power may cause:
        - Device instability
        - Unexpected resets
        - Reduced lifespan

        Mode values:
        - 1 = High brightness enabled
        - 0 = Normal brightness
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [bool]$Enabled
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $modeValue = if ($Enabled) { 1 } else { 0 }

        if ($Enabled) {
            Write-Warning "High brightness mode requires 5V 3A power supply. Ensure adequate power before enabling."
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = if ($Enabled) { "Enable high brightness mode" } else { "Disable high brightness mode" }

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting high brightness mode to $modeValue"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/SetHighLightMode'
                    Mode = $modeValue
                }

                Write-Verbose "High brightness mode set successfully"
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
