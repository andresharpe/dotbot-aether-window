function Connect-AetherWindow {
    <#
    .SYNOPSIS
        Connect to discovered Pixoo-64 hardware.
    .DESCRIPTION
        Delegates to the underlying hardware connection function.
    #>
    [CmdletBinding()]
    param()
    Write-Verbose "Connecting Aether Window conduit..."
    Connect-Pixoo @PSBoundParameters
}
