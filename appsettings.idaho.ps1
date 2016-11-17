Param(
    [string]$AppName,
    [string]$ResourceGroup
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
$hash['ClientStateName'] = "Idaho"
$hash['WEBSITE_TIME_ZONE'] = "Mountain Standard Time"
$hash['ASPNETCORE_ENVIRONMENT'] = "Development"

Write-Host("Setting AppSettings on WebApp")
Set-AzureRMWebAppSlot -ResourceGroupName $ResourceGroup -Name $AppName -AppSettings $hash -Slot production
