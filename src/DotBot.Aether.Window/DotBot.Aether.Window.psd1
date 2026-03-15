@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'DotBot.Aether.Window.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Core')

    # ID used to uniquely identify this module
    GUID = 'f99e6162-6ea3-4c4f-baa1-dfc53d53b7c1'

    # Author of this module
    Author = 'Andre'

    # Company or vendor of this module
    CompanyName = 'DotBot'

    # Copyright statement for this module
    Copyright = '(c) 2026 Andre. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'DotBot Aether Window Conduit — Divoom Pixoo-64 LED display control via REST API. Part of the dotbot-aether conduit plugin collection.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.0'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        # Aether Interface Contract (6)
        'Initialize-AetherWindow'
        'Find-AetherWindow'
        'Connect-AetherWindow'
        'Disconnect-AetherWindow'
        'Test-AetherWindow'
        'Invoke-AetherWindowEvent'
        # Connection & Discovery (5)
        'Find-Pixoo'
        'Connect-Pixoo'
        'Disconnect-Pixoo'
        'Test-PixooConnection'
        'Get-PixooConfiguration'

        # Display Settings (6)
        'Set-PixooBrightness'
        'Get-PixooChannel'
        'Set-PixooChannel'
        'Set-PixooScreenState'
        'Set-PixooClockFace'
        'Get-PixooClockInfo'

        # Drawing & Display (8)
        'Send-PixooText'
        'Clear-PixooText'
        'Send-PixooImage'
        'Send-PixooAnimation'
        'Reset-PixooDisplay'
        'Set-PixooSolidColor'
        'Get-PixooGifId'
        'Send-PixooGifUrl'

        # Batch Commands (1)
        'Invoke-PixooCommandBatch'

        # Tools (5)
        'Start-PixooTimer'
        'Start-PixooStopwatch'
        'Set-PixooScoreboard'
        'Start-PixooBuzzer'
        'Set-PixooNoiseMeter'

        # Device Settings (11)
        'Set-PixooRotation'
        'Set-PixooMirrorMode'
        'Set-PixooTimeFormat'
        'Set-PixooTemperatureUnit'
        'Set-PixooHighLightMode'
        'Set-PixooCustomPageIndex'
        'Set-PixooTime'
        'Set-PixooTimeZone'
        'Set-PixooLocation'
        'Set-PixooWhiteBalance'
        'Invoke-PixooRemoteCommands'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('DotBot', 'Aether', 'Window', 'Pixoo64', 'Divoom', 'LED', 'Display', 'REST', 'API', 'IoT', 'Hardware')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/andresharpe/dotbot-aether-window/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/andresharpe/dotbot-aether-window'

            # ReleaseNotes of this module
            ReleaseNotes = @'
v1.0.0 - Initial Release

Complete PowerShell module for Pixoo64 LED display control:
- 31 public functions with full API coverage
- Device discovery (cloud + ARP cache + full subnet scan)
- Pipeline support throughout (Find-Pixoo | Connect-Pixoo)
- Comprehensive error handling with retry logic
- Cross-platform (PowerShell 7+)
- Complete documentation and examples
- Unit and integration test infrastructure

New Functions:
- Connection: Find-Pixoo, Connect-Pixoo, Disconnect-Pixoo, Test-PixooConnection, Get-PixooConfiguration
- Display: Set-PixooBrightness, Get/Set-PixooChannel, Set-PixooScreenState, Get/Set-PixooClockFace/Info
- Drawing: Send-PixooText/Image/Animation, Clear-PixooText, Reset-PixooDisplay, Set-PixooSolidColor
- Advanced: Get-PixooGifId, Send-PixooGifUrl, Invoke-PixooCommandBatch
- Tools: Start-PixooTimer/Stopwatch/Buzzer, Set-PixooScoreboard/NoiseMeter
- Settings: Set-PixooRotation/MirrorMode/TimeFormat/TemperatureUnit/HighLightMode/CustomPageIndex

See README.md and CHANGELOG.md for full details.
'@
        }
    }
}
