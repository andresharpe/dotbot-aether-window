<#
.SYNOPSIS
    Showing Images and Colors on the Pixoo64

.DESCRIPTION
    This example demonstrates solid colors and image display.
#>

# Import the module and connect
Import-Module ..\src\Pixoo64\Pixoo64.psd1 -Force

$device = Find-Pixoo | Select-Object -First 1
if (-not $device) {
    Write-Error "No device found."
    exit
}

Connect-Pixoo -IPAddress $device.IP

Write-Host "`n=== Solid Color Examples ===" -ForegroundColor Cyan

# Example 1: Red screen
Write-Host "1. Solid red" -ForegroundColor Yellow
Set-PixooSolidColor -Red 255 -Green 0 -Blue 0
Start-Sleep -Seconds 2

# Example 2: Green screen
Write-Host "2. Solid green" -ForegroundColor Yellow
Set-PixooSolidColor -Red 0 -Green 255 -Blue 0
Start-Sleep -Seconds 2

# Example 3: Blue screen
Write-Host "3. Solid blue" -ForegroundColor Yellow
Set-PixooSolidColor -Red 0 -Green 0 -Blue 255
Start-Sleep -Seconds 2

# Example 4: Hex color (purple)
Write-Host "4. Purple (hex color)" -ForegroundColor Yellow
Set-PixooSolidColor -HexColor "#800080"
Start-Sleep -Seconds 2

# Example 5: Gradient effect (quick color changes)
Write-Host "5. Rainbow effect" -ForegroundColor Yellow
$colors = @(
    @{ R=255; G=0; B=0 }     # Red
    @{ R=255; G=127; B=0 }   # Orange
    @{ R=255; G=255; B=0 }   # Yellow
    @{ R=0; G=255; B=0 }     # Green
    @{ R=0; G=0; B=255 }     # Blue
    @{ R=75; G=0; B=130 }    # Indigo
    @{ R=148; G=0; B=211 }   # Violet
)

foreach ($color in $colors) {
    Set-PixooSolidColor -Red $color.R -Green $color.G -Blue $color.B
    Start-Sleep -Milliseconds 500
}

# Example 6: Checkerboard pattern (using image data)
Write-Host "6. Checkerboard pattern" -ForegroundColor Yellow
$imageData = [byte[]]::new(12288)  # 64x64x3 bytes
for ($y = 0; $y -lt 64; $y++) {
    for ($x = 0; $x -lt 64; $x++) {
        $offset = (($y * 64) + $x) * 3
        if (($x + $y) % 2 -eq 0) {
            # White
            $imageData[$offset] = 255
            $imageData[$offset + 1] = 255
            $imageData[$offset + 2] = 255
        }
        else {
            # Black
            $imageData[$offset] = 0
            $imageData[$offset + 1] = 0
            $imageData[$offset + 2] = 0
        }
    }
}

Send-PixooImage -ImageData $imageData
Start-Sleep -Seconds 3

# Reset display
Reset-PixooDisplay

Write-Host "`nExamples complete!" -ForegroundColor Green
Disconnect-Pixoo
