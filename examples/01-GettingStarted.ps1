<#
.SYNOPSIS
    Getting Started with the Pixoo64 Module

.DESCRIPTION
    This example demonstrates basic device discovery, connection, and configuration.
#>

# Import the module
Import-Module "$PSScriptRoot\..\src\Pixoo64\Pixoo64.psd1" -Force

# Method 1: Discover devices automatically
Write-Host "`n=== Device Discovery ===" -ForegroundColor Cyan
$devices = Find-Pixoo
$devices | Format-Table Name, IP, DeviceId, Brightness, Source, Verified

# Method 2: Full subnet scan (slower but more thorough)
# $devices = Find-Pixoo -FullScan

# Connect to the first discovered device
Write-Host "`n=== Connecting to Device ===" -ForegroundColor Cyan
if ($devices) {
    $connected = $devices | Select-Object -First 1 | Connect-Pixoo

    if ($connected) {
        # Get device configuration
        Write-Host "`n=== Device Configuration ===" -ForegroundColor Cyan
        $config = Get-PixooConfiguration
        Write-Host "Device Name: $($config.DeviceName)"
        Write-Host "Brightness: $($config.Brightness)"
        Write-Host "Current Clock ID: $($config.CurClockId)"
        Write-Host "Screen On: $(if ($config.LightSwitch -eq 1) { 'Yes' } else { 'No' })"

        # Test connection
        Write-Host "`n=== Testing Connection ===" -ForegroundColor Cyan
        Test-PixooConnection

        # Clean up
        Write-Host "`n=== Disconnecting ===" -ForegroundColor Cyan
        Disconnect-Pixoo
    }
}
else {
    Write-Warning "No devices found. Try using Find-Pixoo -FullScan or specify IP manually with Connect-Pixoo"
}
