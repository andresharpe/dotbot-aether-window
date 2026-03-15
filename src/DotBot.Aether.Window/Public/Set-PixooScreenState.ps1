function Set-PixooScreenState {
    <#
    .SYNOPSIS
        Turns the Pixoo64 screen on or off.

    .DESCRIPTION
        Controls the screen power state without affecting other settings.

    .PARAMETER State
        Screen state: On/Off or $true/$false.

    .EXAMPLE
        Set-PixooScreenState -State On

    .EXAMPLE
        Set-PixooScreenState -State Off

    .EXAMPLE
        Set-PixooScreenState -State $true

    .NOTES
        API Endpoint: Channel/OnOffScreen
        The device remains powered and connected when screen is off.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet('On', 'Off', $true, $false, 1, 0)]
        [object]$State
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert state to 0/1
        $stateValue = switch ($State) {
            'On' { 1 }
            'Off' { 0 }
            $true { 1 }
            $false { 0 }
            1 { 1 }
            0 { 0 }
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Turn screen $(if ($stateValue -eq 1) { 'on' } else { 'off' })"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting screen state to $stateValue"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Channel/OnOffScreen'
                    OnOff = $stateValue
                }

                Write-Verbose "Screen state set successfully"
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
