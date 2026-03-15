function Disconnect-Pixoo {
    <#
    .SYNOPSIS
        Disconnects from the current Pixoo64 session.

    .DESCRIPTION
        Clears the module-scoped session variable, ending the connection to the Pixoo64 device.

    .EXAMPLE
        Disconnect-Pixoo

    .NOTES
        Does not send any commands to the device, just clears local session state.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    process {
        if ($script:PixooSession) {
            $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
            $action = "Disconnect session"

            if ($PSCmdlet.ShouldProcess($target, $action)) {
                Write-Host "Disconnecting from $($script:PixooSession.IPAddress)..." -ForegroundColor Cyan
                $script:PixooSession = $null
                Write-Host "Disconnected successfully" -ForegroundColor Green
            }
        }
        else {
            Write-Warning "No active session to disconnect"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
