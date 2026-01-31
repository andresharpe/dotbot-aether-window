function Find-Pixoo {
    <#
    .SYNOPSIS
        Discovers Pixoo64 devices on the local network.

    .DESCRIPTION
        Three-stage device discovery process:
        1. Cloud lookup (via Divoom cloud API) - skipped if -LocalOnly
        2. Build IP candidate list from ARP cache or full subnet scan
        3. Probe each IP in parallel to verify Pixoo devices

    .PARAMETER LocalOnly
        Skip cloud discovery and only search locally.

    .PARAMETER FullScan
        Scan entire /24 subnet instead of just ARP cache entries.
        Slower but more thorough.

    .PARAMETER TimeoutSec
        Timeout in seconds for each device probe (default 2).

    .PARAMETER Subnet
        Override subnet for full scan (e.g., '192.168.1.0/24').
        If not specified, uses the subnet of the first active network adapter.

    .EXAMPLE
        Find-Pixoo

        Discovers devices using cloud + ARP cache (fastest).

    .EXAMPLE
        Find-Pixoo -LocalOnly

        Skip cloud lookup, only search locally.

    .EXAMPLE
        Find-Pixoo -FullScan

        Scan entire subnet (slower but finds all devices).

    .EXAMPLE
        Find-Pixoo | Select-Object -First 1 | Connect-Pixoo

        Find and connect to the first discovered device.

    .OUTPUTS
        PSCustomObject[] - Array of devices with Name, IP, DeviceId, Brightness, ScreenOn, Source, Verified properties.

    .NOTES
        Performance targets:
        - ARP scan: < 5 seconds
        - Full scan: < 20 seconds

        Uses parallel probing with throttle limit of 50 concurrent connections.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter()]
        [switch]$LocalOnly,

        [Parameter()]
        [switch]$FullScan,

        [Parameter()]
        [ValidateRange(1, 30)]
        [int]$TimeoutSec = 3,

        [Parameter()]
        [string]$Subnet
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        $discoveredDevices = [System.Collections.ArrayList]::new()
    }

    process {
        # Stage 1: Cloud Discovery
        if (-not $LocalOnly) {
            Write-Host "Searching for Pixoo devices via cloud..." -ForegroundColor Cyan

            try {
                $cloudUri = 'https://app.divoom-gz.com/Device/ReturnSameLANDevice'
                $cloudResponse = Invoke-RestMethod -Uri $cloudUri `
                                                    -Method Post `
                                                    -ContentType 'application/json' `
                                                    -TimeoutSec 5 `
                                                    -ErrorAction Stop

                if ($cloudResponse.DeviceList -and $cloudResponse.DeviceList.Count -gt 0) {
                    foreach ($device in $cloudResponse.DeviceList) {
                        $deviceObj = [PSCustomObject]@{
                            Name = $device.DeviceName
                            IP = $device.DevicePrivateIP
                            DeviceId = $device.DeviceId
                            Brightness = $null
                            ScreenOn = $null
                            Source = 'Cloud'
                            Verified = $false
                        }
                        [void]$discoveredDevices.Add($deviceObj)
                        Write-Host "  Found: $($device.DeviceName) at $($device.DevicePrivateIP) (via cloud)" -ForegroundColor Green
                    }
                }
                else {
                    Write-Verbose "Cloud API returned no devices"
                }
            }
            catch {
                Write-Warning "Cloud discovery failed: $($_.Exception.Message)"
            }
        }

        # Stage 2: Build IP Candidate List
        Write-Host "Scanning local network..." -ForegroundColor Cyan

        $ipCandidates = [System.Collections.ArrayList]::new()

        if ($FullScan) {
            # Full subnet scan
            if (-not $Subnet) {
                # Auto-detect subnet from first active adapter
                try {
                    $adapter = Get-NetIPAddress -AddressFamily IPv4 |
                               Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.PrefixOrigin -ne 'WellKnown' } |
                               Select-Object -First 1

                    if ($adapter) {
                        $ipParts = $adapter.IPAddress -split '\.'
                        $Subnet = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2]).0/24"
                        Write-Verbose "Auto-detected subnet: $Subnet"
                    }
                    else {
                        Write-Error "Could not auto-detect subnet. Please specify -Subnet parameter."
                        return
                    }
                }
                catch {
                    Write-Error "Failed to detect subnet: $($_.Exception.Message)"
                    return
                }
            }

            # Generate all IPs in subnet
            $subnetParts = $Subnet -split '/'
            $baseIP = $subnetParts[0]
            $ipParts = $baseIP -split '\.'

            Write-Verbose "Generating full subnet IP list for $Subnet"

            for ($i = 1; $i -le 254; $i++) {
                $ip = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2]).$i"
                [void]$ipCandidates.Add($ip)
            }

            Write-Host "  Scanning $($ipCandidates.Count) IP addresses..." -ForegroundColor Cyan
        }
        else {
            # ARP cache scan (faster)
            Write-Verbose "Reading ARP cache"

            try {
                if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
                    # Windows
                    $arpOutput = & arp -a
                    foreach ($line in $arpOutput) {
                        if ($line -match '^\s+(\d+\.\d+\.\d+\.\d+)\s+') {
                            [void]$ipCandidates.Add($Matches[1])
                        }
                    }
                }
                else {
                    # Linux/macOS
                    $arpOutput = & arp -an
                    foreach ($line in $arpOutput) {
                        if ($line -match '\((\d+\.\d+\.\d+\.\d+)\)') {
                            [void]$ipCandidates.Add($Matches[1])
                        }
                    }
                }

                Write-Host "  Found $($ipCandidates.Count) IPs in ARP cache" -ForegroundColor Cyan
            }
            catch {
                Write-Warning "Failed to read ARP cache: $($_.Exception.Message)"
            }
        }

        # Stage 3: Parallel Probe
        if ($ipCandidates.Count -gt 0) {
            Write-Host "Probing devices..." -ForegroundColor Cyan

            $probeResults = Invoke-PixooParallelProbe -IPAddresses $ipCandidates.ToArray() -TimeoutSec $TimeoutSec

            foreach ($result in $probeResults) {
                # Check if already found via cloud
                $existingDevice = $discoveredDevices | Where-Object { $_.IP -eq $result.IP }

                if ($existingDevice) {
                    # Update cloud-discovered device with verified info
                    $existingDevice.Brightness = $result.Brightness
                    $existingDevice.Verified = $true
                    Write-Host "  Verified: $($existingDevice.Name) at $($result.IP)" -ForegroundColor Green
                }
                else {
                    # New device found locally - use fallback name if not available
                    $deviceName = if ($result.Name) { $result.Name } else { 'Pixoo64' }
                    $deviceObj = [PSCustomObject]@{
                        Name = $deviceName
                        IP = $result.IP
                        DeviceId = $result.DeviceId
                        Brightness = $result.Brightness
                        ScreenOn = $null
                        Source = if ($FullScan) { 'FullScan' } else { 'ARP' }
                        Verified = $true
                    }
                    [void]$discoveredDevices.Add($deviceObj)
                    Write-Host "  Found: $deviceName at $($result.IP) (local)" -ForegroundColor Green
                }
            }
        }

        # Summary
        $verifiedCount = ($discoveredDevices | Where-Object { $_.Verified }).Count
        Write-Host "`nDiscovery complete: $($discoveredDevices.Count) device(s) found, $verifiedCount verified" -ForegroundColor Green

        if ($discoveredDevices.Count -eq 0) {
            Write-Warning "No Pixoo devices found. Try using -FullScan for a more thorough search."
        }

        return $discoveredDevices.ToArray()
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
