function Set-PixooScoreboard {
    <#
    .SYNOPSIS
        Sets the scoreboard display on the Pixoo64.

    .DESCRIPTION
        Displays a red vs blue scoreboard with customizable scores.

    .PARAMETER RedScore
        Red team score (0-999).

    .PARAMETER BlueScore
        Blue team score (0-999).

    .EXAMPLE
        Set-PixooScoreboard -RedScore 10 -BlueScore 8

    .EXAMPLE
        Set-PixooScoreboard -RedScore 0 -BlueScore 0

    .NOTES
        API Endpoint: Tools/SetScoreBoard
        Valid score range: 0-999
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 999)]
        [int]$RedScore,

        [Parameter(Mandatory)]
        [ValidateRange(0, 999)]
        [int]$BlueScore
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set scoreboard to Red: $RedScore, Blue: $BlueScore"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting scoreboard: Red=$RedScore, Blue=$BlueScore"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Tools/SetScoreBoard'
                    BlueScore = $BlueScore
                    RedScore = $RedScore
                }

                Write-Verbose "Scoreboard set successfully"
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
