Param(
    [string]$AppName,
    [string]$ResourceGroup,
    [string]$ClientStateName = "Idaho",
    [string]$TimeZone = "Mountain Standard Time",
    [string]$Environment = "Development"
    [string]$LoggingSeqKey = $null
    [string]$LoggingSeqServerUri = $null
)

Write-Host("Connecting to WebApp")
$webApp = Get-AzureRMWebAppSlot -ResourceGroupName $ResourceGroup -Name $AppName -Slot production

Write-Host("Reading AppSettings")
$appSettingList = $webApp.SiteConfig.AppSettings


$hash = @{}
ForEach ($kvp in $appSettingList) {
    $hash[$kvp.Name] = $kvp.Value
}

Write-Host("Writing ClientStateName, WEBSITE_TIME_ZONE, and ASPNETCORE_ENVIRONMENT")
$hash['ClientStateName'] = $ClientStateName
$hash['WEBSITE_TIME_ZONE'] = $TimeZone
$hash['ASPNETCORE_ENVIRONMENT'] = $Environment
$hash['Data:Logging:ApplicationName'] = $AppName
$hash['Data:Logging:EnvironmentName'] = $Environment

if ($LoggingSeqKey) 
{
	$hash['Data:Logging:SeqApiKey'] = $LoggingSeqKey
}
if ($LoggingSeqServerUri) 
{
	$hash['Data:Logging:SeqServerUri'] = $LoggingSeqServerUri
}


Write-Host("Setting AppSettings on WebApp")
Set-AzureRMWebAppSlot -ResourceGroupName $ResourceGroup -Name $AppName -AppSettings $hash -Slot production
