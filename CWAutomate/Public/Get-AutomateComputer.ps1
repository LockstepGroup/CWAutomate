function Get-AutomateComputer {
	<#
	.SYNOPSIS
		Gets Computers from Automate Server.
		
	.DESCRIPTION
	
	.EXAMPLE

    .EXAMPLE

    #>
	[CmdletBinding()]

	Param (
		[Parameter(Mandatory=$False,Position=0)]
        [int]$ClientId,

        [Parameter(Mandatory=$False)]
        [string]$ConditionString
	)

    BEGIN {
		$VerbosePrefix = "Get-AutomateComputer:"
    }

    PROCESS {

        if (!($ConditionString)) {
            if ($ClientId) {
                $ConditionHash = @{}
                $ConditionHash.condition = "client.id = $ClientId"
            }
        }

        $ReturnObject = $global:AutomateServer.invokeGetQuery('Computers',$ConditionHash)
        $ReturnObject
    }
}