$results = Invoke-ScriptAnalyzer -Path .\src\Pixoo64 -Recurse -Settings .\PSScriptAnalyzerSettings.psd1
$grouped = $results | Group-Object Severity

Write-Output 'PSScriptAnalyzer Results:'
Write-Output '========================'
Write-Output "Total Issues: $($results.Count)"
Write-Output ''

foreach ($g in $grouped) {
    Write-Output "$($g.Name): $($g.Count)"
}

Write-Output ''
Write-Output 'Issues by Rule (Top 10):'
$results | Group-Object RuleName | Sort-Object Count -Descending | Select-Object -First 10 | ForEach-Object {
    Write-Output "  $($_.Name): $($_.Count)"
}
