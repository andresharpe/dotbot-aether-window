function Connect-Pixoo {
    <#
    .SYNOPSIS
        Establishes connection to a Pixoo64 device.

    .DESCRIPTION
        Tests connectivity to a Pixoo64 device and creates a module session for subsequent commands.
        Supports pipeline input from Find-Pixoo.

    .PARAMETER IPAddress
        IP address of the Pixoo64 device.
        Accepts 'IP' property from pipeline (e.g., from Find-Pixoo).

    .PARAMETER Port
        HTTP port (default 80).

    .PARAMETER TimeoutSec
        Connection timeout in seconds (default 5).

    .EXAMPLE
        Connect-Pixoo -IPAddress '192.168.0.73'

    .EXAMPLE
        Find-Pixoo | Select-Object -First 1 | Connect-Pixoo

        Find and connect to the first discovered device.

    .OUTPUTS
        System.Boolean - $true if connection successful, $false otherwise.

    .NOTES
        Creates $script:PixooSession with connection details.
        Does NOT store brightness or channel (device state can change externally).
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('IP')]
        [ValidateNotNullOrEmpty()]
        [string]$IPAddress,

        [Parameter()]
        [ValidateRange(1, 65535)]
        [int]$Port = 80,

        [Parameter()]
        [ValidateRange(1, 30)]
        [int]$TimeoutSec = 5
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    process {
        $target = "Pixoo64 at $IPAddress"
        $action = "Establish connection"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Host "Connecting to Pixoo64 at $IPAddress..." -ForegroundColor Cyan

                $uri = "http://${IPAddress}:${Port}/post"

                # Test connectivity with GetAllConf
                $body = @{ Command = 'Channel/GetAllConf' } | ConvertTo-Json -Compress

                $response = Invoke-RestMethod -Uri $uri `
                                               -Method Post `
                                               -Body $body `
                                               -ContentType 'application/json' `
                                               -TimeoutSec $TimeoutSec `
                                               -ErrorAction Stop

                if ($response.error_code -ne 0) {
                    Write-Error "Device returned error code: $($response.error_code)"
                    return $false
                }

                # Create session
                $script:PixooSession = @{
                    Uri = $uri
                    IPAddress = $IPAddress
                    Connected = $true
                    LastContact = [DateTime]::Now
                    DeviceInfo = @{
                        DeviceId = $response.DeviceId
                        DeviceName = $response.DeviceName
                    }
                }

                Write-Host "Successfully connected to $($response.DeviceName) ($IPAddress)" -ForegroundColor Green
                return $true
            }
            catch {
                Write-Error "Failed to connect to $IPAddress : $($_.Exception.Message)"
                return $false
            }
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
