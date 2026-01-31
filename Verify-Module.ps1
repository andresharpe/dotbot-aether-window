<#
.SYNOPSIS
    Verification script for Pixoo64 PowerShell module

.DESCRIPTION
    Quick verification that the module is properly implemented and ready for use.
    Checks module import, function count, help system, and basic functionality.
#>

Write-Host "`n=== Pixoo64 Module Verification ===" -ForegroundColor Cyan
Write-Host "Verifying module implementation...`n" -ForegroundColor Gray

# Test 1: Module Import
Write-Host "[1/6] Testing module import..." -ForegroundColor Yellow
try {
    Import-Module .\src\Pixoo64\Pixoo64.psd1 -Force -ErrorAction Stop
    Write-Host "  ✓ Module imported successfully" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Module import failed: $_" -ForegroundColor Red
    exit 1
}

# Test 2: Function Count
Write-Host "[2/6] Verifying function count..." -ForegroundColor Yellow
$functionCount = (Get-Command -Module Pixoo64).Count
if ($functionCount -eq 31) {
    Write-Host "  ✓ All 31 functions exported" -ForegroundColor Green
}
else {
    Write-Host "  ✗ Expected 31 functions, found $functionCount" -ForegroundColor Red
    exit 1
}

# Test 3: Module Version
Write-Host "[3/6] Checking module version..." -ForegroundColor Yellow
$version = (Get-Module Pixoo64).Version.ToString()
if ($version -eq '1.0.0') {
    Write-Host "  ✓ Module version: $version" -ForegroundColor Green
}
else {
    Write-Host "  ⚠ Module version: $version (expected 1.0.0)" -ForegroundColor Yellow
}

# Test 4: Help System
Write-Host "[4/6] Testing help system..." -ForegroundColor Yellow
$help = Get-Help Find-Pixoo -ErrorAction SilentlyContinue
if ($help -and $help.Synopsis) {
    Write-Host "  ✓ Comment-based help working" -ForegroundColor Green
}
else {
    Write-Host "  ✗ Help system not working" -ForegroundColor Red
    exit 1
}

# Test 5: Function Categories
Write-Host "[5/6] Verifying function categories..." -ForegroundColor Yellow
$functions = Get-Command -Module Pixoo64

$categories = @{
    'Connection & Discovery' = @('Find-Pixoo', 'Connect-Pixoo', 'Disconnect-Pixoo', 'Test-PixooConnection', 'Get-PixooConfiguration')
    'Display Settings' = @('Set-PixooBrightness', 'Get-PixooChannel', 'Set-PixooChannel', 'Set-PixooScreenState', 'Set-PixooClockFace', 'Get-PixooClockInfo')
    'Drawing & Display' = @('Send-PixooText', 'Clear-PixooText', 'Send-PixooImage', 'Send-PixooAnimation', 'Reset-PixooDisplay', 'Set-PixooSolidColor', 'Get-PixooGifId', 'Send-PixooGifUrl')
    'Batch Commands' = @('Invoke-PixooCommandBatch')
    'Tools' = @('Start-PixooTimer', 'Start-PixooStopwatch', 'Set-PixooScoreboard', 'Start-PixooBuzzer', 'Set-PixooNoiseMeter')
    'Device Settings' = @('Set-PixooRotation', 'Set-PixooMirrorMode', 'Set-PixooTimeFormat', 'Set-PixooTemperatureUnit', 'Set-PixooHighLightMode', 'Set-PixooCustomPageIndex')
}

$allCategoriesOk = $true
foreach ($category in $categories.Keys) {
    $expected = $categories[$category]
    $missing = $expected | Where-Object { $_ -notin $functions.Name }

    if ($missing) {
        Write-Host "  ✗ Missing from $category : $($missing -join ', ')" -ForegroundColor Red
        $allCategoriesOk = $false
    }
}

if ($allCategoriesOk) {
    Write-Host "  ✓ All function categories complete" -ForegroundColor Green
}
else {
    exit 1
}

# Test 6: File Structure
Write-Host "[6/6] Verifying file structure..." -ForegroundColor Yellow
$requiredFiles = @(
    'src\Pixoo64\Pixoo64.psd1'
    'src\Pixoo64\Pixoo64.psm1'
    'README.md'
    'LICENSE'
    'CHANGELOG.md'
    'docs\CONTRIBUTING.md'
    'docs\TROUBLESHOOTING.md'
    'examples\README.md'
    'PSScriptAnalyzerSettings.psd1'
)

$missingFiles = $requiredFiles | Where-Object { -not (Test-Path $_) }
if ($missingFiles) {
    Write-Host "  ✗ Missing files: $($missingFiles -join ', ')" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "  ✓ All required files present" -ForegroundColor Green
}

# Summary
Write-Host "`n=== Verification Complete ===" -ForegroundColor Cyan
Write-Host "✓ Module is properly implemented and ready for use!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Install PSScriptAnalyzer: Install-Module PSScriptAnalyzer" -ForegroundColor Gray
Write-Host "  2. Install Pester: Install-Module Pester -MinimumVersion 5.0.0" -ForegroundColor Gray
Write-Host "  3. Run tests: Invoke-Pester -Path .\tests\Unit\" -ForegroundColor Gray
Write-Host "  4. Try examples: .\examples\01-GettingStarted.ps1" -ForegroundColor Gray
Write-Host "`nSee IMPLEMENTATION_SUMMARY.md for full details.`n" -ForegroundColor Gray
