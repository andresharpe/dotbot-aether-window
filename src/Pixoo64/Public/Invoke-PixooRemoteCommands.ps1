function Invoke-PixooRemoteCommands {
    <#
    .SYNOPSIS
        Executes commands from a remote URL on the Pixoo64 device.

    .DESCRIPTION
        Instructs the device to fetch and execute a list of commands from an HTTP endpoint.
        The device itself retrieves and processes the command file.

    .PARAMETER CommandUrl
        HTTP URL pointing to a text file containing commands.
        Note: HTTPS may not be supported by the device; use HTTP URLs.

    .EXAMPLE
        Invoke-PixooRemoteCommands -CommandUrl "http://example.com/commands.txt"
        Executes commands from the specified URL.

    .NOTES
        API Endpoint: Draw/UseHTTPCommandSource
        - The URL must be accessible from the device's network.
        - HTTPS URLs may not be supported (use HTTP).
        - The command file format should match Divoom's expected format.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^https?://')]
        [string]$CommandUrl
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
    }

    process {
        # Warn if using HTTPS
        if ($CommandUrl -match '^https://') {
            Write-Warning "HTTPS URLs may not be supported by the device. Consider using HTTP instead."
        }

        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Execute commands from $CommandUrl"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Instructing device to fetch commands from: $CommandUrl"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Draw/UseHTTPCommandSource'
                    CommandUrl = $CommandUrl
                }

                Write-Verbose "Remote commands executed successfully"
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
