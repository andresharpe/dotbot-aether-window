$config = New-PesterConfiguration
$config.Run.Path = '.\tests\Unit\'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '.\src\Pixoo64\**\*.ps1'
$config.Output.Verbosity = 'None'

Write-Host "Running tests..." -ForegroundColor Cyan
$result = Invoke-Pester -Configuration $config

Write-Host ""
Write-Host "Result object type: $($result.GetType().FullName)"
Write-Host ""
Write-Host "Result properties:"
$result | Get-Member -MemberType Property | Select-Object Name

Write-Host ""
Write-Host "CodeCoverage type: $($result.CodeCoverage.GetType().FullName)"
Write-Host ""
Write-Host "CodeCoverage properties:"
$result.CodeCoverage | Get-Member -MemberType Property | Select-Object Name

Write-Host ""
Write-Host "Trying to access coverage data:"
Write-Host "CommandsAnalyzed: $($result.CodeCoverage.CommandsAnalyzed)"
Write-Host "CommandsExecuted: $($result.CodeCoverage.CommandsExecuted)"
Write-Host "CommandsMissed: $($result.CodeCoverage.CommandsMissed)"
Write-Host "CoveragePercent: $($result.CodeCoverage.CoveragePercent)"
