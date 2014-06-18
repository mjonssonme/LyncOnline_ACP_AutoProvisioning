Clear-Host

Write-Host "`n----------------------------------------------------------------"


if ($Proxy_Security -eq $NULL)
{
Write-Host "Loading Security WSDL"
$URI_Security = "https://integration.pgiconnect.com/Services/Public/2009/03/Security.svc?wsdl"
$Proxy_Security = New-WebServiceProxy -Uri $URI_Security -Namespace security
}
else
{ write-host "Security URI & WSDL Loaded" }

if ($Proxy_ProvisioningServices -eq $NULL)
{
Write-Host "Loading Services WSDL"
$URI_ProvisioningServices = "https://integration.pgiconnect.com/Services/Public/2009/03/ProvisioningServices.svc?wsdl"
$Proxy_ProvisioningServices = New-WebServiceProxy -Uri $URI_ProvisioningServices -Namespace services
}
else
{ write-host "ProvisioningServices URI & WSDL Loaded" }

if ($Proxy_ProvisioningProfiles -eq $NULL)
{
Write-Host "Loading Profiles WSDL`n"
$URI_ProvisioningProfiles = "https://integration.pgiconnect.com/Services/Public/2009/03/ProvisioningProfiles.svc?wsdl"
$Proxy_ProvisioningProfiles = New-WebServiceProxy -Uri $URI_ProvisioningProfiles -Namespace profiles
}
else {Write-Host "ProvisioningProfiles URI & WSDL Loaded"}

Write-Host "`n----------------------------------------------------------------"
write-host "Define LogOn Message"
$LogOnMessage = New-Object "security.LogOnMessage"
    $ApiCredentials = New-Object "security.Credentials"
        $ApiCredentials.Id = ""                             #ADD YOUR CREDENTIALS
        $ApiCredentials.Password = ""                       #ADD YOUR CREDENTIALS

    $ClientCredentials = New-Object "security.Credentials"
        $ClientCredentials.Id = ""                           #ADD YOUR CREDENTIALS
        $ClientCredentials.Password = ""                     #ADD YOUR CREDENTIALS

$LogOnMessage.ApiCredentials = $ApiCredentials
$LogOnMessage.ClientCredentials = $ClientCredentials
$LogOnMessage.CorrelationId = "PowerShell Flow"


Write-Host "----------------------------------------------------------------"
write-host "Define ClientCreate Message"
$ClientCreateMessage= New-Object "profiles.ClientCreateMessage"
#Client Details
write-host "Client Details"
$ClientCreateMessage.Token = $LogOnResult.Token
$ClientCreateMessage.CorrelationId = $LogOnResult.CorrelationId
$ClientCreateMessage.CompanyId ="NNNNNN"                       #ADD YOUR Value
$ClientCreateMessage.HubId ="NNNNNN"                           #ADD YOUR Value
$ClientCreateMessage.Password = "NNNNNNNN"                     #ADD YOUR Value

$ClientDetails = New-Object "profiles.ClientDetail"
$ClientDetails.RoleCode = 1                                   #ADD YOUR Value
$ClientDetails.RoleCodeSpecified = 1                          #ADD YOUR Value
$ClientDetails.TimeZoneCode = "CEURPSWEDN"                    #ADD YOUR Value
$ClientCreateMessage.Client = $ClientDetails

write-host "Client Billing Details"
$ClientBillingDetails = New-Object "profiles.ClientBillingDetail"
$ClientBillingDetails.POCC = "POCC for Powershell"            #ADD YOUR Value
#Send back to Message
$ClientCreateMessage.Billing = $ClientBillingDetails

write-host "Client Contact Detail"
$ClientContactDetail = New-Object "profiles.ContactDetail"
$ClientContactDetail.FirstName = "Mattias"                   #ADD YOUR Value
$ClientContactDetail.LastName = "Johnsson"                   #ADD YOUR Value
$ClientContactDetail.email= "mattias@pgi.com"                #ADD YOUR Value
$ClientContactDetail.PhoneIntlPrefix = "+46"                 #ADD YOUR Value
$ClientContactDetail.Phone = "1234567"                       #ADD YOUR Value
#Send back to message
$ClientCreateMessage.Contact = $ClientContactDetail

