function Set-PixooNoiseMeter {
    <#
    .SYNOPSIS
        Enables or disables the noise meter on the Pixoo64.

    .DESCRIPTION
        Starts or stops the audio level visualization (noise meter).

    .PARAMETER Enabled
        Enable ($true) or disable ($false) the noise meter.

    .PARAMETER Status
        Alternative parameter: Start or Stop.

    .EXAMPLE
        Set-PixooNoiseMeter -Enabled $true

    .EXAMPLE
        Set-PixooNoiseMeter -Status Start

    .EXAMPLE
        Set-PixooNoiseMeter -Enabled $false

    .NOTES
        API Endpoint: Tools/SetNoiseStatus
        Status values:
        - 1 = Start (enable)
        - 0 = Stop (disable)
    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Enabled')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Enabled', ValueFromPipeline)]
        [bool]$Enabled,

        [Parameter(Mandatory, ParameterSetName = 'Status')]
        [ValidateSet('Start', 'Stop')]
        [string]$Status
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert to API status value
        $statusValue = if ($PSCmdlet.ParameterSetName -eq 'Enabled') {
            if ($Enabled) { 1 } else { 0 }
        }
        else {
            if ($Status -eq 'Start') { 1 } else { 0 }
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = if ($statusValue -eq 1) { "Start noise meter" } else { "Stop noise meter" }

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting noise meter status to $statusValue"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Tools/SetNoiseStatus'
                    NoiseStatus = $statusValue
                }

                Write-Verbose "Noise meter status set successfully"
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
