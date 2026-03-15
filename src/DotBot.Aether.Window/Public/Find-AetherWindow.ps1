function Find-AetherWindow {
    <#
    .SYNOPSIS
        Discover Pixoo-64 hardware on network/bus.
    .DESCRIPTION
        Delegates to the underlying hardware discovery function.
    #>
    [CmdletBinding()]
    param()
    Write-Verbose "Discovering Aether Window hardware..."
    Find-Pixoo @PSBoundParameters
}
