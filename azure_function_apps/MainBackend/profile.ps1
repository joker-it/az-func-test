# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using MSI.
# Remove this if you are not planning on using MSI or Azure PowerShell.
if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity
}

#Load BetterCollab Config File
try {
    $env:BETTERCOLLAB_CONFIG = Get-Content -Raw -Path C:\home\site\wwwroot\config\config.json
    Write-Information "BetterCollab Config initiated"
} catch {
    Write-Log $PSItem.ToString()
    Write-Error -Message "Import of BetterCollab Config failed" -ErrorAction Stop
}

#Load BetterCollab Powershell Module
try {
    Import-Module C:\home\site\wwwroot\Modules\BetterCollab.psm1
    Write-Information "BetterCollab Moule imported"
} catch {
    Write-Log $PSItem.ToString()
    Write-Error -Message "Import BetterCollab Module failed" -ErrorAction Stop
}

#Load PnP Powershell Module
try {
    Import-Module PnP.PowerShell
} catch {
    Write-Log $PSItem.ToString()
    Write-Error -Message "Import PNP Powershell Module failed" -ErrorAction Stop
}

function Get-ConfigFromEnvironment {
    $config = $env:BETTERCOLLAB_CONFIG | ConvertFrom-Json

    if($env:serviceaccount){
        $config.serviceaccount = $env:serviceaccount
    }
    return $config
}

function Get-GraphAPIToken {
    try {
        $bettercollabClientId = $env:clientId
        $bettercollabTenantId = $env:tenantId
        $bettercollabThumbprint = $env:thumbprint
        $token = Connect-GraphAPIWithCertificate -AppID $bettercollabClientId -TenantID $bettercollabTenantId -CertificatePath "Cert:\CurrentUser\My\$bettercollabThumbprint" -Scope ".default"
        Write-Information "Graph API Token successfully fetched" 
        return $token
    } catch {
        Write-Error -Message "Connection to GraphAPI failed" -ErrorAction Stop
    }   
}

# Setting Environmental Variables
$env:BETTERCOLLAB_TEAMS_SETTINGS_PATH = "C:\home\site\wwwroot\config\templates\TeamSettings.json"

# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.