<#
.SYNOPSIS
  Registers device info to an Azure Automation webhook for Windows Autopilot.
.NOTES
  Author: Internal IT Infrastructure Team / Adapted for demo by Joaquin Antonio Corona Rangel
  Based on the work of Viktor Sjögren / https://www.smthwentright.com/
  Webhook expiration date: EXAMPLE_DATE (same as secret expiration)
  Disclaimer: Demo/portfolio version. No production secrets included.
#>

# --- Settings & Safety ---
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- Variables (placeholders for demo) ---
$GroupTag        = 'AAD'
$WebHookUrl      = 'EXAMPLE_URL'
$WebhookPassword = 'EXAMPLE_PASS'

# --- Logging (ProgramData is cleaner than Temp for real-world) ---
$LogRoot   = Join-Path $env:ProgramData 'AutopilotLogs'
$null = New-Item -ItemType Directory -Path $LogRoot -Force -ErrorAction SilentlyContinue
$LogFile   = Join-Path $LogRoot ("AutopilotDeviceUpload_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

Start-Transcript -Path $LogFile -Append | Out-Null
Write-Host (Get-Date)

# --- Admin / context check (optional) ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
  Write-Warning "Script is not running elevated. Some queries may fail."
}

try {
  Write-Host "Gathering device info..."
  # Device Hash (CIM)
  $dev = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_DevDetail_Ext01 `
         -Filter "InstanceID='Ext' AND ParentID='./DevDetail'"
  $DeviceHashData = $dev.DeviceHardwareData

  # Serial Number (CIM)
  $bios = Get-CimInstance -ClassName Win32_BIOS
  $SerialNumber = $bios.SerialNumber

  # Build payload (omit ProductKey in public/demo)
  $body = @{
    SerialNumber    = $SerialNumber
    DeviceHashData  = $DeviceHashData
    GroupTag        = $GroupTag
  }

  # Validate minimal fields
  foreach ($k in 'SerialNumber','GroupTag','DeviceHashData') {
    if (-not $body[$k]) { throw "Missing required field: $k" }
  }

  $params = @{
    ContentType = 'application/json'
    Headers     = @{
      'from'    = 'AutoPilotDeviceInfo'
      'date'    = (Get-Date).ToString('o')
      'message' = $WebhookPassword
    }
    Body        = ($body | ConvertTo-Json -Depth 4)
    Method      = 'Post'
    Uri         = $WebHookUrl
  }

  Write-Host "Sending payload to webhook..."
  $response = Invoke-RestMethod @params
  Write-Host "Autopilot info successfully sent."
  Start-Sleep -Seconds 30
}
catch {
  Write-Warning "Failed to send Autopilot info: $($_.Exception.Message)"
  # Return non-zero for automation pipelines if you want:
  # exit 1
}
finally {
  Stop-Transcript | Out-Null
}
