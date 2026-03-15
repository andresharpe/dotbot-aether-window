function Write-PixooError {
    <#
    .SYNOPSIS
        Maps Pixoo API error codes to descriptive messages.

    .DESCRIPTION
        Converts Pixoo64 REST API error codes into user-friendly error messages.
        Currently only error_code 0 (success) is documented by Divoom.

    .PARAMETER ErrorCode
        The error code returned by the Pixoo API.

    .PARAMETER Command
        The command that generated the error (for context).

    .EXAMPLE
        Write-PixooError -ErrorCode 1 -Command 'Channel/SetBrightness'

    .NOTES
        This is an internal helper function for error handling.
        Error code mapping:
        - 0 = Success (this function should not be called for code 0)
        - Other codes = Unknown (not documented by Divoom)
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ErrorCode,

        [Parameter()]
        [string]$Command
    )

    # Map known error codes
    $errorMessages = @{
        0 = 'Success'
    }

    $message = if ($errorMessages.ContainsKey($ErrorCode)) {
        $errorMessages[$ErrorCode]
    }
    else {
        "Unknown error (code: $ErrorCode)"
    }

    if ($Command) {
        $message = "$message - Command: $Command"
    }

    Write-Error $message
}
