$config = New-PesterConfiguration
$config.Run.Path = '.\tests\Unit\'
$config.Run.PassThru = $true
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '.\src\Pixoo64\**\*.ps1'
$config.Output.Verbosity = 'None'

Write-Host "Running tests with code coverage..." -ForegroundColor Cyan
$result = Invoke-Pester -Configuration $config

Write-Host ""
if ($null -eq $result) {
    Write-Host "ERROR: Result is null" -ForegroundColor Red
    exit 1
}

Write-Host "=== CODE COVERAGE SUMMARY ===" -ForegroundColor Cyan

if ($null -eq $result.CodeCoverage) {
    Write-Host "ERROR: CodeCoverage is null" -ForegroundColor Red
    Write-Host "Available properties:"
    $result | Get-Member -MemberType Property | ForEach-Object { Write-Host "  $($_.Name)" }
    exit 1
}

$analyzed = $result.CodeCoverage.NumberOfCommandsAnalyzed
$executed = $result.CodeCoverage.NumberOfCommandsExecuted
$missed = $result.CodeCoverage.NumberOfCommandsMissed

Write-Host "Total Commands Analyzed: $analyzed"
Write-Host "Commands Executed: $executed"
Write-Host "Commands Missed: $missed"

if ($analyzed -gt 0) {
    $coverage = ($executed / $analyzed) * 100
    $coverageRounded = [math]::Round($coverage, 2)

    $color = if ($coverageRounded -ge 80) { 'Green' } elseif ($coverageRounded -ge 60) { 'Yellow' } else { 'Red' }
    Write-Host "Coverage Percentage: $coverageRounded%" -ForegroundColor $color

    if ($coverageRounded -ge 80) {
        Write-Host "✓ Coverage target met (≥80%)" -ForegroundColor Green
    } else {
        Write-Host "✗ Coverage below target (<80%)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== TEST RESULTS ===" -ForegroundColor Cyan
Write-Host "Tests Passed: $($result.PassedCount)"
Write-Host "Tests Failed: $($result.FailedCount)"
Write-Host "Tests Skipped: $($result.SkippedCount)"
