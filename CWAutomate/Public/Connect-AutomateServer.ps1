function Connect-AutomateServer {
	<#
	.SYNOPSIS
		Establishes initial connection to ConnectWise Automate API and generates and Authorization Token.
		
	.DESCRIPTION
	
	.EXAMPLE

    .EXAMPLE

    #>
	[CmdletBinding()]

	Param (
		[Parameter(Mandatory=$True,Position=0)]
		[ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
		[string]$Server,

        [Parameter(Mandatory=$True,Position=1)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

		[Parameter(Mandatory=$False)]
		[switch]$SkipCertificateCheck,

        [Parameter(Mandatory=$False)]
		[alias('q')]
        [switch]$Quiet
	)

    BEGIN {
		$VerbosePrefix = "Connect-AutomateServer:"
    }

    PROCESS {

        $global:AutomateServer = [CwaServer]::new($Server,$Credential)

        if (!($Quiet)) {
            return $global:AutomateServer
        }
    }
}