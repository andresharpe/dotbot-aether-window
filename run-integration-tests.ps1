Write-Host "=== INTEGRATION TEST CHECK ===" -ForegroundColor Cyan
Write-Host ""

# Import module to enable discovery
$ModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'src\Pixoo64\Pixoo64.psd1'
Import-Module $ModulePath -Force

# Try to discover device if not manually configured
if (-not $env:PIXOO_TEST_IP) {
    Write-Host "No device manually configured. Attempting discovery..." -ForegroundColor Cyan
    $discoveredDevices = Find-Pixoo -LocalOnly -ErrorAction SilentlyContinue
    
    if ($discoveredDevices) {
        $env:PIXOO_TEST_IP = $discoveredDevices[0].IP
        Write-Host "Discovered device at: $env:PIXOO_TEST_IP" -ForegroundColor Green
    }
}

if ($env:PIXOO_TEST_IP) {
    Write-Host "Testing with device: $env:PIXOO_TEST_IP" -ForegroundColor Green
    Write-Host "Running integration tests..." -ForegroundColor Cyan
    Write-Host ""

    Invoke-Pester -Path .\tests\Integration\ -Output Detailed
} else {
    Write-Host "No Pixoo64 device found on network." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Integration tests require a physical Pixoo64 device." -ForegroundColor Yellow
    Write-Host "To manually specify a device, set:" -ForegroundColor Yellow
    Write-Host '  $env:PIXOO_TEST_IP = "192.168.x.x"' -ForegroundColor White
    Write-Host ""
    Write-Host "Skipping integration tests (optional for QA)." -ForegroundColor Yellow
}
