function Invoke-PixooCommand {
    <#
    .SYNOPSIS
        Core API wrapper for sending commands to Pixoo64 device.

    .DESCRIPTION
        Sends HTTP POST requests to the Pixoo64 REST API with automatic retry logic
        for transient failures. This is the foundation function used by all public
        API commands.

    .PARAMETER Command
        Hashtable containing the command structure to send to the device.
        Will be converted to JSON with depth 10 for nested objects.

    .PARAMETER MaxRetries
        Maximum number of retry attempts for transient failures (timeout, connection refused, 5xx errors).
        Default is 3. Does NOT retry on permanent errors (4xx, JSON parse errors, error_code != 0).

    .EXAMPLE
        Invoke-PixooCommand -Command @{ Command = 'Channel/GetAllConf' }

    .NOTES
        - Validates session exists before sending request
        - Uses exponential backoff: 1s, 2s, 4s between retries
        - Updates $script:PixooSession.LastContact on successful response
        - Only retries on transient failures (network issues, 5xx errors)
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Command,

        [Parameter()]
        [ValidateRange(1, 10)]
        [int]$MaxRetries = 3
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"

        # Validate session exists
        if (-not (Test-PixooSession)) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new('Not connected to a Pixoo device. Use Connect-Pixoo first.'),
                'PixooSessionNotFound',
                [System.Management.Automation.ErrorCategory]::ConnectionError,
                $null
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    process {
        $attempt = 0
        $lastError = $null

        while ($attempt -lt $MaxRetries) {
            $attempt++

            try {
                Write-Verbose "Attempt $attempt of $MaxRetries - Sending command to $($script:PixooSession.Uri)"
                Write-Verbose "Command: $($Command | ConvertTo-Json -Depth 10 -Compress)"

                # Convert command to JSON
                $body = $Command | ConvertTo-Json -Depth 10 -Compress

                # Send POST request
                $response = Invoke-RestMethod -Uri $script:PixooSession.Uri `
                                               -Method Post `
                                               -Body $body `
                                               -ContentType 'application/json' `
                                               -TimeoutSec 10 `
                                               -ErrorAction Stop

                Write-Verbose "Response: $($response | ConvertTo-Json -Depth 5 -Compress)"

                # Update last contact timestamp
                $script:PixooSession.LastContact = [DateTime]::Now

                # Validate error_code in response
                if ($response.PSObject.Properties.Name -contains 'error_code') {
                    if ($response.error_code -ne 0) {
                        # API-level error - do not retry
                        Write-PixooError -ErrorCode $response.error_code -Command $Command.Command
                        return $response
                    }
                }

                # Success
                Write-Verbose "Command executed successfully"
                return $response
            }
            catch [System.Net.WebException] {
                $lastError = $_
                $statusCode = $null

                if ($_.Exception.Response) {
                    $statusCode = [int]$_.Exception.Response.StatusCode
                }

                # Determine if we should retry
                $shouldRetry = $false

                if ($statusCode) {
                    # Retry on 5xx errors (server errors)
                    if ($statusCode -ge 500 -and $statusCode -lt 600) {
                        $shouldRetry = $true
                        Write-Verbose "Server error (HTTP $statusCode) - will retry"
                    }
                    # Do NOT retry on 4xx errors (client errors)
                    elseif ($statusCode -ge 400 -and $statusCode -lt 500) {
                        Write-Verbose "Client error (HTTP $statusCode) - will not retry"
                        $shouldRetry = $false
                        break
                    }
                }
                else {
                    # Network-level error (timeout, connection refused, etc.) - retry
                    $shouldRetry = $true
                    Write-Verbose "Network error - will retry: $($_.Exception.Message)"
                }

                if (-not $shouldRetry -or $attempt -ge $MaxRetries) {
                    break
                }

                # Exponential backoff: 1s, 2s, 4s
                $backoffSeconds = [Math]::Pow(2, $attempt - 1)
                Write-Verbose "Waiting $backoffSeconds seconds before retry..."
                Start-Sleep -Seconds $backoffSeconds
            }
            catch {
                # Other errors (JSON parse, unexpected exceptions) - do not retry
                $lastError = $_
                Write-Verbose "Non-retryable error: $($_.Exception.Message)"
                break
            }
        }

        # All retries exhausted or non-retryable error
        if ($lastError) {
            $errorMessage = "Failed to execute command after $attempt attempt(s): $($lastError.Exception.Message)"
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new($errorMessage),
                'PixooCommandFailed',
                [System.Management.Automation.ErrorCategory]::ConnectionError,
                $Command
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
