function Test-PixooConnection {
    <#
    .SYNOPSIS
        Tests connection to the current Pixoo64 session.

    .DESCRIPTION
        Verifies that the current session is valid without modifying it.
        Optionally suppresses output with -Quiet.

    .PARAMETER Quiet
        Suppresses console output, returns only boolean result.

    .EXAMPLE
        Test-PixooConnection

    .EXAMPLE
        if (Test-PixooConnection -Quiet) { ... }

    .OUTPUTS
        System.Boolean - $true if connected, $false otherwise.

    .NOTES
        Read-only function - does not modify session state.
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter()]
        [switch]$Quiet
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    process {
        $connected = Test-PixooSession

        if (-not $Quiet) {
            if ($connected) {
                Write-Host "Connected to Pixoo64 at $($script:PixooSession.IPAddress)" -ForegroundColor Green
                Write-Host "  Last contact: $($script:PixooSession.LastContact)" -ForegroundColor Gray
            }
            else {
                Write-Host "Not connected to any Pixoo64 device" -ForegroundColor Yellow
            }
        }

        return $connected
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
