#Requires -Version 7.0

<#
.SYNOPSIS
    Shared test helper functions for Pixoo64 module tests.

.DESCRIPTION
    Provides common mocking functions and utilities for both unit and integration tests.
#>

# Mock Invoke-RestMethod for unit tests
function Get-MockInvokeRestMethod {
    <#
    .SYNOPSIS
        Returns a scriptblock for mocking Invoke-RestMethod in tests.
    #>

    return {
        param($Uri, $Method, $Body, $ContentType, $TimeoutSec, $ErrorAction)

        # Parse command from body
        $bodyObj = $Body | ConvertFrom-Json

        # Import mock responses
        $mockResponsesPath = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures\MockResponses.ps1'
        . $mockResponsesPath

        # Return appropriate mock response based on command
        switch ($bodyObj.Command) {
            'Channel/GetAllConf' {
                return $script:MockGetAllConfSuccess
            }
            'Channel/SetBrightness' {
                return $script:MockSetBrightnessSuccess
            }
            'Draw/SendHttpText' {
                return $script:MockSendHttpTextSuccess
            }
            'Channel/GetIndex' {
                return $script:MockGetChannelSuccess
            }
            default {
                return $script:MockGenericSuccess
            }
        }
    }
}

# Create mock Pixoo session for tests
function New-MockPixooSession {
    <#
    .SYNOPSIS
        Creates a mock Pixoo session for unit tests.
    #>

    param(
        [string]$IPAddress = '192.168.0.73',
        [int]$Port = 80
    )

    return @{
        Uri = "http://${IPAddress}:${Port}/post"
        IPAddress = $IPAddress
        Connected = $true
        LastContact = [DateTime]::Now
        DeviceInfo = @{
            DeviceId = 'MOCK-DEVICE-123'
            DeviceName = 'Mock Pixoo64'
        }
    }
}

# Reset mock session
function Clear-MockPixooSession {
    <#
    .SYNOPSIS
        Clears the mock Pixoo session.
    #>

    $script:PixooSession = $null
}

Export-ModuleMember -Function @(
    'Get-MockInvokeRestMethod'
    'New-MockPixooSession'
    'Clear-MockPixooSession'
)
