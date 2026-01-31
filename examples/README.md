# Pixoo64 PowerShell Module Examples

This directory contains example scripts demonstrating various features of the Pixoo64 PowerShell module.

## Prerequisites

1. **Import the module** before running examples:
   ```powershell
   Import-Module ..\src\Pixoo64\Pixoo64.psd1
   ```

2. **Ensure your Pixoo64 is on the network** and accessible from your computer.

3. **Update IP addresses** if needed - most examples use `Find-Pixoo` for automatic discovery.

## Examples

### 01-GettingStarted.ps1
**Basic device discovery, connection, and configuration**
- Discover devices using Find-Pixoo
- Connect to a device
- Get device configuration
- Test connection status
- Disconnect properly

```powershell
.\01-GettingStarted.ps1
```

### 02-DisplayingText.ps1
**Text display with various options**
- Basic text display
- Colored text
- Custom positioning
- Scroll speed control
- Multiple text overlays
- Pipeline input

```powershell
.\02-DisplayingText.ps1
```

### 03-ShowingImages.ps1
**Solid colors and image display**
- Solid color fills (RGB and hex)
- Rainbow gradient effect
- Custom image data
- Checkerboard pattern example

```powershell
.\03-ShowingImages.ps1
```

### 04-CreatingAnimations.ps1
**Frame-by-frame animations**
- Color fade animation
- Moving dot animation
- Frame generation techniques
- Animation timing

```powershell
.\04-CreatingAnimations.ps1
```

### 05-UsingTools.ps1
**Timer, stopwatch, scoreboard, and buzzer**
- Countdown timer
- Stopwatch control
- Scoreboard updates
- Buzzer patterns
- Noise meter (audio visualizer)

```powershell
.\05-UsingTools.ps1
```

## Running Examples

Navigate to the examples directory and run any script:

```powershell
cd examples
.\01-GettingStarted.ps1
```

Or run from the repository root:

```powershell
.\examples\01-GettingStarted.ps1
```

## Tips

- **Use Find-Pixoo for discovery**: Most examples use automatic device discovery
- **Check connections**: Always ensure device is connected before sending commands
- **Disconnect when done**: Examples disconnect automatically, but you can keep connections open for interactive sessions
- **Experiment**: Modify examples to learn more about the API

## Interactive Usage

For interactive exploration, import the module and connect manually:

```powershell
# Import module
Import-Module .\src\Pixoo64\Pixoo64.psd1

# Discover and connect
$device = Find-Pixoo | Select-Object -First 1
Connect-Pixoo -IPAddress $device.IP

# Try commands
Set-PixooBrightness -Brightness 50
Send-PixooText -Text "Hello!"
Set-PixooSolidColor -HexColor "#FF0000"

# Disconnect when done
Disconnect-Pixoo
```

## Troubleshooting

If examples don't work:

1. **Verify device is on network**: Try pinging the device IP
2. **Use full scan**: `Find-Pixoo -FullScan` for more thorough discovery
3. **Manual connection**: Connect directly with `Connect-Pixoo -IPAddress 192.168.x.x`
4. **Check firewall**: Ensure port 80 is accessible
5. **See troubleshooting guide**: Check `docs/TROUBLESHOOTING.md`

## Learn More

- Full API reference: `docs/Pixoo64-REST-API-Guide.md`
- Function help: `Get-Help <Function-Name> -Full`
- Module commands: `Get-Command -Module Pixoo64`