write-host "Client Address"
$ClientAddress = New-Object "profiles.Address"
$ClientAddress.Address1 = "Street 1"                        #ADD YOUR Value
$ClientAddress.City = "Stockholm"                           #ADD YOUR Value
$ClientAddress.PostalCode = "12345"                         #ADD YOUR Value
$ClientAddress.CountryCode = "SWE"                          #ADD YOUR Value
$ClientAddress.Province = "SWE"                             #ADD YOUR Value - ONLY used for NON US Countries
#$ClientAddress.State = "CO"                                #ADD YOUR Value - ONLY used for When Country is US
$ClientAddress.TimeZone = "CEURPSWEDN"                      #ADD YOUR Value
#Send back to message
$ClientCreateMessage.Contact.Address = $ClientAddress

Write-Host "`n----------------------------------------------------------------"
Write-Host "LogOn and save to LogOnResult"
$LogOnResult = $Proxy_Security.LogOn($LogOnMessage)

Write-Host "CreateClient and save to ClientCreateResult`n"
$ClientCreateResult = $Proxy_ProvisioningProfiles.ClientCreate($ClientCreateMessage)
#Write-Host "Token: "$LogOnResult.Token
Write-Host "Created ClientId: " $ClientCreateResult.ClientId
#Write-Host "MessageId: " $ClientCreateResult.MessageId


Write-Host "`n----------------------------------------------------------------"
write-host "Define ReservationCreate Message"

$ReservationCreateMessage = New-Object "services.ReservationCreateMessage"

$ReservationCreateMessage.Token = $LogOnResult.Token
$ReservationCreateMessage.CorrelationId = $LogOnResult.CorrelationId
$ReservationCreateMessage.SendEmail = 0                                 #SET to 1 to send email to Client with conference details
$ReservationCreateMessage.SendEmailSpecified = 1                        
$ReservationCreateMessage.ClientId = $ClientCreateResult.ClientId

Write-Host "`nDefine BridgeOptionCodes"
$ReservationCreateMessage.BridgeOptionCodes = "GlobalMeet2"

Write-Host "`nDefine ConferenceOptionCodes"
#$ReservationCreateMessage.ConferenceOptionCodes = ""                   #NO Specific ConferenceOptionCodes for Lync Audio Accounts

Write-Host "`nDefine PasscodeRequirements"
$PasscodeRequirements = New-Object "services.ReservationPassCodeRequirements"
$PasscodeRequirements.SecurePassCodes = 1                             
#Send PasscodeRequirements back to Message
$ReservationCreateMessage.PassCodeRequirements = $PasscodeRequirements

Write-Host "`nDefine ReservationDetails"
$ReservationDetails = New-Object "services.ReservationDetails"
$ReservationDetails.ConferenceName = "Lync Audio Conference"            #ADD YOUR Value
$ReservationDetails.Email = "mattias@pgi.com"                           #ADD YOUR Value
$ReservationDetails.IsClientDefault = 1                                
$ReservationDetails.IsClientDefaultSpecified = 1
$ReservationDetails.ModeratorName = $ClientContactDetail.FirstName + $ClientContactDetail.LastName
$ReservationDetails.POCC = $ClientBillingDetails.POCC                   #Will pull POCC from Client, set to a value if different
$ReservationCreateMessage.Reservation = $ReservationDetails

Write-Host "`nDefine ReservationSchedule"
$ReservationSchedule = New-Object "services.ReservationSchedule"
$ReservationSchedule.TimeZoneCode = "CEURPSWEDN"                        #ADD YOUR Value
$ReservationCreateMessage.Schedule = $ReservationSchedule

Write-Host "`n----------------------------------------------------------------"
write-host "Call ReservationCreate"

$ReservationCreateResult = $Proxy_ProvisioningServices.ReservationCreate($ReservationCreateMessage)

Write-Host "ConferenceId: "$ReservationCreateResult.ConfId
Write-Host "PPasscode: "$ReservationCreateResult.PassCodes.ParticipantPassCode
