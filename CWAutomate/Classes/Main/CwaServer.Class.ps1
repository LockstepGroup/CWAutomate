class CwaServer {
    [string]$Address
    [string]$Token
    [datetime]$TokenExpirationDate

    # Track usage
    hidden [bool]$Connected
    hidden [string]$ConfigNode
    [array]$UrlHistory
    [array]$RawQueryResultHistory
    [array]$QueryHistory
    $LastError
    $LastResult

    ##################################### Initiators #####################################
    # Initiator for Address only
    CwaServer([string]$Address) {
        $this.Address = $Address
    }

    # Initiator with Credential
    CwaServer([string]$Address,[PSCredential]$Credential) {
        $this.Address = $Address
        $this.invokeTokenQuery($Credential)
    }

    # Generate Api URL
    [String] getApiUrl([string]$UrlPostfix,[string]$ConditionString) {
        if ($this.Address) {
            $url = "https://" + $this.Address + "/cwa/api/v1/" + $UrlPostfix + "?pagesize=1000"
            if ($ConditionString) {
                $url += '&condition=' + $ConditionString
            }
            return $url
        } else {
            return $null
        }
    }

    ##################################### Specific Queries #####################################
    # Keygen API Query
    [psobject] invokeTokenQuery([PSCredential]$credential) {
        $queryBody = @{}
        $queryBody.username = $credential.UserName
        $queryBody.password = $Credential.getnetworkcredential().password
        $queryBody = $queryBody | ConvertTo-Json -Compress

        $Url = $this.getApiUrl("apitoken",$null)

        $result = $this.invokeApiQuery('POST',$url,$queryBody)

        $this.Token = $result.AccessToken
        $this.TokenExpirationDate = $result.ExpirationDate

        return $result
    }

    # Keygen API Query
    [psobject] invokeGetQuery([string]$UrlPostfix,[string]$ConditionString) {
        $Url    = $this.getApiUrl($UrlPostfix,$ConditionString)
        $result = $this.invokeApiQuery('GET',$url,$null)

        return $result
    }


    ##################################### Main Query Method #####################################
    [psobject] invokeApiQuery($Method,$Url,$Body) {
        $returnObject = $null
        $params             = @{}
        $params.Uri         = $Url
        $params.Method      = $Method
        $params.ContentType = 'application/json'
        $params.Body        = $Body

        # Check for token generation url
        if ($Url -match 'apitoken') {
            $queryResult = Invoke-RestMethod @params
            $returnObject = $queryResult
        } else {
            $params.Headers = @{}
            $params.Headers.Authorization = 'Bearer ' + $this.Token

            $queryResult  = Invoke-RestMethod @params
            $returnObject = $queryResult
        }
        return $returnObject
    }
}
