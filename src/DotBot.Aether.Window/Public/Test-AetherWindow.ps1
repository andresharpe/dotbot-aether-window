function Test-AetherWindow {
    <#
    .SYNOPSIS
        Health check for the Window conduit.
    .DESCRIPTION
        Returns $true if the Pixoo-64 hardware is reachable.
    #>
    [CmdletBinding()]
    param()
    Write-Verbose "Testing Aether Window conduit health..."
    Test-PixooConnection @PSBoundParameters
}
