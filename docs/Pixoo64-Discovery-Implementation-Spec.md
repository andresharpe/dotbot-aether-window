# Pixoo64 Device Discovery - Implementation Spec

## Overview

Build a PowerShell function that discovers Divoom Pixoo devices on the local network using a combined cloud + local approach for maximum reliability.

---

## Function Signature

```powershell
function Find-Pixoo {
    [CmdletBinding()]
    param(
        [switch]$LocalOnly,      # Skip cloud lookup
        [switch]$FullScan,       # Scan entire subnet, not just ARP cache
        [int]$TimeoutSec = 2     # Per-device timeout
    )
}
```

---

## Discovery Strategy

Execute in this order, accumulating results:

### Step 1: Cloud Lookup

Skip if `-LocalOnly` is specified.

| Property | Value |
|----------|-------|
| Method | POST |
| URL | `https://app.divoom-gz.com/Device/ReturnSameLANDevice` |
| Body | None |
| Timeout | 5 seconds |

**Response Format:**
```json
{
  "ReturnCode": 0,
  "ReturnMessage": "",
  "DeviceList": [
    {
      "DeviceName": "Pixoo64",
      "DeviceId": 300000001,
      "DevicePrivateIP": "192.168.0.73"
    }
  ]
}
```

**Behaviour:**
- On success: add each device to results with `Source = "Cloud"`
- On failure: log warning, continue to local discovery

---

### Step 2: Build IP Candidate List

Determine which IPs to probe based on flags:

| Condition | IPs to Probe |
|-----------|--------------|
| `-FullScan` | Entire /24 subnet (x.x.x.1-254) |
| Default | ARP cache entries only |

**Get Current Subnet:**
```powershell
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { $_.PrefixOrigin -in 'Dhcp','Manual' -and $_.AddressState -eq 'Preferred' } | 
    Select-Object -First 1).IPAddress

$subnet = $localIP -replace '\.\d+$', ''  # e.g., "192.168.0"
```

**Get ARP Cache:**
```powershell
$arpIPs = (Get-NetNeighbor -AddressFamily IPv4 | 
    Where-Object { $_.State -in 'Reachable','Stale','Permanent' }).IPAddress
```

**Merge with Cloud Results:**
- Always verify cloud-reported IPs
- Deduplicate before probing

---

### Step 3: Probe Each IP

For each candidate IP, test if it's a Pixoo device.

| Property | Value |
|----------|-------|
| Method | POST |
| URL | `http://<ip>:80/post` |
| Body | `{"Command":"Channel/GetAllConf"}` |
| Content-Type | `application/json` |
| Timeout | Value of `$TimeoutSec` parameter |

**Success Criteria:**
- HTTP 200 response
- JSON contains `"error_code": 0`

**Extract from Response:**
| Field | Type | Description |
|-------|------|-------------|
| `Brightness` | int | Current brightness 0-100 |
| `LightSwitch` | int | 1 = screen on, 0 = off |
| `CurClockId` | int | Active clock face ID |
| `RotationFlag` | int | Display rotation |

---

## Output Object Schema

Return an array of objects with this structure:

```powershell
[PSCustomObject]@{
    Name       = [string]    # "Pixoo64" or device name from cloud
    IP         = [string]    # Device IP address
    DeviceId   = [int]       # Cloud device ID, or $null if local-only
    Brightness = [int]       # 0-100
    ScreenOn   = [bool]      # True if LightSwitch -eq 1
    Source     = [string]    # "Cloud", "ARP", or "Scan"
    Verified   = [bool]      # True if API responded successfully
}
```

---

## Parallel Execution

For `-FullScan`, use parallel jobs to scan subnet quickly.

**PowerShell 7+:**
```powershell
$jobs = $ipList | ForEach-Object {
    Start-ThreadJob -ScriptBlock { param($ip) <# probe logic #> } -ArgumentList $_ -ThrottleLimit 50
}
$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job
```

**PowerShell 5.1 Fallback:**
```powershell
$runspacePool = [runspacefactory]::CreateRunspacePool(1, 50)
$runspacePool.Open()
# Use runspaces for parallel execution
```

**Performance Target:**
- Full /24 scan: < 20 seconds
- ARP-only scan: < 5 seconds

---

## Console Output

Use colored output for user feedback:

| Color | Usage |
|-------|-------|
| Cyan | Status messages, headings |
| Green | Device found |
| DarkGreen | Device verified |
| Yellow | Warnings (cloud failed, etc.) |
| Red | Errors |

**Example Output:**
```
Checking Divoom cloud service...
  ✓ Cloud found: Pixoo64 at 192.168.0.73
Verifying local connectivity...
  ✓ Verified: 192.168.0.73
  ✓ Local found: 192.168.0.150

Found 2 Pixoo device(s):

Name    IP             DeviceId  Brightness ScreenOn Source Verified
----    --             --------  ---------- -------- ------ --------
Pixoo64 192.168.0.73   300000001         75     True  Cloud     True
Pixoo   192.168.0.150                    50     True    ARP     True
```

---

## Error Handling

| Scenario | Behaviour |
|----------|-----------|
| Cloud timeout | Log warning, continue to local |
| Cloud returns empty list | Continue to local |
| Device probe timeout | Skip silently, don't add to results |
| Device probe error | Skip silently |
| No devices found | Return empty array, display message |
| Invalid subnet detection | Fall back to common subnets or prompt user |

---

## Edge Cases

1. **Multiple network adapters**: Pick the first DHCP/Manual IPv4 address that's preferred
2. **VPN active**: May return wrong subnet; consider allowing `-Subnet` parameter override
3. **Device powered off**: Won't respond to probe; cloud may still report it
4. **Device on different subnet**: Won't be found via local scan; cloud will find it if on same LAN

---

## Optional Enhancements

### Progress Indicator
For full scan, show progress:
```powershell
Write-Progress -Activity "Scanning subnet" -PercentComplete (($i / 254) * 100)
```

### Subnet Parameter
Allow manual override:
```powershell
param(
    [string]$Subnet  # e.g., "192.168.1" or "10.0.0"
)
```

### Output Formatting
Add a default table format:
```powershell
Update-FormatData -PrependPath Pixoo.Format.ps1xml
```

---

## Testing Checklist

- [ ] Cloud lookup succeeds with internet
- [ ] Cloud lookup gracefully fails without internet
- [ ] `-LocalOnly` skips cloud entirely
- [ ] ARP scan finds device that was recently contacted
- [ ] `-FullScan` finds device not in ARP cache
- [ ] Multiple devices are all returned
- [ ] Timeout is respected per-device
- [ ] Non-Pixoo devices on port 80 are ignored
- [ ] Empty result returns empty array, not error
- [ ] Output objects have correct schema

---

## Example Usage

```powershell
# Quick discovery (cloud + ARP)
$devices = Find-Pixoo

# Local only, no cloud
$devices = Find-Pixoo -LocalOnly

# Full subnet scan
$devices = Find-Pixoo -FullScan

# Use first found device
$pixoo = (Find-Pixoo)[0]
$uri = "http://$($pixoo.IP):80/post"

# Pipe to other commands
Find-Pixoo | Where-Object { $_.ScreenOn } | ForEach-Object {
    # Do something with each online device
}
```
