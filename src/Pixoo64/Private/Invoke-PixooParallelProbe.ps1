function Invoke-PixooParallelProbe {
    <#
    .SYNOPSIS
        Probes multiple IP addresses in parallel for Pixoo devices.

    .DESCRIPTION
        Tests an array of IP addresses for Pixoo64 devices using parallel execution
        via Start-ThreadJob.

    .PARAMETER IPAddresses
        Array of IP addresses to probe.

    .PARAMETER TimeoutSec
        Timeout in seconds for each probe attempt.

    .PARAMETER ThrottleLimit
        Maximum number of concurrent probes (default 50).

    .EXAMPLE
        Invoke-PixooParallelProbe -IPAddresses @('192.168.0.1', '192.168.0.2')

    .OUTPUTS
        Array of successful probe results with IP, DeviceId, Name, Brightness properties.

    .NOTES
        This is an internal helper function for Find-Pixoo.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$IPAddresses,

        [Parameter()]
        [int]$TimeoutSec = 2,

        [Parameter()]
        [int]$ThrottleLimit = 50
    )

    Write-Verbose "Starting parallel probe of $($IPAddresses.Count) IP addresses"

    $results = [System.Collections.ArrayList]::new()

    $jobs = foreach ($ip in $IPAddresses) {
        Start-ThreadJob -ThrottleLimit $ThrottleLimit -ScriptBlock {
            param($IPAddress, $Timeout)

            try {
                $uri = "http://${IPAddress}:80/post"
                $body = @{ Command = 'Channel/GetAllConf' } | ConvertTo-Json -Compress

                $response = Invoke-RestMethod -Uri $uri `
                                               -Method Post `
                                               -Body $body `
                                               -ContentType 'application/json' `
                                               -TimeoutSec $Timeout `
                                               -ErrorAction Stop

                if ($response.error_code -eq 0) {
                    return [PSCustomObject]@{
                        IP = $IPAddress
                        DeviceId = $response.DeviceId
                        Name = $response.DeviceName
                        Brightness = $response.Brightness
                    }
                }
            }
            catch {
                # Silently ignore failures
                return $null
            }
        } -ArgumentList $ip, $TimeoutSec
    }

    # Wait for all jobs and collect results
    $jobs | Wait-Job | ForEach-Object {
        $result = Receive-Job -Job $_
        if ($result) {
            [void]$results.Add($result)
        }
        Remove-Job -Job $_ -Force
    }

    Write-Verbose "Parallel probe completed. Found $($results.Count) device(s)"

    return $results.ToArray()
}
