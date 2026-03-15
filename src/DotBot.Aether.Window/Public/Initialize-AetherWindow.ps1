function Initialize-AetherWindow {
    <#
    .SYNOPSIS
        Initialize the Window conduit (Pixoo-64).
    .DESCRIPTION
        Accepts configuration, validates hardware reachability, and prepares
        the Window conduit for event handling.
    .PARAMETER Config
        Hashtable of conduit configuration from dotbot settings.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )
    Write-Verbose "Initializing Aether Window conduit..."
    $script:AetherConfig = $Config
    $result = Test-PixooConnection -ErrorAction SilentlyContinue
    if ($result) {
        Write-Verbose "Aether Window conduit initialized successfully."
    }
    $result
}
