function Disconnect-AetherWindow {
    <#
    .SYNOPSIS
        Disconnect from Pixoo-64 hardware.
    .DESCRIPTION
        Clean shutdown of the Window conduit.
    #>
    [CmdletBinding()]
    param()
    Write-Verbose "Disconnecting Aether Window conduit..."
    Disconnect-Pixoo @PSBoundParameters
}
