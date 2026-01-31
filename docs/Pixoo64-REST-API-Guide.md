# Divoom Pixoo64 REST API Guide for PowerShell

A practical guide for controlling your Pixoo64 via its local REST API from Windows PowerShell.

## Overview

The Pixoo64 exposes a local HTTP API on port 80 that accepts JSON POST requests. All commands are sent to `http://<device-ip>:80/post` with a JSON body containing a `Command` field.

**Official Documentation**: http://doc.divoom-gz.com/web/#/12?page_id=196 (requires JavaScript)

**Key Community Resources**:
- [SomethingWithComputers/pixoo](https://github.com/SomethingWithComputers/pixoo) - Python library (most comprehensive)
- [r12f/divoom](https://github.com/r12f/divoom) - Rust library with CLI
- [4ch1m/pixoo-rest](https://github.com/4ch1m/pixoo-rest) - REST wrapper with Swagger UI
- [gickowtf/pixoo-homeassistant](https://github.com/gickowtf/pixoo-homeassistant) - Home Assistant integration

---

## Initial Setup

### 1. Find Your Device IP

Open the Divoom app → Settings → Device Information → IP Address

### 2. Test Connectivity

```powershell
$pixooIP = "192.168.0.73"  # Replace with your IP

# Ping test
Test-Connection -ComputerName $pixooIP -Count 2

# Port test
Test-NetConnection -ComputerName $pixooIP -Port 80
```

### 3. Basic API Test

```powershell
$uri = "http://192.168.0.73:80/post"

$response = Invoke-RestMethod -Uri $uri -Method Post `
    -Body '{"Command":"Channel/GetAllConf"}' `
    -ContentType "application/json"

$response | ConvertTo-Json -Depth 5
```

**Expected Response**:
```json
{
  "error_code": 0,
  "Brightness": 100,
  "RotationFlag": 0,
  "ClockTime": 0,
  "GalleryTime": 0,
  "SingleGalleyTime": -1,
  "PowerOnChannelId": 2,
  "GalleryShowTimeFlag": 0,
  "CurClockId": 104,
  "Time24Flag": 0,
  "TemperatureMode": 0,
  "GyrateAngle": 0,
  "MirrorFlag": 0,
  "LightSwitch": 1
}
```

`error_code: 0` = success

---

## Known Issues & Workarounds

### Buffer/Image Stuck Issue
The Pixoo64 has a known firmware bug where previous images can remain stuck on screen. **Always call `Draw/ResetHttpGifId` before sending new images.**

```powershell
# Reset before drawing
Invoke-RestMethod -Uri $uri -Method Post -Body '{"Command":"Draw/ResetHttpGifId"}' -ContentType "application/json"
```

### Text Only Scrolls Left
Most fonts only support left-scrolling text. This is a firmware limitation.

### ~300 Update Limit
After approximately 300 screen updates, the device may stop responding. Power cycle or use `ResetHttpGifId` periodically.

### Maximum Animation Frames
Animations are limited to approximately 40 frames. Exceeding this may crash the device.

---

## Verified Working Commands

### Device Information & Settings

#### Get All Configuration
```powershell
$body = '{"Command":"Channel/GetAllConf"}'
Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Set Brightness (0-100)
```powershell
$body = @{
    Command = "Channel/SetBrightness"
    Brightness = 75
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Turn Screen On/Off
```powershell
# Turn off
$body = @{
    Command = "Channel/OnOffScreen"
    OnOff = 0  # 0 = off, 1 = on
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Get Clock Info
```powershell
$body = '{"Command":"Channel/GetClockInfo"}'
Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

---

### Channel Control

Channels control what the display shows. Channel indices:
- `0` = Faces (clock faces)
- `1` = Cloud Channel (community gallery)
- `2` = Visualizer (music visualization)
- `3` = Custom (your uploaded content)

#### Switch Channel
```powershell
$body = @{
    Command = "Channel/SetIndex"
    SelectIndex = 3  # Switch to Custom channel
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Get Current Channel
```powershell
$body = '{"Command":"Channel/GetIndex"}'
Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Select Clock Face
```powershell
$body = @{
    Command = "Channel/SetClockSelectId"
    ClockId = 104  # Clock face ID from app
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

---

### Drawing: Text

#### Send Scrolling Text
```powershell
$body = @{
    Command = "Draw/SendHttpText"
    TextId = 1            # Unique ID (1-20), use to update existing text
    x = 0                 # X position
    y = 24                # Y position (0 = top)
    dir = 0               # Scroll direction: 0=left, 1=right
    font = 2              # Font ID (0-7, support varies)
    TextWidth = 64        # Text box width
    speed = 50            # Scroll speed in ms
    TextString = "Hello World!"
    color = "#00FF00"     # Hex color
    align = 1             # Alignment: 1=left, 2=center, 3=right
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

**Font Reference** (support varies by firmware):
- `0` - Small
- `1` - Small bold  
- `2` - Medium (most reliable)
- `3-7` - Various sizes (may crash on some characters)

#### Clear All Text
```powershell
$body = '{"Command":"Draw/ClearHttpText"}'
Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

---

### Drawing: Images & Animation

The PicData format is Base64-encoded RGB data:
- 24-bit color (3 bytes per pixel: R, G, B)
- 64×64 = 4096 pixels
- Total: 12,288 bytes raw → Base64 encoded

#### Reset GIF ID (IMPORTANT - Always Do First!)
```powershell
$body = '{"Command":"Draw/ResetHttpGifId"}'
Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Get Current GIF ID
```powershell
$body = '{"Command":"Draw/GetHttpGifId"}'
Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Send Static Image (Solid Color)
```powershell
# Helper function to create solid color
function Get-PixooSolidColor {
    param([byte]$R, [byte]$G, [byte]$B)
    $pixels = New-Object byte[] (64 * 64 * 3)
    for ($i = 0; $i -lt 4096; $i++) {
        $pixels[$i * 3] = $R
        $pixels[$i * 3 + 1] = $G
        $pixels[$i * 3 + 2] = $B
    }
    return [Convert]::ToBase64String($pixels)
}

# Reset first
Invoke-RestMethod -Uri $uri -Method Post -Body '{"Command":"Draw/ResetHttpGifId"}' -ContentType "application/json"

# Send red screen
$body = @{
    Command = "Draw/SendHttpGif"
    PicNum = 1
    PicWidth = 64
    PicOffset = 0
    PicID = 1
    PicSpeed = 1000
    PicData = (Get-PixooSolidColor -R 255 -G 0 -B 0)
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Send Animation (Multiple Frames)
```powershell
# Reset first
Invoke-RestMethod -Uri $uri -Method Post -Body '{"Command":"Draw/ResetHttpGifId"}' -ContentType "application/json"

# Send frame 1 (red)
$body = @{
    Command = "Draw/SendHttpGif"
    PicNum = 2          # Total number of frames
    PicWidth = 64
    PicOffset = 0       # Frame index (0-based)
    PicID = 1
    PicSpeed = 500      # Frame duration in ms
    PicData = (Get-PixooSolidColor -R 255 -G 0 -B 0)
} | ConvertTo-Json
Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"

# Send frame 2 (blue)
$body = @{
    Command = "Draw/SendHttpGif"
    PicNum = 2
    PicWidth = 64
    PicOffset = 1
    PicID = 1
    PicSpeed = 500
    PicData = (Get-PixooSolidColor -R 0 -G 0 -B 255)
} | ConvertTo-Json
Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Play GIF from URL
```powershell
$body = @{
    Command = "Device/PlayTFGif"
    FileType = 2        # 0=SD card file, 1=SD card folder, 2=URL
    FileName = "https://example.com/animation.gif"
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

---

### Tools

#### Countdown Timer
```powershell
$body = @{
    Command = "Tools/SetTimer"
    Minute = 5
    Second = 0
    Status = 1  # 1=start, 0=stop
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Stopwatch
```powershell
$body = @{
    Command = "Tools/SetStopWatch"
    Status = 1  # 1=start, 2=stop, 0=reset
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Scoreboard
```powershell
$body = @{
    Command = "Tools/SetScoreBoard"
    BlueScore = 10
    RedScore = 5
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Noise Meter
```powershell
$body = @{
    Command = "Tools/SetNoiseStatus"
    NoiseStatus = 1  # 1=start, 0=stop
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Buzzer
```powershell
$body = @{
    Command = "Device/PlayBuzzer"
    ActiveTimeInCycle = 500   # Buzz duration ms
    OffTimeInCycle = 500      # Pause duration ms
    PlayTotalTime = 3000      # Total duration ms
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

---

### Device Settings

#### Set 24-Hour Time Format
```powershell
$body = @{
    Command = "Device/SetTime24Flag"
    Mode = 1  # 0=12-hour, 1=24-hour
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Set Temperature Unit
```powershell
$body = @{
    Command = "Device/SetDisTempMode"
    Mode = 0  # 0=Celsius, 1=Fahrenheit
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Set Rotation Angle
```powershell
$body = @{
    Command = "Device/SetScreenRotationAngle"
    Mode = 0  # 0=0°, 1=90°, 2=180°, 3=270°
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Set Mirror Mode
```powershell
$body = @{
    Command = "Device/SetMirrorMode"
    Mode = 0  # 0=off, 1=on
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

#### Set High-Light Mode
```powershell
$body = @{
    Command = "Device/SetHighLightMode"
    Mode = 0  # 0=off, 1=on (requires 5V3A power)
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
```

---

## Complete Command Reference

Based on APK reverse engineering and community research:

### Channel Commands
| Command | Description |
|---------|-------------|
| `Channel/GetIndex` | Get current channel |
| `Channel/SetIndex` | Set channel (0=Faces, 1=Cloud, 2=Visualizer, 3=Custom) |
| `Channel/GetAllConf` | Get all device configuration |
| `Channel/SetBrightness` | Set brightness (0-100) |
| `Channel/OnOffScreen` | Turn screen on/off |
| `Channel/GetClockInfo` | Get current clock info |
| `Channel/SetClockSelectId` | Select clock face by ID |
| `Channel/SetCustomPageIndex` | Set custom page index |

### Draw Commands
| Command | Description |
|---------|-------------|
| `Draw/SendHttpGif` | Send image/animation frame |
| `Draw/ResetHttpGifId` | Reset frame buffer (IMPORTANT) |
| `Draw/GetHttpGifId` | Get current frame ID |
| `Draw/SendHttpText` | Display scrolling text |
| `Draw/ClearHttpText` | Clear all text overlays |
| `Draw/SendHttpItemList` | Send display item list |
| `Draw/CommandList` | Batch multiple draw commands |

### Device Commands
| Command | Description |
|---------|-------------|
| `Device/PlayTFGif` | Play GIF from SD/URL |
| `Device/PlayBuzzer` | Activate buzzer |
| `Device/SetHighLightMode` | Enable/disable high brightness |
| `Device/SetScreenRotationAngle` | Rotate display |
| `Device/SetMirrorMode` | Mirror display |
| `Device/SetTime24Flag` | 12/24 hour format |
| `Device/SetDisTempMode` | Celsius/Fahrenheit |

### Tools Commands
| Command | Description |
|---------|-------------|
| `Tools/SetTimer` | Countdown timer |
| `Tools/SetStopWatch` | Stopwatch |
| `Tools/SetScoreBoard` | Score display |
| `Tools/SetNoiseStatus` | Noise meter |

---

## PowerShell Helper Module

Save as `Pixoo64.psm1`:

```powershell
$script:PixooUri = $null

function Connect-Pixoo {
    param([Parameter(Mandatory)][string]$IPAddress)
    $script:PixooUri = "http://$IPAddress:80/post"
    
    try {
        $response = Invoke-RestMethod -Uri $script:PixooUri -Method Post `
            -Body '{"Command":"Channel/GetAllConf"}' `
            -ContentType "application/json" -TimeoutSec 5
        
        if ($response.error_code -eq 0) {
            Write-Host "✓ Connected to Pixoo64 at $IPAddress" -ForegroundColor Green
            Write-Host "  Brightness: $($response.Brightness)%"
            return $true
        }
    }
    catch {
        Write-Host "✗ Failed to connect: $_" -ForegroundColor Red
        return $false
    }
}

function Send-PixooCommand {
    param([Parameter(Mandatory)][hashtable]$Command)
    
    if (-not $script:PixooUri) {
        throw "Not connected. Call Connect-Pixoo first."
    }
    
    $body = $Command | ConvertTo-Json -Depth 10
    return Invoke-RestMethod -Uri $script:PixooUri -Method Post -Body $body -ContentType "application/json"
}

function Set-PixooBrightness {
    param([Parameter(Mandatory)][ValidateRange(0,100)][int]$Brightness)
    Send-PixooCommand @{ Command = "Channel/SetBrightness"; Brightness = $Brightness }
}

function Send-PixooText {
    param(
        [Parameter(Mandatory)][string]$Text,
        [string]$Color = "#00FF00",
        [int]$Y = 24,
        [int]$Speed = 50,
        [int]$Font = 2,
        [int]$TextId = 1
    )
    
    Send-PixooCommand @{
        Command = "Draw/SendHttpText"
        TextId = $TextId
        x = 0
        y = $Y
        dir = 0
        font = $Font
        TextWidth = 64
        speed = $Speed
        TextString = $Text
        color = $Color
        align = 1
    }
}

function Clear-PixooText {
    Send-PixooCommand @{ Command = "Draw/ClearHttpText" }
}

function Reset-PixooDisplay {
    Send-PixooCommand @{ Command = "Draw/ResetHttpGifId" }
}

function Set-PixooSolidColor {
    param(
        [Parameter(Mandatory)][byte]$R,
        [Parameter(Mandatory)][byte]$G,
        [Parameter(Mandatory)][byte]$B
    )
    
    Reset-PixooDisplay
    
    $pixels = New-Object byte[] (64 * 64 * 3)
    for ($i = 0; $i -lt 4096; $i++) {
        $pixels[$i * 3] = $R
        $pixels[$i * 3 + 1] = $G
        $pixels[$i * 3 + 2] = $B
    }
    
    Send-PixooCommand @{
        Command = "Draw/SendHttpGif"
        PicNum = 1
        PicWidth = 64
        PicOffset = 0
        PicID = 1
        PicSpeed = 1000
        PicData = [Convert]::ToBase64String($pixels)
    }
}

function Set-PixooChannel {
    param([Parameter(Mandatory)][ValidateRange(0,3)][int]$Channel)
    Send-PixooCommand @{ Command = "Channel/SetIndex"; SelectIndex = $Channel }
}

Export-ModuleMember -Function *
```

**Usage**:
```powershell
Import-Module .\Pixoo64.psm1

Connect-Pixoo -IPAddress "192.168.0.73"
Set-PixooBrightness -Brightness 50
Send-PixooText -Text "Hello!" -Color "#FF0000"
Set-PixooSolidColor -R 0 -G 0 -B 255
Clear-PixooText
```

---

## Troubleshooting

### API Not Responding
1. Ensure device and PC are on same network/subnet
2. Open Divoom app and interact with device to "wake" it
3. Try power cycling the device
4. Check if port 80 is open: `Test-NetConnection -ComputerName <IP> -Port 80`

### Images Not Updating
1. Always call `Draw/ResetHttpGifId` before sending new images
2. Increment `PicID` for each new image sequence
3. The device caches aggressively

### Text Not Appearing
1. Make sure you're on a channel that supports overlays (Custom works best)
2. Try different Y positions (0-60)
3. Use font 2 for best compatibility

### Request Timeouts
Use explicit timeout and consider using `Invoke-WebRequest` with `-UseBasicParsing`:
```powershell
$response = Invoke-WebRequest -Uri $uri -Method Post `
    -Body $body -ContentType "application/json" `
    -TimeoutSec 10 -UseBasicParsing
```

---

## Version History

- **Guide Version**: 1.0
- **Tested Device**: Pixoo64
- **Tested Firmware**: (check with `Channel/GetAllConf`)
- **Last Updated**: 2025-01-29
