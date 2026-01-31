<#
.SYNOPSIS
    Using Pixoo64 Tools

.DESCRIPTION
    This example demonstrates timer, stopwatch, scoreboard, and buzzer functions.
#>

# Import the module and connect
Import-Module ..\src\Pixoo64\Pixoo64.psd1 -Force

$device = Find-Pixoo | Select-Object -First 1
if (-not $device) {
    Write-Error "No device found."
    exit
}

Connect-Pixoo -IPAddress $device.IP

Write-Host "`n=== Tool Examples ===" -ForegroundColor Cyan

# Example 1: Countdown Timer
Write-Host "1. Starting 30-second countdown timer" -ForegroundColor Yellow
Start-PixooTimer -Seconds 30
Write-Host "   Timer running on device..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Example 2: Timer with minutes
Write-Host "2. Starting 2-minute timer" -ForegroundColor Yellow
Start-PixooTimer -Minutes 2
Start-Sleep -Seconds 3

# Example 3: Stopwatch
Write-Host "3. Stopwatch demo" -ForegroundColor Yellow
Write-Host "   Starting stopwatch..." -ForegroundColor Gray
Start-PixooStopwatch -Action Start
Start-Sleep -Seconds 3

Write-Host "   Stopping stopwatch..." -ForegroundColor Gray
Start-PixooStopwatch -Action Stop
Start-Sleep -Seconds 2

Write-Host "   Resetting stopwatch..." -ForegroundColor Gray
Start-PixooStopwatch -Action Reset
Start-Sleep -Seconds 2

# Example 4: Scoreboard
Write-Host "4. Scoreboard demo" -ForegroundColor Yellow
Set-PixooScoreboard -RedScore 0 -BlueScore 0
Start-Sleep -Seconds 2

Write-Host "   Red team scores!" -ForegroundColor Gray
Set-PixooScoreboard -RedScore 10 -BlueScore 0
Start-Sleep -Seconds 2

Write-Host "   Blue team scores!" -ForegroundColor Gray
Set-PixooScoreboard -RedScore 10 -BlueScore 8
Start-Sleep -Seconds 2

# Example 5: Buzzer patterns
Write-Host "5. Buzzer demo" -ForegroundColor Yellow
Write-Host "   Short beep..." -ForegroundColor Gray
Start-PixooBuzzer -Preset Short
Start-Sleep -Seconds 2

Write-Host "   Alert pattern..." -ForegroundColor Gray
Start-PixooBuzzer -Preset Alert
Start-Sleep -Seconds 4

# Example 6: Noise Meter
Write-Host "6. Noise meter (audio visualizer)" -ForegroundColor Yellow
Write-Host "   Starting noise meter..." -ForegroundColor Gray
Set-PixooNoiseMeter -Enabled $true
Start-Sleep -Seconds 5

Write-Host "   Stopping noise meter..." -ForegroundColor Gray
Set-PixooNoiseMeter -Enabled $false
Start-Sleep -Seconds 1

Write-Host "`nTool examples complete!" -ForegroundColor Green
Disconnect-Pixoo
