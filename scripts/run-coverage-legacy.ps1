Write-Host "Running tests with code coverage (legacy syntax)..." -ForegroundColor Cyan

$result = Invoke-Pester -Path .\tests\Unit\ -CodeCoverage .\src\Pixoo64\**\*.ps1 -PassThru -Show None

Write-Host ""
Write-Host "=== CODE COVERAGE SUMMARY ===" -ForegroundColor Cyan

if ($null -eq $result.CodeCoverage) {
    Write-Host "ERROR: CodeCoverage is null" -ForegroundColor Red
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
        Write-Host ""
        Write-Host "=== TOP 10 FILES WITH COVERAGE GAPS ===" -ForegroundColor Yellow
        $result.CodeCoverage.MissedCommands |
            Group-Object File |
            Sort-Object Count -Descending |
            Select-Object -First 10 |
            ForEach-Object {
                $fileName = Split-Path $_.Name -Leaf
                Write-Host "  $fileName : $($_.Count) missed commands"
            }
    }
}

Write-Host ""
Write-Host "=== TEST RESULTS ===" -ForegroundColor Cyan
Write-Host "Tests Passed: $($result.PassedCount)"
Write-Host "Tests Failed: $($result.FailedCount)"
Write-Host "Tests Skipped: $($result.SkippedCount)"
Write-Host "Execution Time: $([math]::Round($result.Time.TotalSeconds, 2))s"
