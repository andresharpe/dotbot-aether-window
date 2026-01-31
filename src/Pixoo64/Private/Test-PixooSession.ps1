function Test-PixooSession {
    <#
    .SYNOPSIS
        Validates that a Pixoo session exists.

    .DESCRIPTION
        Checks if the module-scoped $script:PixooSession variable is initialized.
        Used internally by all functions that require an active connection.

    .PARAMETER Throw
        If specified, throws a terminating error when session is not found.
        Otherwise, returns $false.

    .EXAMPLE
        Test-PixooSession -Throw

    .EXAMPLE
        if (Test-PixooSession) { ... }

    .NOTES
        This is an internal helper function used for session validation.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Throw
    )

    $sessionExists = $null -ne $script:PixooSession -and $script:PixooSession.Connected -eq $true

    if (-not $sessionExists -and $Throw) {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new('Not connected to a Pixoo device. Use Connect-Pixoo first.'),
            'PixooSessionNotFound',
            [System.Management.Automation.ErrorCategory]::ConnectionError,
            $null
        )
        throw $errorRecord
    }

    # Only return value when not using -Throw (for conditional checks)
    if (-not $Throw) {
        return $sessionExists
    }
}
