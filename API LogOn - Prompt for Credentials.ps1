Clear-Host


if ($Proxy_Security -eq $NULL)
{
Write-Host "Loading Security WSDL"
$URI_Security = "https://integration.pgiconnect.com/Services/Public/2009/03/Security.svc?wsdl"
$Proxy_Security = New-WebServiceProxy -Uri $URI_Security -Namespace security
}
else
{ write-host "Security URI & WSDL Loaded" }


Write-Host "`n----------------------------------------------------------------"
write-host "Define LogOn Message"
$ApiCredentialsGet = Get-Credential -Message "Please enter your API WebId and Password"
$ClientCredentialsGet = Get-Credential -Message "Please enter your ClientID and Password"

$LogOnMessage = New-Object "security.LogOnMessage"
    $ApiCredentials = New-Object "security.Credentials"
        $ApiCredentials.Id = $ApiCredentialsGet.UserName
        $ApiCredentials.Password = $ApiCredentialsGet.GetNetworkCredential().Password

    $ClientCredentials = New-Object "security.Credentials"
        $ClientCredentials.Id = $ClientCredentialsGet.UserName
        $ClientCredentials.Password = $ClientCredentialsGet.GetNetworkCredential().Password

$LogOnMessage.ApiCredentials = $ApiCredentials
$LogOnMessage.ClientCredentials = $ClientCredentials
$LogOnMessage.CorrelationId = "PowerShell Flow"