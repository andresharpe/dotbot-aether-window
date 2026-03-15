Write-Host "Running tests..." -ForegroundColor Cyan

$config = New-PesterConfiguration
$config.Run.Path = '.\tests\Unit\'
$config.Run.PassThru = $true
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '.\src\Pixoo64\**\*.ps1'
$config.Output.Verbosity = 'None'

$result = Invoke-Pester -Configuration $config

Write-Host ""
Write-Host "Result is null: $($null -eq $result)"
Write-Host "CodeCoverage is null: $($null -eq $result.CodeCoverage)"

if ($result) {
    Write-Host ""
    Write-Host "Result properties:"
    $result.PSObject.Properties | ForEach-Object { Write-Host "  $($_.Name) = $($_.Value)" }
}

if ($result.CodeCoverage) {
    Write-Host ""
    Write-Host "CodeCoverage properties:"
    $result.CodeCoverage.PSObject.Properties | ForEach-Object { Write-Host "  $($_.Name) = $($_.Value)" }
}

# Try converting to JSON to see structure
Write-Host ""
Write-Host "Exporting to coverage-debug.json..."
$result | ConvertTo-Json -Depth 5 | Out-File coverage-debug.json
Write-Host "Done. Check coverage-debug.json for full structure."
