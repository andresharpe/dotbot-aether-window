# Troubleshooting Guide

This guide covers common issues when using the Pixoo64 PowerShell module and their solutions.

## Table of Contents

- [Connection Issues](#connection-issues)
- [Device Discovery Problems](#device-discovery-problems)
- [Display Issues](#display-issues)
- [Image and Animation Problems](#image-and-animation-problems)
- [Known Device Limitations](#known-device-limitations)
- [Performance Issues](#performance-issues)
- [Error Messages](#error-messages)

## Connection Issues

### "Not connected to a Pixoo device"

**Problem**: Functions throw error about missing connection.

**Solution**:
```powershell
# Ensure you're connected first
Connect-Pixoo -IPAddress "192.168.0.73"

# Or discover and connect
Find-Pixoo | Select-Object -First 1 | Connect-Pixoo

# Verify connection
Test-PixooConnection
```

### Connection Timeout

**Problem**: `Connect-Pixoo` times out or fails.

**Possible causes and solutions**:

1. **Device not on network**
   ```powershell
   # Ping the device
   Test-Connection -ComputerName 192.168.0.73 -Count 2
   ```

2. **Wrong IP address**
   ```powershell
   # Use device discovery
   Find-Pixoo -FullScan
   ```

3. **Firewall blocking port 80**
   ```powershell
   # Test port connectivity (Windows)
   Test-NetConnection -ComputerName 192.168.0.73 -Port 80
   ```

4. **Device needs "waking"**
   - Open the Divoom app and interact with the device
   - Try connecting again from PowerShell

### "Connection refused"

**Problem**: Device actively refuses connection.

**Solutions**:
- Restart the Pixoo64 device (power cycle)
- Check if another application is using the API
- Ensure device firmware is up to date
- Try factory reset (last resort)

## Device Discovery Problems

### Find-Pixoo Returns No Devices

**Problem**: `Find-Pixoo` doesn't find any devices.

**Solutions**:

1. **Try full subnet scan**
   ```powershell
   Find-Pixoo -FullScan
   ```

2. **Check cloud connectivity** (if not using `-LocalOnly`)
   - Ensure internet connection
   - Check if Divoom cloud services are operational

3. **Verify network configuration**
   - Ensure computer and Pixoo64 are on same subnet
   - Check for VPN interference
   - Verify network adapter is active

4. **Manual connection**
   ```powershell
   # Connect directly if you know the IP
   Connect-Pixoo -IPAddress "192.168.0.73"
   ```

### Discovery is Slow

**Problem**: `Find-Pixoo` takes too long.

**Solutions**:

1. **Use ARP scan (default) instead of full scan**
   ```powershell
   Find-Pixoo  # Uses ARP cache (fast)
   ```

2. **Skip cloud lookup**
   ```powershell
   Find-Pixoo -LocalOnly  # Skip cloud API
   ```

3. **Reduce timeout**
   ```powershell
   Find-Pixoo -TimeoutSec 1  # Default is 2
   ```

## Display Issues

### Text Not Displaying

**Problem**: `Send-PixooText` executes but no text appears.

**Solutions**:

1. **Check channel**
   ```powershell
   # Text may not be visible on all channels
   Set-PixooChannel -Channel Custom
   Send-PixooText -Text "Test"
   ```

2. **Clear existing text**
   ```powershell
   Clear-PixooText
   Send-PixooText -Text "New Text"
   ```

3. **Check brightness**
   ```powershell
   Set-PixooBrightness -Brightness 75
   ```

### Screen is Black

**Problem**: Display shows nothing.

**Solutions**:

1. **Check screen state**
   ```powershell
   Set-PixooScreenState -State On
   ```

2. **Check brightness**
   ```powershell
   Set-PixooBrightness -Brightness 50
   ```

3. **Reset display**
   ```powershell
   Reset-PixooDisplay
   Set-PixooSolidColor -HexColor "#FFFFFF"  # White
   ```

### Colors Look Wrong

**Problem**: Colors don't match expectations.

**Solutions**:

1. **Check color format** (hex must include #)
   ```powershell
   # Correct
   Send-PixooText -Text "Test" -Color "#FF0000"

   # Incorrect
   Send-PixooText -Text "Test" -Color "FF0000"  # Missing #
   ```

2. **RGB order** is Red-Green-Blue
   ```powershell
   Set-PixooSolidColor -Red 255 -Green 0 -Blue 0  # Red
   ```

## Image and Animation Problems

### Images Not Updating

**Problem**: `Send-PixooImage` or `Set-PixooSolidColor` doesn't update display.

**Solution**: **ALWAYS call `Reset-PixooDisplay` first**

```powershell
# Correct approach
Reset-PixooDisplay
Set-PixooSolidColor -Red 255 -Green 0 -Blue 0

# Or use AutoReset (default)
Set-PixooSolidColor -Red 255 -Green 0 -Blue 0 -AutoReset $true
```

**Why**: The Pixoo64 has a frame buffer management bug. Resetting the buffer before sending new images is a required workaround.

### Animation Fails

**Problem**: Animation doesn't play or freezes.

**Solutions**:

1. **Check frame count** (limit ~40 frames)
   ```powershell
   # If you get a warning, reduce frame count
   $frames = $frames[0..35]  # Use only first 36 frames
   Send-PixooAnimation -Frames $frames
   ```

2. **Reset before animation**
   ```powershell
   Reset-PixooDisplay
   Send-PixooAnimation -Frames $frames
   ```

3. **Increase frame delay**
   ```powershell
   # Some animations need slower timing
   Send-PixooAnimation -Frames $frames -FrameDelay 200
   ```

### "Image data wrong size" Error

**Problem**: Image data validation fails.

**Solution**: Ensure exactly 12,288 bytes (64x64x3)

```powershell
# Correct size
$imageData = [byte[]]::new(12288)

# Verify size
$imageData.Length  # Should be 12288
```

## Known Device Limitations

### ~300 Update Limit

**Problem**: Device stops responding after many rapid updates.

**Explanation**: The Pixoo64 has an undocumented limit of approximately 300 rapid updates before it becomes unresponsive.

**Solutions**:
- **Power cycle** the device (unplug and plug back in)
- **Add delays** between updates
  ```powershell
  Send-PixooImage -Base64Data $img1
  Start-Sleep -Milliseconds 500  # Delay between updates
  Send-PixooImage -Base64Data $img2
  ```
- **Batch commands** when possible
  ```powershell
  Invoke-PixooCommandBatch -Commands @($cmd1, $cmd2, $cmd3)
  ```

### ~40 Frame Animation Limit

**Problem**: Animations with >40 frames fail or freeze.

**Explanation**: Firmware limitation varies by version but generally ~40 frames max.

**Solutions**:
- **Reduce frame count**
  ```powershell
  # Subsample frames
  $reducedFrames = $allFrames | Select-Object -Index (0..39)
  ```
- **Split into multiple animations**
- **Loop shorter animations**

### Text Scrolling Direction

**Problem**: Right-scrolling text doesn't work.

**Explanation**: Most fonts only support left scrolling.

**Solution**: Use left scrolling (default)
```powershell
Send-PixooText -Text "Message" -Direction Left
```

### High Brightness Power Requirement

**Problem**: High brightness mode causes instability.

**Explanation**: Requires 5V 3A power supply.

**Solutions**:
- **Upgrade power supply** to 5V 3A
- **Disable high brightness** if using standard power
  ```powershell
  Set-PixooHighLightMode -Enabled $false
  ```
- **Lower normal brightness** instead
  ```powershell
  Set-PixooBrightness -Brightness 100  # Max without high-light mode
  ```

## Performance Issues

### Slow Command Execution

**Problem**: Commands take too long to execute.

**Solutions**:

1. **Check network latency**
   ```powershell
   Test-Connection -ComputerName 192.168.0.73
   ```

2. **Reduce retry attempts**
   ```powershell
   # Not directly exposed, but commands should be fast
   # If consistently slow, check network/device
   ```

3. **Use batch commands**
   ```powershell
   # Instead of multiple individual calls
   $commands = @(
       @{ Command = 'Draw/SendHttpText'; TextString = 'Line 1' }
       @{ Command = 'Draw/SendHttpText'; TextString = 'Line 2' }
   )
   Invoke-PixooCommandBatch -Commands $commands
   ```

### Memory Usage

**Problem**: High memory usage during animations.

**Solution**: Clear variables after use
```powershell
$frames = @($frame1, $frame2, $frame3)
Send-PixooAnimation -Frames $frames

# Clear large data
$frames = $null
[System.GC]::Collect()
```

## Error Messages

### "Device returned error code: X"

**Problem**: API returned non-zero error code.

**Solution**: Most error codes are undocumented. Common fixes:
- **Retry the command**
- **Reset device** (power cycle)
- **Check parameters** are valid
- **Update firmware** if available

### "Failed to execute command after 3 attempts"

**Problem**: Retry logic exhausted.

**Solutions**:
- **Check network connectivity**
  ```powershell
  Test-Connection -ComputerName 192.168.0.73
  ```
- **Restart device**
- **Check firewall** isn't blocking port 80
- **Try manual connection** to verify device is responsive

### "Timeout" Errors

**Problem**: Commands time out.

**Solutions**:
- **Increase timeout** (for Connect-Pixoo)
  ```powershell
  Connect-Pixoo -IPAddress 192.168.0.73 -TimeoutSec 10
  ```
- **Check network** for congestion
- **Restart device** if consistently timing out

## Getting Help

If these solutions don't resolve your issue:

1. **Check existing issues**: [GitHub Issues](https://github.com/yourusername/Pixoo/issues)
2. **Review API documentation**: [Pixoo64-REST-API-Guide.md](Pixoo64-REST-API-Guide.md)
3. **Enable verbose logging**:
   ```powershell
   $VerbosePreference = 'Continue'
   Set-PixooBrightness -Brightness 50 -Verbose
   ```
4. **File a bug report** with:
   - PowerShell version (`$PSVersionTable`)
   - Module version
   - Full error message
   - Verbose output
   - Steps to reproduce

## Quick Reference

### Device Unresponsive Checklist

- [ ] Power cycle device (unplug/plug back in)
- [ ] Verify network connectivity (`Test-Connection`)
- [ ] Try Divoom mobile app (can "wake" device)
- [ ] Check firewall (port 80)
- [ ] Update device firmware (via Divoom app)
- [ ] Factory reset (last resort)

### Image Display Checklist

- [ ] Call `Reset-PixooDisplay` first
- [ ] Verify image data size (12,288 bytes)
- [ ] Check screen is on (`Set-PixooScreenState -State On`)
- [ ] Check brightness > 0 (`Set-PixooBrightness -Brightness 50`)
- [ ] Switch to Custom channel (`Set-PixooChannel -Channel Custom`)
