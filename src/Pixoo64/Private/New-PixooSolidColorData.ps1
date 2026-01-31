function New-PixooSolidColorData {
    <#
    .SYNOPSIS
        Generates RGB byte array for solid color display.

    .DESCRIPTION
        Creates a 12,288-byte array (64x64x3) filled with the specified RGB color,
        then returns it as a Base64-encoded string for use with Draw/SendHttpGif.

    .PARAMETER Red
        Red channel value (0-255).

    .PARAMETER Green
        Green channel value (0-255).

    .PARAMETER Blue
        Blue channel value (0-255).

    .EXAMPLE
        New-PixooSolidColorData -Red 255 -Green 0 -Blue 0

    .OUTPUTS
        System.String - Base64-encoded RGB data

    .NOTES
        The Pixoo64 expects raw RGB data as Base64 string.
        Format: 64x64 pixels, 3 bytes per pixel (RGB), total 12,288 bytes.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 255)]
        [byte]$Red,

        [Parameter(Mandatory)]
        [ValidateRange(0, 255)]
        [byte]$Green,

        [Parameter(Mandatory)]
        [ValidateRange(0, 255)]
        [byte]$Blue
    )

    Write-Verbose "Generating solid color data: R=$Red, G=$Green, B=$Blue"

    # Create byte array for 64x64 RGB image (12,288 bytes)
    $pixelCount = 64 * 64
    $bytesPerPixel = 3
    $totalBytes = $pixelCount * $bytesPerPixel
    $byteArray = [byte[]]::new($totalBytes)

    # Fill array with RGB values
    for ($i = 0; $i -lt $pixelCount; $i++) {
        $offset = $i * $bytesPerPixel
        $byteArray[$offset] = $Red
        $byteArray[$offset + 1] = $Green
        $byteArray[$offset + 2] = $Blue
    }

    # Convert to Base64
    $base64 = [Convert]::ToBase64String($byteArray)

    Write-Verbose "Generated $totalBytes bytes, Base64 length: $($base64.Length)"

    return $base64
}
