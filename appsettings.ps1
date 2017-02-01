Param(
    [string]$AppName,
    [string]$ResourceGroup,
    [string]$ClientStateName = "Idaho",
    [string]$TimeZone = "Mountain Standard Time",
    [string]$Environment = "Development",
    [string]$LoggingSeqKey = $null,
    [string]$LoggingSeqServerUri = $null,
    [bool]$VerifySqlConnectionExistance = $false
)

function CheckAppSetting
{
    Param([System.Object[]] $hash, [string] $keyName, [string] $expectedValue)

    Write-Host("Verifying AppSetting $keyName")
    if (!$hash.ContainsKey($keyName))
    {
        Write-Warning("$keyName is not set.  Updating to $expectedValue");
        $hash[$keyName] = $expectedValue;
    }
    else
    {
        $existingValue = $hash[$keyName];
        if($existingValue -ne $expectedValue)
        {
            Write-Warning("$keyName is not correct.  Updating from $existingValue to $expectedValue");
            $hahs[$keyName] = $expectedValue;
        }
    }

    return $hash;
}

Write-Host("Connecting to WebApp")
$webApp = Get-AzureRMWebAppSlot -ResourceGroupName $ResourceGroup -Name $AppName -Slot production

Write-Host("Reading AppSettings")
$appSettingList = $webApp.SiteConfig.AppSettings


$hash = @{}
ForEach ($kvp in $appSettingList) {
    $hash[$kvp.Name] = $kvp.Value
}

Write-Host("Verifying App Settings")
$hash = CheckAppSetting($hash, 'ClientStateName', $ClientStateName)
$hash = CheckAppSetting($hash, 'WEBSITE_TIME_ZONE', $TimeZone)
$hash = CheckAppSetting($hash, 'ASPNETCORE_ENVIRONMENT', $Environment)

if ($LoggingSeqKey) 
{
    $hash = CheckAppSetting($hash, 'Data:Logging:SeqApiKey', $LoggingSeqKey)
}
if ($LoggingSeqServerUri) 
{
    $hash = CheckAppSetting($hash, 'Data:Logging:SeqServerUri', $LoggingSeqServerUri)
}



#Write-Host("Setting AppSettings on WebApp")
#Set-AzureRMWebAppSlot -ResourceGroupName $ResourceGroup -Name $AppName -AppSettings $hash -Slot production
