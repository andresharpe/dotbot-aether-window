$json = Get-Content coverage-debug.json | ConvertFrom-Json

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "  CODE COVERAGE REPORT" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

$coverage = $json.CodeCoverage

Write-Host "Test Results:" -ForegroundColor Yellow
Write-Host "  Tests Passed: $($json.PassedCount)"
Write-Host "  Tests Failed: $($json.FailedCount)"
Write-Host "  Execution Time: $([math]::Round($json.Duration.TotalSeconds, 2))s"
Write-Host ""

Write-Host "Coverage Statistics:" -ForegroundColor Yellow
Write-Host "  Files Analyzed: $($coverage.FilesAnalyzedCount)"
Write-Host "  Commands Analyzed: $($coverage.CommandsAnalyzedCount)"
Write-Host "  Commands Executed: $($coverage.CommandsExecutedCount)"
Write-Host "  Commands Missed: $($coverage.CommandsMissedCount)"
Write-Host ""

$coveragePercent = if ($coverage.CommandsAnalyzedCount -gt 0) {
    ($coverage.CommandsExecutedCount / $coverage.CommandsAnalyzedCount) * 100
} else { 0 }
$coverageRounded = [math]::Round($coveragePercent, 2)

$color = if ($coverageRounded -ge 80) { 'Green' } elseif ($coverageRounded -ge 60) { 'Yellow' } else { 'Red' }
Write-Host "  Coverage Percentage: $coverageRounded%" -ForegroundColor $color

if ($coverageRounded -ge 80) {
    Write-Host "  ✓ Coverage target met (≥80%)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Coverage below target (<80%)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Files with Coverage Gaps:" -ForegroundColor Yellow

# Group missed commands by file
$missedByFile = $coverage.CommandsMissed | Group-Object File | Sort-Object Count -Descending

Write-Host "  Top 10 files needing coverage:"
$missedByFile | Select-Object -First 10 | ForEach-Object {
    $fileName = Split-Path $_.Name -Leaf
    Write-Host "    $fileName : $($_.Count) missed commands" -ForegroundColor Red
}

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Summary
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  The current test suite covers $coverageRounded% of the codebase."
Write-Host "  To reach 80% coverage, approximately $([math]::Ceiling(($coverage.CommandsAnalyzedCount * 0.8) - $coverage.CommandsExecutedCount)) more commands need to be tested."
