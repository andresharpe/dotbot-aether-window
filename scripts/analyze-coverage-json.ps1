$json = Get-Content coverage-debug.json | ConvertFrom-Json

Write-Host "=== CODE COVERAGE ANALYSIS ===" -ForegroundColor Cyan
Write-Host ""

if ($json.CodeCoverage) {
    Write-Host "CodeCoverage object found!"
    Write-Host ""

    # Get properties
    $props = $json.CodeCoverage | Get-Member -MemberType Properties, NoteProperty
    Write-Host "Properties available:"
    $props | ForEach-Object { Write-Host "  - $($_.Name)" }

    Write-Host ""

    # Try to count commands
    if ($json.CodeCoverage.CommandsMissed) {
        $missedCount = $json.CodeCoverage.CommandsMissed.Count
        Write-Host "Commands Missed: $missedCount"
    }

    if ($json.CodeCoverage.CommandsExecuted) {
        $executedCount = $json.CodeCoverage.CommandsExecuted.Count
        Write-Host "Commands Executed: $executedCount"
    }

    if ($json.CodeCoverage.CommandsAnalyzed) {
        $analyzedCount = $json.CodeCoverage.CommandsAnalyzed.Count
        Write-Host "Commands Analyzed: $analyzedCount"
    }

    # List all covered files
    if ($json.CodeCoverage.CoverageReport) {
        Write-Host ""
        Write-Host "Coverage Report available with $($json.CodeCoverage.CoverageReport.Count) entries"
    }

} else {
    Write-Host "No CodeCoverage object found!" -ForegroundColor Red
}
