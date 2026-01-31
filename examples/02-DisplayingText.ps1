<#
.SYNOPSIS
    Displaying Text on the Pixoo64

.DESCRIPTION
    This example demonstrates various text display options.
#>

# Import the module and connect
Import-Module "$PSScriptRoot\..\src\Pixoo64\Pixoo64.psd1" -Force

# Connect to device (replace with your IP or use Find-Pixoo)
$device = Find-Pixoo | Select-Object -First 1
if (-not $device) {
    Write-Error "No device found. Please ensure your Pixoo64 is on the network."
    exit
}

Connect-Pixoo -IPAddress $device.IP

Write-Host "`n=== Text Display Examples ===" -ForegroundColor Cyan

# IMPORTANT: Text commands only work after sending an image first
# Set a black background before displaying text
Set-PixooSolidColor -HexColor "#000000"

# Example 1: Basic text with default settings
Write-Host "1. Basic green text" -ForegroundColor Yellow
Send-PixooText -Text "Hello World!"
Start-Sleep -Seconds 3

# Example 2: Colored text
Write-Host "2. Red text" -ForegroundColor Yellow
Send-PixooText -Text "Red Alert!" -Color "#FF0000"
Start-Sleep -Seconds 3

# Example 3: Blue text with custom position
Write-Host "3. Blue text at top" -ForegroundColor Yellow
Send-PixooText -Text "Top of Screen" -Color "#0000FF" -Y 5
Start-Sleep -Seconds 3

# Example 4: Fast scrolling yellow text
Write-Host "4. Fast scrolling yellow text" -ForegroundColor Yellow
Send-PixooText -Text "Speed Demo" -Color "#FFFF00" -Speed 80
Start-Sleep -Seconds 3

# Example 5: Multiple text lines using different TextIDs
Write-Host "5. Multiple text overlays" -ForegroundColor Yellow
Send-PixooText -Text "Line 1" -Color "#00FF00" -Y 10 -TextId 1
Send-PixooText -Text "Line 2" -Color "#FF00FF" -Y 30 -TextId 2
Start-Sleep -Seconds 3

# Example 6: Pipeline input
Write-Host "6. Pipeline text" -ForegroundColor Yellow
"PowerShell", "Pixoo64", "Module" | ForEach-Object {
    Send-PixooText -Text $_ -Color "#00FFFF"
    Start-Sleep -Seconds 2
}

# Clear all text
Write-Host "7. Clearing text" -ForegroundColor Yellow
Clear-PixooText
Start-Sleep -Seconds 1

# Disconnect
Write-Host "`nExamples complete!" -ForegroundColor Green
Disconnect-Pixoo
