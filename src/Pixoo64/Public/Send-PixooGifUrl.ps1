function Send-PixooGifUrl {
    <#
    .SYNOPSIS
        Plays a GIF from URL or SD card on the Pixoo64.

    .DESCRIPTION
        Displays an animated GIF from a network URL or SD card file.
        Alternative to manually sending frame-by-frame animations.

    .PARAMETER Url
        URL or path to GIF file.
        - For URLs: Full HTTP/HTTPS URL
        - For SD card: Filename or folder path

    .PARAMETER FileType
        Source type: URL, SD, or SDFolder.
        - URL: Load from network URL (default)
        - SD: Play single file from SD card
        - SDFolder: Play all GIFs in SD card folder

    .EXAMPLE
        Send-PixooGifUrl -Url "http://example.com/animation.gif"

    .EXAMPLE
        Send-PixooGifUrl -Url "animations/test.gif" -FileType SD

    .EXAMPLE
        Send-PixooGifUrl -Url "animations" -FileType SDFolder

    .NOTES
        API Endpoint: Device/PlayTFGif
        FileType values:
        - 0 = SD card file
        - 1 = SD card folder
        - 2 = URL (default)
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,

        [Parameter()]
        [ValidateSet('URL', 'SD', 'SDFolder')]
        [string]$FileType = 'URL'
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Convert FileType to API value
        $fileTypeValue = switch ($FileType) {
            'SD' { 0 }
            'SDFolder' { 1 }
            'URL' { 2 }
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Play GIF from $FileType : $Url"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Playing GIF from $FileType : $Url"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Device/PlayTFGif'
                    FileType = $fileTypeValue
                    FileName = $Url
                }

                Write-Verbose "GIF playback started successfully"
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
