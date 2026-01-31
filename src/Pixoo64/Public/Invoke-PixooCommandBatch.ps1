function Invoke-PixooCommandBatch {
    <#
    .SYNOPSIS
        Sends multiple draw commands in a single batch.

    .DESCRIPTION
        Executes multiple drawing commands efficiently by sending them in one API call.
        More efficient than individual calls for complex displays.

    .PARAMETER Commands
        Array of command hashtables to execute.

    .EXAMPLE
        $commands = @(
            @{ Command = 'Draw/SendHttpText'; TextString = 'Line 1'; y = 10 }
            @{ Command = 'Draw/SendHttpText'; TextString = 'Line 2'; y = 30 }
        )
        Invoke-PixooCommandBatch -Commands $commands

    .NOTES
        API Endpoint: Draw/CommandList
        Each command in the array should be a complete command hashtable
        (without the outer "Command" wrapper - that's added automatically).
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [hashtable[]]$Commands
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PixooSession -Throw
        $commandList = [System.Collections.ArrayList]::new()
    }

    process {
        foreach ($cmd in $Commands) {
            [void]$commandList.Add($cmd)
        }
    }

    end {
        $target = "Pixoo64 at $($script:PixooSession.IPAddress)"
        $action = "Execute $($commandList.Count) commands in batch"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Verbose "Sending batch of $($commandList.Count) commands"

                $response = Invoke-PixooCommand -Command @{
                    Command = 'Draw/CommandList'
                    CommandList = $commandList.ToArray()
                }

                Write-Verbose "Batch commands executed successfully"
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }

        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
