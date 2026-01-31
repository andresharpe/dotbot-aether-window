# Pixoo64 PowerShell Module

A comprehensive PowerShell module for controlling the Divoom Pixoo64 LED display via its REST API.

[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Features

- **Complete API Coverage** - All 31 documented endpoints supported
- **Device Discovery** - Cloud, ARP cache, and full subnet scanning
- **Pipeline Support** - Seamless integration with PowerShell pipelines
- **Comprehensive Error Handling** - Automatic retry logic with exponential backoff
- **Well-Tested** - 80%+ code coverage with unit and integration tests
- **Cross-Platform** - PowerShell 5.1+ (Windows) and PowerShell 7+ (Windows/Linux/macOS)

## Quick Start

### Installation

```powershell
# Clone the repository
git clone https://github.com/yourusername/Pixoo.git

# Import the module
Import-Module .\Pixoo\src\Pixoo64\Pixoo64.psd1
```

### Basic Usage

```powershell
# Discover devices on your network
$devices = Find-Pixoo
$devices | Format-Table Name, IP, DeviceId

# Connect to a device (pipeline supported!)
$devices | Select-Object -First 1 | Connect-Pixoo

# Display some text
Send-PixooText -Text "Hello from PowerShell!" -Color "#00FF00"

# Set brightness
Set-PixooBrightness -Brightness 75

# Show a solid color
Set-PixooSolidColor -HexColor "#FF0000"

# Disconnect when done
Disconnect-Pixoo
```

## Functions Overview

The module provides **31 public functions** organized into six categories:

### Connection & Discovery (5 functions)
- `Find-Pixoo` - Discover devices (cloud + ARP + full scan)
- `Connect-Pixoo` - Establish connection
- `Disconnect-Pixoo` - Close connection
- `Test-PixooConnection` - Verify connectivity
- `Get-PixooConfiguration` - Get all device settings

### Display Settings (6 functions)
- `Set-PixooBrightness` - Adjust brightness (0-100)
- `Get-PixooChannel` - Get current channel
- `Set-PixooChannel` - Switch channels (Faces/Cloud/Visualizer/Custom)
- `Set-PixooScreenState` - Turn screen on/off
- `Set-PixooClockFace` - Select clock face by ID
- `Get-PixooClockInfo` - Get clock face details

### Drawing & Display (8 functions)
- `Send-PixooText` - Display scrolling text
- `Clear-PixooText` - Clear text overlays
- `Send-PixooImage` - Send static image
- `Send-PixooAnimation` - Send multi-frame animation
- `Reset-PixooDisplay` - Reset frame buffer (critical before images!)
- `Set-PixooSolidColor` - Fill with solid RGB color
- `Get-PixooGifId` - Get current GIF frame ID
- `Send-PixooGifUrl` - Play GIF from URL or SD card

### Batch Commands (1 function)
- `Invoke-PixooCommandBatch` - Send multiple commands efficiently

### Tools (5 functions)
- `Start-PixooTimer` - Countdown timer
- `Start-PixooStopwatch` - Control stopwatch
- `Set-PixooScoreboard` - Red vs Blue scoreboard
- `Start-PixooBuzzer` - Activate buzzer
- `Set-PixooNoiseMeter` - Audio visualizer

### Device Settings (6 functions)
- `Set-PixooRotation` - Set rotation angle (0/90/180/270)
- `Set-PixooMirrorMode` - Enable/disable mirror mode
- `Set-PixooTimeFormat` - Set 12/24 hour format
- `Set-PixooTemperatureUnit` - Set Celsius/Fahrenheit
- `Set-PixooHighLightMode` - Enable high brightness (requires 5V3A)
- `Set-PixooCustomPageIndex` - Set custom channel page

## Examples

See the [`examples/`](examples/) directory for comprehensive examples:

- **[01-GettingStarted.ps1](examples/01-GettingStarted.ps1)** - Device discovery and connection
- **[02-DisplayingText.ps1](examples/02-DisplayingText.ps1)** - Text display with various options
- **[03-ShowingImages.ps1](examples/03-ShowingImages.ps1)** - Solid colors and image display
- **[04-CreatingAnimations.ps1](examples/04-CreatingAnimations.ps1)** - Frame-by-frame animations
- **[05-UsingTools.ps1](examples/05-UsingTools.ps1)** - Timer, stopwatch, scoreboard, buzzer

## Documentation

- **[API Reference](docs/Pixoo64-REST-API-Guide.md)** - Complete Pixoo64 REST API documentation
- **[Discovery Specification](docs/Pixoo64-Discovery-Implementation-Spec.md)** - Device discovery details
- **[Examples README](examples/README.md)** - How to use example scripts
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Contributing Guide](docs/CONTRIBUTING.md)** - How to contribute

### Function Help

Every function has comprehensive comment-based help:

```powershell
Get-Help Find-Pixoo -Full
Get-Help Send-PixooText -Examples
Get-Help Set-PixooBrightness -Parameter Brightness
```

## Requirements

- **PowerShell**: Version 5.1 or later (Windows), or PowerShell 7+ (cross-platform)
- **Network**: Pixoo64 device on same network as your computer
- **Permissions**: Firewall access to port 80 on device IP

## Key Features Explained

### Device Discovery

Find-Pixoo uses a three-stage discovery process:

1. **Cloud API** - Queries Divoom's cloud service (skip with `-LocalOnly`)
2. **IP Candidates** - ARP cache scan (default) or full subnet scan (`-FullScan`)
3. **Parallel Probing** - Tests IPs concurrently for fast results

```powershell
# Fast discovery (ARP cache)
Find-Pixoo

# Thorough discovery (full subnet scan)
Find-Pixoo -FullScan

# Local only (skip cloud)
Find-Pixoo -LocalOnly
```

### Pipeline Support

The module supports PowerShell pipelines for natural workflows:

```powershell
# Discover and connect in one line
Find-Pixoo | Select-Object -First 1 | Connect-Pixoo

# Send multiple text messages
"Line 1", "Line 2", "Line 3" | Send-PixooText -Color "#00FF00"
```

### Error Handling

Automatic retry logic for transient failures:
- **Retries** timeout, connection refused, 5xx errors
- **Does NOT retry** 4xx errors, API errors, JSON parse errors
- **Exponential backoff** 1s, 2s, 4s between retries

## Known Limitations

The Pixoo64 device has some quirks (not module bugs):

1. **Buffer Reset Required** - Always call `Reset-PixooDisplay` before sending new images
2. **~300 Update Limit** - Device stops responding after ~300 rapid updates (needs power cycle)
3. **~40 Frame Maximum** - Animations limited to ~40 frames (varies by firmware)
4. **Text Scrolling** - Most fonts only support left scrolling
5. **High Brightness** - Requires 5V 3A power supply

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for details and workarounds.

## Testing

### Run Unit Tests

```powershell
# All unit tests
Invoke-Pester -Path .\tests\Unit\

# With code coverage
Invoke-Pester -Path .\tests\ -CodeCoverage .\src\**\*.ps1
```

### Run Integration Tests

```powershell
# Set your device IP
$env:PIXOO_TEST_IP = "192.168.0.73"

# Run integration tests
Invoke-Pester -Path .\tests\Integration\
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on the Divoom Pixoo64 REST API
- Community reverse-engineering efforts
- PowerShell community best practices

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/Pixoo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/Pixoo/discussions)
- **Documentation**: [docs/](docs/) directory

---

**Made with ❤️ for the PowerShell and Pixoo64 communities**
