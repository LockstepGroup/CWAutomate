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
            $ConditionString = ""
            if ($ClientId) {
                $ConditionString += "client.id = $ClientId"
            }
        }

        $ReturnObject = $global:AutomateServer.invokeGetQuery('Computers',$ConditionString)
        $ReturnObject
    }
}