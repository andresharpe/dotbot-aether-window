function Set-PixooRotation {
    <#
    .SYNOPSIS
        Sets the screen rotation angle on the Pixoo64.

    .DESCRIPTION
        Rotates the display orientation.

    .PARAMETER Angle
        Rotation angle: 0, 90, 180, or 270 degrees.

    .EXAMPLE
        Set-PixooRotation -Angle 0

    .EXAMPLE
        Set-PixooRotation -Angle 90

    .NOTES
        API Endpoint: Device/SetScreenRotationAngle
        Valid angles: 0, 90, 180, 270
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet(0, 90, 180, 270)]
        [int]$Angle
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set rotation to $Angle degrees"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting rotation angle to $Angle degrees"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/SetScreenRotationAngle'
                    Mode = $Angle
                }

                Write-Verbose "Rotation set successfully"
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
