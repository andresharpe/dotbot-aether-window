<#
.SYNOPSIS
    SBB Departures Display for Pixoo64

.DESCRIPTION
    Displays upcoming bus and train departures from Zug Fridbach area to Zug main station.
    Queries multiple nearby stops (Fridbach, Salesianum, Roost) and shows the next departures
    with real-time delay information.

.NOTES
    Uses the free Swiss public transport API: https://transport.opendata.ch
#>

# Import the module and connect
Import-Module "$PSScriptRoot\..\src\Pixoo64\Pixoo64.psd1" -Force

$device = Find-Pixoo | Select-Object -First 1
if (-not $device) {
    Write-Error "No device found."
    exit
}

Connect-Pixoo -IPAddress $device.IP

# Configuration
$stations = @(
    "Zug Fridbach"      # Train station (S-Bahn)
    "Zug, Salesianum"   # Bus stop
    "Zug, Roost"        # Bus stop
)
$destination = "Zug"
$refreshInterval = 30  # seconds
$maxDepartures = 4

function Get-Departures {
    param(
        [string[]]$FromStations,
        [string]$ToStation,
        [int]$Limit = 4
    )

    $allConnections = @()

    foreach ($station in $FromStations) {
        try {
            $encodedFrom = [System.Web.HttpUtility]::UrlEncode($station)
            $encodedTo = [System.Web.HttpUtility]::UrlEncode($ToStation)
            $url = "https://transport.opendata.ch/v1/connections?from=$encodedFrom&to=$encodedTo&limit=$Limit"
            
            $response = Invoke-RestMethod -Uri $url -TimeoutSec 10
            
            foreach ($conn in $response.connections) {
                # Use the FIRST non-walk journey section as the true departing leg
                $firstJourney = $conn.sections | Where-Object { $_.journey -ne $null } | Select-Object -First 1
                if (-not $firstJourney) { continue }

                $depStationName = $firstJourney.departure.station.name
                $depTimeRaw = $firstJourney.departure.departure
                $depDelay = $firstJourney.departure.delay

                # Fallbacks
                if (-not $depTimeRaw) { $depTimeRaw = $conn.from.departure }
                if ($null -eq $depDelay) { $depDelay = $conn.from.delay }

                $departureTime = [datetime]$depTimeRaw
                $minutesUntil  = [math]::Floor(($departureTime - (Get-Date)).TotalMinutes)
                $delay         = if ($null -ne $depDelay) { $depDelay } else { 0 }

                # Build product/line id from the journey
                $cat   = $firstJourney.journey.category
                $num   = $firstJourney.journey.number
                if ($cat -eq 'S' -and $num) { $product = "S$num" }
                elseif ($cat -in @('IR','RE','IC','EC','ICE') -and $num) { $product = "$cat$num" }
                elseif ($cat -eq 'B' -and $num) { $product = "$num" }
                else { $product = ($conn.products | Select-Object -First 1) }

                # Map the actual departure station (of the first journey leg)
                $stationShort = switch -Wildcard ($depStationName) {
                    "*Fridbach*" { "FB" }
                    "*Salesianum*" { "SA" }
                    "*Roost*" { "RO" }
                    default { "??" }
                }

                $isTrain = $cat -in @('S','IR','RE','IC','EC','ICE')

                $allConnections += [PSCustomObject]@{
                    Product       = $product
                    DepartureTime = $departureTime
                    MinutesUntil  = $minutesUntil
                    Delay         = $delay
                    Station       = $stationShort
                    FullStation   = $depStationName
                    Icon          = $(if ($isTrain) { 'T' } else { 'B' })
                    IsTrain       = $isTrain
                }
            }
        }
        catch {
            Write-Warning "Failed to fetch from $station`: $_"
        }
    }

    # Remove duplicates (same product at same exact time), filter past, then sort by minutes until departure
    $allConnections |
        Where-Object { $_.MinutesUntil -ge 0 } |
        Group-Object { "$($_.Product)-$($_.DepartureTime.ToString('o'))" } |
        ForEach-Object { $_.Group[0] } |
        Sort-Object MinutesUntil, DepartureTime |
        Select-Object -First $Limit
}

function Update-Display {
    param(
        [array]$Departures
    )

    # Clear display with black background
    Set-PixooSolidColor -HexColor "#000000"

    # Header - use TextId 1
    Send-PixooText -Text "Fridbach > Zug" -Color "#FFFFFF" -Y 2 -TextId 1 -Speed 0

    if ($Departures.Count -eq 0) {
        Send-PixooText -Text "No departures" -Color "#FF6600" -Y 28 -TextId 2
        return
    }

    # Display each departure on a separate line
    $yPositions = @(16, 30, 44, 56)
    $textId = 2

    for ($i = 0; $i -lt [Math]::Min($Departures.Count, 4); $i++) {
        $dep = $Departures[$i]
        
        # Format: "FB S2 5'" or "RO 614 12' +2"
        # Station: FB=Fridbach, SA=Salesianum, RO=Roost
        $lineText = "$($dep.Station) $($dep.Product) $($dep.MinutesUntil)'"
        
        if ($dep.Delay -gt 0) {
            $lineText += " +$($dep.Delay)"
        }

        # Color: cyan for train, yellow for bus, red if delayed, orange if leaving soon
        $color = if ($dep.Delay -gt 0) {
            "#FF4444"  # Red for delayed
        } elseif ($dep.MinutesUntil -le 3) {
            "#FFAA00"  # Orange for leaving soon
        } elseif ($dep.IsTrain) {
            "#00FFFF"  # Cyan for train
        } else {
            "#FFFF00"  # Yellow for bus
        }

        Send-PixooText -Text $lineText -Color $color -Y $yPositions[$i] -TextId $textId -Speed 0
        $textId++
    }
}

# Main loop
Write-Host "`n=== SBB Departures Display ===" -ForegroundColor Cyan
Write-Host "Showing departures from Fridbach area to Zug" -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray

try {
    while ($true) {
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - Fetching departures..." -ForegroundColor DarkGray
        
        $departures = Get-Departures -FromStations $stations -ToStation $destination -Limit $maxDepartures
        
        if ($departures) {
            foreach ($dep in $departures) {
                $delayStr = if ($dep.Delay -gt 0) { " +$($dep.Delay)" } else { "" }
                # Match Pixoo display format: "FB S2 5'" or "RO 614 12' +2"
                Write-Host "  $($dep.Station) $($dep.Product) $($dep.MinutesUntil)'$delayStr" -ForegroundColor Green
            }
        } else {
            Write-Host "  No upcoming departures found" -ForegroundColor Yellow
        }

        Update-Display -Departures $departures
        
        Write-Host "  Next refresh in $refreshInterval seconds..." -ForegroundColor DarkGray
        Start-Sleep -Seconds $refreshInterval
    }
}
finally {
    Write-Host "`nCleaning up..." -ForegroundColor Yellow
    Clear-PixooText
    Disconnect-Pixoo
    Write-Host "Disconnected." -ForegroundColor Green
}
