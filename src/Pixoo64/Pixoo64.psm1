#Requires -Version 7.0

<#
.SYNOPSIS
    Pixoo64 PowerShell Module - Main module file

.DESCRIPTION
    PowerShell module for controlling the Divoom Pixoo64 LED display via REST API.
    Provides complete API coverage with device discovery, display control, animations,
    tools, and settings management.

.NOTES
    Author: Pixoo64 PowerShell Module Contributors
    Version: 0.1.0
    License: MIT
#>

# Initialize module-scoped session variable
$script:PixooSession = $null

# Get module paths
$PrivatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$PublicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'

# Dot-source all private functions
if (Test-Path -Path $PrivatePath) {
    $PrivateFunctions = Get-ChildItem -Path $PrivatePath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
    foreach ($Function in $PrivateFunctions) {
        try {
            . $Function.FullName
            Write-Verbose "Imported private function: $($Function.BaseName)"
        }
        catch {
            Write-Error "Failed to import private function $($Function.FullName): $_"
        }
    }
}

# Dot-source all public functions
if (Test-Path -Path $PublicPath) {
    $PublicFunctions = Get-ChildItem -Path $PublicPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
    foreach ($Function in $PublicFunctions) {
        try {
            . $Function.FullName
            Write-Verbose "Imported public function: $($Function.BaseName)"
        }
        catch {
            Write-Error "Failed to import public function $($Function.FullName): $_"
        }
    }
}

# Module cleanup on removal
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    if ($script:PixooSession) {
        Write-Verbose "Clearing Pixoo session on module removal"
        $script:PixooSession = $null
    }
}

# Export public functions (defined in manifest)
Export-ModuleMember -Function @(
    # Connection & Discovery
    'Find-Pixoo'
    'Connect-Pixoo'
    'Disconnect-Pixoo'
    'Test-PixooConnection'
    'Get-PixooConfiguration'

    # Display Settings
    'Set-PixooBrightness'
    'Get-PixooChannel'
    'Set-PixooChannel'
    'Set-PixooScreenState'
    'Set-PixooClockFace'
    'Get-PixooClockInfo'

    # Drawing & Display
    'Send-PixooText'
    'Clear-PixooText'
    'Send-PixooImage'
    'Send-PixooAnimation'
    'Reset-PixooDisplay'
    'Set-PixooSolidColor'
    'Get-PixooGifId'
    'Send-PixooGifUrl'

    # Batch Commands
    'Invoke-PixooCommandBatch'

    # Tools
    'Start-PixooTimer'
    'Start-PixooStopwatch'
    'Set-PixooScoreboard'
    'Start-PixooBuzzer'
    'Set-PixooNoiseMeter'

    # Device Settings
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
