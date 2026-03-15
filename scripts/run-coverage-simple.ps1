$config = New-PesterConfiguration
$config.Run.Path = '.\tests\Unit\'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '.\src\Pixoo64\**\*.ps1'
$config.Output.Verbosity = 'None'

Write-Host "Running tests with code coverage..." -ForegroundColor Cyan
$result = Invoke-Pester -Configuration $config

Write-Host ""
Write-Host "=== CODE COVERAGE SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total Commands Analyzed: $($result.CodeCoverage.CommandsAnalyzedCount)"
Write-Host "Commands Executed: $($result.CodeCoverage.CommandsExecutedCount)"
Write-Host "Commands Missed: $($result.CodeCoverage.CommandsMissedCount)"

if ($result.CodeCoverage.CommandsAnalyzedCount -gt 0) {
    $coverage = ($result.CodeCoverage.CommandsExecutedCount / $result.CodeCoverage.CommandsAnalyzedCount) * 100
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
