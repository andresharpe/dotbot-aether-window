# Mock API response data for testing

# GetAllConf - Success
$script:MockGetAllConfSuccess = [PSCustomObject]@{
    error_code = 0
    Brightness = 50
    RotationFlag = 0
    ClockTime = 60
    GalleryTime = 60
    SingleGalleyTime = 5
    PowerOnChannelId = 0
    GalleryShowTimeFlag = 0
    CurClockId = 182
    Time24Flag = 0
    TemperatureMode = 0
    GyrateAngle = 0
    MirrorFlag = 0
    LightSwitch = 1
    DeviceId = 'MOCK-DEVICE-123'
    DeviceName = 'Mock Pixoo64'
}

# GetAllConf - Error
$script:MockGetAllConfError = [PSCustomObject]@{
    error_code = 1
}

# SetBrightness - Success
$script:MockSetBrightnessSuccess = [PSCustomObject]@{
    error_code = 0
}

# SendHttpText - Success
$script:MockSendHttpTextSuccess = [PSCustomObject]@{
    error_code = 0
}

# GetChannel - Success
$script:MockGetChannelSuccess = [PSCustomObject]@{
    error_code = 0
    SelectIndex = 0
}

# Cloud Discovery - Success
$script:MockCloudDiscoverySuccess = [PSCustomObject]@{
    ReturnCode = 0
    ReturnMessage = 'success'
    DeviceList = @(
        [PSCustomObject]@{
            DeviceName = 'Living Room Pixoo'
            DeviceId = 'CLOUD-DEVICE-001'
            DevicePrivateIP = '192.168.0.50'
        }
        [PSCustomObject]@{
            DeviceName = 'Office Pixoo'
            DeviceId = 'CLOUD-DEVICE-002'
            DevicePrivateIP = '192.168.0.51'
        }
    )
}

# Cloud Discovery - Empty
$script:MockCloudDiscoveryEmpty = [PSCustomObject]@{
    ReturnCode = 0
    ReturnMessage = 'success'
    DeviceList = @()
}

# Generic Success
$script:MockGenericSuccess = [PSCustomObject]@{
    error_code = 0
}
