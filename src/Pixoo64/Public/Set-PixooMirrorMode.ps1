function Set-PixooMirrorMode {
    <#
    .SYNOPSIS
        Enables or disables mirror mode on the Pixoo64.

    .DESCRIPTION
        Flips the display horizontally (mirror image).

    .PARAMETER Enabled
        Enable ($true) or disable ($false) mirror mode.

    .EXAMPLE
        Set-PixooMirrorMode -Enabled $true

    .EXAMPLE
        Set-PixooMirrorMode -Enabled $false

    .NOTES
        API Endpoint: Device/SetMirrorMode
        Mode values:
        - 1 = Mirror enabled
        - 0 = Mirror disabled
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

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = if ($Enabled) { "Enable mirror mode" } else { "Disable mirror mode" }

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting mirror mode to $modeValue"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/SetMirrorMode'
                    Mode = $modeValue
                }

                Write-Verbose "Mirror mode set successfully"
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
