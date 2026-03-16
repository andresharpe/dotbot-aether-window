# DotBot.Aether.Window

Aether **Window** conduit — Pixoo-64 LED display integration for [dotbot](https://github.com/andresharpe/dotbot). Part of the [dotbot-aether](https://github.com/andresharpe/dotbot-aether) conduit plugin collection.

[![PowerShell 7.0+](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## What It Does

Translates dotbot event bus events into Pixoo-64 display output — task names, status icons, animations, dashboards, and clock faces. Supports device discovery (cloud API, ARP, subnet scan), text/image/animation display, GIF URLs, tools (timer, stopwatch, scoreboard, buzzer), and batch commands.

## Quick Start

```powershell
Import-Module ./src/DotBot.Aether.Window/DotBot.Aether.Window.psd1

# Discover and connect
Find-AetherWindow | Connect-AetherWindow

# Or use the native Pixoo functions directly
Find-Pixoo | Connect-Pixoo
Send-PixooText -Text "Hello from dotbot!" -Color "#00FF00"
Set-PixooBrightness -Brightness 75
```

## Aether Contract Functions

Every Aether conduit exports these standard lifecycle functions:

- `Initialize-AetherWindow` — validate config and hardware reachability
- `Find-AetherWindow` — discover Pixoo devices on the network
- `Connect-AetherWindow` — bond to a discovered device
- `Disconnect-AetherWindow` — clean shutdown
- `Test-AetherWindow` — health check
- `Invoke-AetherWindowEvent` — handle an event bus event (the sink entry point)

## Native Functions (36)

### Connection & Discovery
`Find-Pixoo`, `Connect-Pixoo`, `Disconnect-Pixoo`, `Test-PixooConnection`, `Get-PixooConfiguration`

### Display Settings
`Set-PixooBrightness`, `Get-PixooChannel`, `Set-PixooChannel`, `Set-PixooScreenState`, `Set-PixooClockFace`, `Get-PixooClockInfo`

### Drawing & Display
`Send-PixooText`, `Clear-PixooText`, `Send-PixooImage`, `Send-PixooAnimation`, `Reset-PixooDisplay`, `Set-PixooSolidColor`, `Get-PixooGifId`, `Send-PixooGifUrl`, `Invoke-PixooCommandBatch`, `Invoke-PixooRemoteCommands`

### Tools
`Start-PixooTimer`, `Start-PixooStopwatch`, `Set-PixooScoreboard`, `Start-PixooBuzzer`, `Set-PixooNoiseMeter`

### Device Settings
`Set-PixooRotation`, `Set-PixooMirrorMode`, `Set-PixooTimeFormat`, `Set-PixooTemperatureUnit`, `Set-PixooHighLightMode`, `Set-PixooCustomPageIndex`, `Set-PixooTime`, `Set-PixooTimeZone`, `Set-PixooLocation`, `Set-PixooWhiteBalance`

## Documentation

- [Pixoo-64 REST API Guide](docs/Pixoo64-REST-API-Guide.md)
- [Discovery Implementation Spec](docs/Pixoo64-Discovery-Implementation-Spec.md)
- [Local API Spec](docs/pixoo64-local-api-spec.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Contributing](docs/CONTRIBUTING.md)
- [Changelog](docs/CHANGELOG.md)

## Testing

```powershell
Invoke-Pester ./tests/Unit
Invoke-Pester ./tests/Integration  # requires Pixoo-64 device
```

## License

MIT — see [LICENSE](LICENSE)