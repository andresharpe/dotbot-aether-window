<#
.SYNOPSIS
    Creating Animations on the Pixoo64

.DESCRIPTION
    This example demonstrates frame-by-frame animations.
#>

# Import the module and connect
Import-Module "$PSScriptRoot\..\src\Pixoo64\Pixoo64.psd1" -Force

$device = Find-Pixoo | Select-Object -First 1
if (-not $device) {
    Write-Error "No device found."
    exit
}

Connect-Pixoo -IPAddress $device.IP

Write-Host "`n=== Animation Examples ===" -ForegroundColor Cyan

# Example 1: Simple color fade animation
Write-Host "1. Creating color fade animation (10 frames)" -ForegroundColor Yellow

$frames = @()
for ($i = 0; $i -lt 10; $i++) {
    # Fade from red to blue
    $red = [byte](255 - ($i * 25))
    $blue = [byte]($i * 25)

    # Create frame data
    $frameData = [byte[]]::new(12288)
    for ($pixel = 0; $pixel -lt 4096; $pixel++) {
        $offset = $pixel * 3
        $frameData[$offset] = $red
        $frameData[$offset + 1] = 0
        $frameData[$offset + 2] = $blue
    }

    # Convert to Base64
    $frames += [Convert]::ToBase64String($frameData)
}

# Send animation
Send-PixooAnimation -Frames $frames -FrameDelay 200

Write-Host "Animation playing (200ms per frame)..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Example 2: Moving dot animation
Write-Host "2. Creating moving dot animation (20 frames)" -ForegroundColor Yellow

function New-DotFrame {
    param([int]$X, [int]$Y, [byte]$R, [byte]$G, [byte]$B)

    $frame = [byte[]]::new(12288)
    # Fill with black
    for ($i = 0; $i -lt 12288; $i++) { $frame[$i] = 0 }

    # Draw 5x5 dot at position
    for ($dy = -2; $dy -le 2; $dy++) {
        for ($dx = -2; $dx -le 2; $dx++) {
            $px = $X + $dx
            $py = $Y + $dy

            if ($px -ge 0 -and $px -lt 64 -and $py -ge 0 -and $py -lt 64) {
                $offset = (($py * 64) + $px) * 3
                $frame[$offset] = $R
                $frame[$offset + 1] = $G
                $frame[$offset + 2] = $B
            }
        }
    }

    return [Convert]::ToBase64String($frame)
}

$dotFrames = @()
for ($i = 0; $i -lt 20; $i++) {
    # Move dot in a circle
    $angle = ($i / 20.0) * [Math]::PI * 2
    $x = [int](32 + ([Math]::Cos($angle) * 20))
    $y = [int](32 + ([Math]::Sin($angle) * 20))

    $dotFrames += New-DotFrame -X $x -Y $y -R 0 -G 255 -B 0
}

Send-PixooAnimation -Frames $dotFrames -FrameDelay 100

Write-Host "Dot animation playing..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Clean up
Reset-PixooDisplay

Write-Host "`nAnimations complete!" -ForegroundColor Green
Disconnect-Pixoo
