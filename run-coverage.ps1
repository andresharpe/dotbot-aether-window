$config = New-PesterConfiguration
$config.Run.Path = '.\tests\Unit\'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '.\src\Pixoo64\**\*.ps1'
$config.Output.Verbosity = 'Detailed'

$result = Invoke-Pester -Configuration $config

Write-Host ''
Write-Host '=== CODE COVERAGE SUMMARY ===' -ForegroundColor Cyan
Write-Host "Total Commands: $($result.CodeCoverage.CommandsAnalyzedCount)"
Write-Host "Executed Commands: $($result.CodeCoverage.CommandsExecutedCount)"
Write-Host "Missed Commands: $($result.CodeCoverage.CommandsMissedCount)"

if ($result.CodeCoverage.CommandsAnalyzedCount -gt 0) {
    $coverage = [math]::Round(($result.CodeCoverage.CommandsExecutedCount / $result.CodeCoverage.CommandsAnalyzedCount) * 100, 2)
    Write-Host "Coverage: $coverage%" -ForegroundColor $(if ($coverage -ge 80) { 'Green' } else { 'Yellow' })
} else {
    Write-Host "Coverage: N/A"
}

Write-Host ''
if ($result.CodeCoverage.CommandsMissedCount -gt 0) {
    Write-Host '=== COVERAGE GAPS ===' -ForegroundColor Yellow
    $result.CodeCoverage.MissedCommands | Group-Object File | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.Name): $($_.Count) missed commands"
    }
}
