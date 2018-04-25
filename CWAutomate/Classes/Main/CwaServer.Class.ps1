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
    [String] getApiUrl([string]$UrlPostfix,[hashtable]$QueryHashTable) {
        if ($QueryHashTable) {
            $QueryHashTable.pagesize = 1000
        } else {
            $QueryHashTable = @{}
            $QueryHashTable.pagesize = 1000
        }

        $QueryString = [HelperWeb]::createQueryString($QueryHashTable)

        if ($this.Address) {
            $url = "https://" + $this.Address + "/cwa/api/v1/" + $UrlPostfix + $QueryString
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
    [psobject] invokeGetQuery([string]$UrlPostfix,[hashtable]$QueryHashTable) {
        $Url    = $this.getApiUrl($UrlPostfix,$QueryHashTable)
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

        $this.UrlHistory += $Url

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
