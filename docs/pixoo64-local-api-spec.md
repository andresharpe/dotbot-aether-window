# Pixoo64 Local HTTP API (Unofficial Community Spec)

**Document status:** community-compiled / best-effort  
**Last updated:** 2026-01-29  
**Device:** Divoom Pixoo 64 (Pixoo64)  

> This document describes the Pixoo64’s **local** (LAN) HTTP API exposed by the device itself (typically at `http://<pixoo-ip>/post`).  
> It is compiled from publicly accessible community references and SDK implementations, because the official doc site is not reliably accessible in all environments and Divoom’s help center notes the API is still being tested.  
>
> **No warranty:** payloads can vary by firmware/device model. Test carefully and rate-limit requests to avoid device reboots.

---

## Table of contents

1. [Transport and endpoints](#transport-and-endpoints)  
2. [Common request/response conventions](#common-requestresponse-conventions)  
3. [Command reference](#command-reference)  
   1. [Channel commands](#channel-commands)  
   2. [System and device commands](#system-and-device-commands)  
   3. [Tools commands](#tools-commands)  
   4. [Animation and drawing commands](#animation-and-drawing-commands)  
   5. [Batch commands](#batch-commands)  
4. [Notes, quirks, and safety](#notes-quirks-and-safety)  
5. [References](#references)

---

## Transport and endpoints

### Base URL

- The device runs an HTTP server on the LAN, typically reachable at:

```
http://<PIXOO_IP>/
```

### Endpoints

#### `GET /get` (health check)

Commonly used by community scripts to verify the target is a Pixoo device.

- Example: request `http://<PIXOO_IP>/get`
- Expected body (substring match):
  - `"Hello World divoom!"`

> Some implementations only use this as a heuristic check and don’t parse a formal JSON response.

#### `POST /post` (command execution)

Primary endpoint for all device control commands.

- URL: `http://<PIXOO_IP>/post`
- Method: `POST`
- Body: JSON
- Recommended headers:
  - `Content-Type: application/json; charset=utf-8`

---

## Common request/response conventions

### Request envelope

All commands are sent as a single JSON object containing:

- `Command` (string, required): `"Namespace/Action"`  
- Additional fields depend on the command.

Example:

```json
{
  "Command": "Channel/GetIndex"
}
```

### Response conventions

Many commands return JSON with:

- `error_code` (number): `0` typically means success.
- Additional fields depend on the command.

Example response for `Channel/GetIndex`:

```json
{
  "error_code": 0,
  "SelectIndex": 3
}
```

> Some community code treats a missing `error_code` as “maybe OK” if expected fields exist, but you should prefer checking `error_code == 0` when present.

### Channel index meanings

Where `SelectIndex` is used (get/set channel), community references map:

- `0` = Faces / Clock  
- `1` = Cloud Channel  
- `2` = Visualizer  
- `3` = Custom

---

## Command reference

### Channel commands

#### `Channel/GetIndex`

Get the currently selected top-level channel.

**Request**

```json
{ "Command": "Channel/GetIndex" }
```

**Response**

```json
{ "error_code": 0, "SelectIndex": 3 }
```

---

#### `Channel/SetIndex`

Select a top-level channel.

**Request**

```json
{ "Command": "Channel/SetIndex", "SelectIndex": 3 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `SelectIndex` | integer | ✅ | 0..3 (see [Channel index meanings](#channel-index-meanings)) |

**Response**

```json
{ "error_code": 0 }
```

---

#### `Channel/OnOffScreen`

Turn the display panel on or off.

**Request**

```json
{ "Command": "Channel/OnOffScreen", "OnOff": 1 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `OnOff` | integer | ✅ | 1 = on, 0 = off |

**Response**

```json
{ "error_code": 0 }
```

---

#### `Channel/SetBrightness`

Set screen brightness.

**Request**

```json
{ "Command": "Channel/SetBrightness", "Brightness": 30 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `Brightness` | integer | ✅ | Typically 0..100 |

**Response**

```json
{ "error_code": 0 }
```

---

#### `Channel/GetAllConf`

Get the device’s current configuration (brightness, rotation flags, timers, etc.).

**Request**

```json
{ "Command": "Channel/GetAllConf" }
```

**Response (example fields)**

```json
{
  "error_code": 0,
  "Brightness": 100,
  "RotationFlag": 1,
  "ClockTime": 60,
  "GalleryTime": 60,
  "SingleGalleyTime": 5,
  "PowerOnChannelId": 1,
  "GalleryShowTimeFlag": 1,
  "CurClockId": 1,
  "Time24Flag": 1,
  "TemperatureMode": 1,
  "GyrateAngle": 1,
  "MirrorFlag": 1,
  "LightSwitch": 1
}
```

> Field availability can vary by device/firmware.

---

#### `Channel/SetCustomPageIndex`

Select a custom page (within the Custom channel).

**Request**

```json
{ "Command": "Channel/SetCustomPageIndex", "SelectIndex": 0 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `SelectIndex` | integer | ✅ | Custom page index (device-specific range) |

**Response**

```json
{ "error_code": 0 }
```

---

#### `Channel/SetClockSelectId`

Select a clock “face” (dial) while in Faces/Clock channel.

**Request**

```json
{ "Command": "Channel/SetClockSelectId", "ClockId": 12 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `ClockId` | integer | ✅ | Clock/dial ID |

**Response**

```json
{ "error_code": 0 }
```

---

#### `Channel/GetClockInfo`

Get the selected clock info.

**Request**

```json
{ "Command": "Channel/GetClockInfo" }
```

**Response (example)**

```json
{ "ClockId": 12, "Brightness": 100 }
```

> Some responses may also include `error_code` depending on firmware.

---

### System and device commands

#### `Device/SetUTC`

Set the device’s system time using Unix epoch seconds (UTC).

**Request**

```json
{ "Command": "Device/SetUTC", "Utc": 1672416000 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `Utc` | integer | ✅ | Unix time (seconds) |

**Response**

```json
{ "error_code": 0 }
```

---

#### `Device/SetHighLightMode`

Set “highlight mode” (exact semantics vary).

**Request (example)**

```json
{ "Command": "Device/SetHighLightMode", "Mode": 0 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `Mode` | integer | ✅ | Enum; commonly 0/1 (device-specific) |

---

#### `Device/SetTime24Flag`

Set 12h vs 24h time display.

**Request (example)**

```json
{ "Command": "Device/SetTime24Flag", "Mode": 0 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `Mode` | integer | ✅ | Often 0 = 12h, 1 = 24h (verify on device) |

---

#### `Device/SetMirrorMode`

Mirror screen output.

**Request (example)**

```json
{ "Command": "Device/SetMirrorMode", "Mode": 0 }
```

---

#### `Device/SetScreenRotationAngle`

Rotate screen.

**Request (example)**

```json
{ "Command": "Device/SetScreenRotationAngle", "Mode": 0 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `Mode` | integer | ✅ | Enum; commonly 0..3 for 0/90/180/270 (verify on device) |

---

#### `Device/SetDisTempMode`

Set temperature unit display.

**Request (example)**

```json
{ "Command": "Device/SetDisTempMode", "Mode": 0 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `Mode` | integer | ✅ | Enum; commonly Celsius/Fahrenheit (verify on device) |

---

#### `Sys/TimeZone`

Set the device’s time zone.

**Request (example)**

```json
{ "Command": "Sys/TimeZone", "TimeZoneValue": "GMT-5" }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `TimeZoneValue` | string | ✅ | Examples: `"UTC"`, `"GMT-5"` (device-specific accepted formats) |

---

#### `Sys/LogAndLat`

Set the device’s weather location coordinates.

**Request (example)**

```json
{ "Command": "Sys/LogAndLat", "Longitude": "30.29", "Latitude": "20.58" }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `Longitude` | string | ✅ | String numeric |
| `Latitude` | string | ✅ | String numeric |

---

#### `Device/SetWhiteBalance`

Set white balance values.

**Request (example)**

```json
{
  "Command": "Device/SetWhiteBalance",
  "RValue": 100,
  "GValue": 100,
  "BValue": 100
}
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `RValue` | integer | ✅ | 0..255 or 0..100 (varies) |
| `GValue` | integer | ✅ | 0..255 or 0..100 (varies) |
| `BValue` | integer | ✅ | 0..255 or 0..100 (varies) |

---

> **Note:** A “Get device time” command exists in SDKs with a response containing `UTCTime` and `LocalTime`, but the **exact request payload** is not consistently shown in the accessible sources used to compile this document. See [References](#references) for the SDK that documents the response shape.

---

### Tools commands

#### `Tools/SetTimer` (countdown tool)

**Request (example)**

```json
{ "Command": "Tools/SetTimer", "Minute": 1, "Second": 0, "Status": 1 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `Minute` | integer | ✅ | 0..59 (typical) |
| `Second` | integer | ✅ | 0..59 (typical) |
| `Status` | integer | ✅ | Often 0 = stop/reset, 1 = start (verify) |

---

#### `Tools/SetNoiseStatus` (noise tool)

**Request (example)**

```json
{ "Command": "Tools/SetNoiseStatus", "NoiseStatus": 1 }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `NoiseStatus` | integer | ✅ | Often 0/1 |

---

#### `Tools/SetScoreBoard` (scoreboard tool)

**Request (example)**

```json
{ "Command": "Tools/SetScoreBoard", "BlueScore": 100, "RedScore": 79 }
```

---

#### `Tools/SetStopWatch` (stopwatch tool)

**Request (example)**

```json
{ "Command": "Tools/SetStopWatch", "Status": 1 }
```

---

### Animation and drawing commands

#### `Device/PlayTFGif` (play GIF from file/folder/URL)

Play a GIF from:

- a file on device storage,
- a folder on device storage,
- or a remote URL.

**Requests (examples)**

```json
{ "Command": "Device/PlayTFGif", "FileType": 0, "FileName": "divoom_gif/1.gif" }
```

```json
{ "Command": "Device/PlayTFGif", "FileType": 1, "FileName": "divoom_gif" }
```

```json
{ "Command": "Device/PlayTFGif", "FileType": 2, "FileName": "http://example.com/64_64.gif" }
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `FileType` | integer | ✅ | 0 = file, 1 = folder, 2 = URL |
| `FileName` | string | ✅ | Path or URL |

**Important constraints**

- Community SDK notes that this API only supports **16×16, 32×32, and 64×64 GIFs**, and other formats can cause a crash/reboot.
- Community scripts report **HTTPS URLs may not be supported** for `FileType=2` (use `http://`).

---

#### `Draw/GetHttpGifId` (get next animation id)

Fetch the next/available animation ID used for `PicID` in `Draw/SendHttpGif`.

**Request**

```json
{ "Command": "Draw/GetHttpGifId" }
```

**Response (example)**

```json
{ "error_code": 0, "PicId": 3 }
```

---

#### `Draw/ResetHttpGifId` (reset animation id counter)

**Request**

```json
{ "Command": "Draw/ResetHttpGifId" }
```

**Response**

```json
{ "error_code": 0 }
```

---

#### `Draw/SendHttpGif` (send image animation frames)

Send raw frame data as base64 (or base64-like) encoded data to render/play on the device.

**Request (example)**

```json
{
  "Command": "Draw/SendHttpGif",
  "PicNum": 2,
  "PicWidth": 64,
  "PicOffset": 0,
  "PicID": 3,
  "PicSpeed": 100,
  "PicData": "AAIpAAIp..."
}
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `PicNum` | integer | ✅ | Number of frames in this animation (often repeated per chunk) |
| `PicWidth` | integer | ✅ | Canvas width (Pixoo64 = 64) |
| `PicOffset` | integer | ✅ | Offset/chunk index; **first frame must use 0** |
| `PicID` | integer | ✅ | Animation ID, usually from `Draw/GetHttpGifId` |
| `PicSpeed` | integer | ✅ | Frame duration or speed (ms-like), device-specific |
| `PicData` | string | ✅ | Encoded image payload |

**Notes**

- Community SDK notes: the *first* request must have `PicOffset = 0` to create the image “slot”; otherwise later requests may fail.

---

#### `Draw/SendHttpText` (send text overlay/animation)

Send a text animation overlay. This generally only works when the device is in a drawing mode displaying animations.

**Request (example)**

```json
{
  "Command": "Draw/SendHttpText",
  "TextId": 4,
  "x": 0,
  "y": 40,
  "dir": 0,
  "font": 4,
  "TextWidth": 56,
  "speed": 10,
  "TextString": "hello, Divoom",
  "color": "#FFFF00",
  "align": 1
}
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `TextId` | integer | ✅ | Identifier for text area |
| `x` | integer | ✅ | X position |
| `y` | integer | ✅ | Y position |
| `dir` | integer | ✅ | Direction enum (device-specific) |
| `font` | integer | ✅ | Font index |
| `TextWidth` | integer | ✅ | Pixel width |
| `speed` | integer | ✅ | Scroll speed |
| `TextString` | string | ✅ | Text content |
| `color` | string | ✅ | Hex color string like `#RRGGBB` |
| `align` | integer | ✅ | Alignment enum (device-specific) |

**Important constraint**

- SDK docs note text animations may be ignored unless the device is currently in drawing mode (e.g., showing an image animation).

---

#### Clear all text area

A “clear all text area” command exists in SDKs (official doc page referenced as `page_id=232`), but accessible references used here do not consistently show the exact JSON request. Some implementations use `Draw/ClearHttpText`.

If your device supports it, you can try:

```json
{ "Command": "Draw/ClearHttpText" }
```

Treat this as **experimental** unless you confirm on your device.

---

#### Play buzzer

Two different command names appear in community sources:

- `Device/PlayBuzzer` (seen in Home Assistant configurations)
- A “Play buzzer” section in one SDK shows a request using `Command: "Device/PlayTFGif"` (very likely a documentation/library mistake)

**Recommended (commonly working) request**

```json
{
  "Command": "Device/PlayBuzzer",
  "ActiveTimeInCycle": 500,
  "OffTimeInCycle": 500,
  "PlayTotalTime": 3000
}
```

**Parameters**

| Field | Type | Required | Notes |
|---|---:|:---:|---|
| `ActiveTimeInCycle` | integer | ✅ | ms-like; device struggles with too-small values |
| `OffTimeInCycle` | integer | ✅ | ms-like |
| `PlayTotalTime` | integer | ✅ | Total duration |

**Timing notes (from SDK docs)**

- Buzz is ~50ms and device can’t handle requests `<100ms` well.
- Too-small `ActiveTimeInCycle` / `OffTimeInCycle` may lead to no audible result.

---

### Batch commands

#### `Draw/UseHTTPCommandSource` (execute commands from URL)

Execute a list of commands hosted as a text file on an HTTP endpoint.

**Request (example)**

```json
{
  "Command": "Draw/UseHTTPCommandSource",
  "CommandUrl": "http://f.divoom-gz.com/all_command.txt"
}
```

**Parameters**

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `CommandUrl` | string | ✅ | Must be reachable by the device (often HTTP) |

---

#### “Batching commands in one request” (SDK feature)

Some SDKs support batching multiple commands client-side and sending them as one request. However, the **exact on-device JSON schema** for the multi-command payload is not consistently visible in the accessible sources used to compile this document.

If you need batching, consider using an existing gateway/tooling layer (e.g., a Pixoo REST gateway) or inspect traffic from known libraries.

---

## Notes, quirks, and safety

- **API maturity:** Divoom’s own help center indicates the API is “still in testing” and may change.  
- **Device reboots:** Some community code notes the device may reboot when certain commands are sent, especially unstable GIF playback or invalid payloads.  
- **GIF playback:** Only send 16×16, 32×32, or 64×64 GIFs to `Device/PlayTFGif` to reduce crash risk.  
- **URL playback:** Prefer `http://` URLs; some implementations report `https://` is unsupported for the device URL playback API.  
- **Rate limiting:** Avoid rapid-fire requests; introduce delays and retry logic.  
- **LAN security:** There is typically no authentication; keep the device on a trusted network/VLAN.

---

## References

These are the primary public references used to compile this document (URLs provided verbatim for convenience):

- Divoom help center (REST API overview / testing notice):  
  `https://divoom.helpscoutdocs.com/article/404-divoom-rest-api`

- Rust SDK / docs (PixooCommandBuilder examples and request/response snippets):  
  `https://docs.rs/divoom/latest/divoom/struct.PixooCommandBuilder.html`

- Rust crate README showing `Channel/GetIndex` response example:  
  `https://docs.rs/crate/divoom/latest/source/README.md`

- Home Assistant Pixoo64 YAML gist (lists several commands with payloads):  
  `https://gist.github.com/kmplngj/bc6352d954a722b6ad95c1c165125ed7`

- PowerShell Pixoo64 control script (shows `/get` probe and several command payloads):  
  `https://gist.github.com/quonic/72604443b2385a02e7880b86d7900bc5`
