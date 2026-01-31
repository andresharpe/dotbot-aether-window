function Set-PixooCustomPageIndex {
    <#
    .SYNOPSIS
        Sets the custom page index on the Pixoo64.

    .DESCRIPTION
        Selects which custom page to display when on the Custom channel (3).

    .PARAMETER PageIndex
        Custom page index to display.

    .EXAMPLE
        Set-PixooCustomPageIndex -PageIndex 0

    .EXAMPLE
        Set-PixooCustomPageIndex -PageIndex 5

    .NOTES
        API Endpoint: Channel/SetCustomPageIndex
        Device must be on Custom channel (3) for this to take effect.
        Use Set-PixooChannel -Channel Custom first if needed.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateRange(0, 100)]
        [int]$PageIndex
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Set custom page index to $PageIndex"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Setting custom page index to $PageIndex"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Channel/SetCustomPageIndex'
                    CustomPageIndex = $PageIndex
                }

                Write-Verbose "Custom page index set successfully"
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
