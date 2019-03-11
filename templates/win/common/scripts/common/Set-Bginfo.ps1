param (
    [string]$VMPlatform = "vmpooler"
)

# User Script to display useful VMData in on the desktop using BGInfo

. C:\Packer\Scripts\windows-env.ps1

$BGIFile = "C:\Packer\Config\VMPooler.bgi"
$VMHostname = hostname

Switch ($VMPlatform) {
  "vmpooler" {
    $PoolerApiURL = "http://vmpooler.delivery.puppetlabs.net/api/v1/vm/"

    # Query the pooler to pick up attributes on this session.
    # Using PS2 compatible code here (Invoke-Restmethod ins't available until PS3) 
    $WebRequest = [System.Net.WebRequest]::Create("$PoolerApiURL/$VMHostname")
    $WebRequest.Method = "GET"
    $WebRequest.ContentType = "application/json"
    $Response = $WebRequest.GetResponse()
    $ResponseStream = $Response.GetResponseStream()
    $ReadStream = New-Object System.IO.StreamReader $ResponseStream

    [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
    $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $PoolerData = $ser.DeserializeObject($ReadStream.ReadToEnd())

    $Lifetime = $PoolerData.$VMHostname.lifetime
    $ENV:VMPOOLER_Lifetime = "$Lifetime hours"

    # Get Remaining time in seconds - display short format same as bginfo time
    $RemainingTime = [Math]::Floor([decimal](($Lifetime - $PoolerData.$VMHostname.running)*3600))
    $ENV:VMPOOLER_Expiry_Time = Get-Date (Get-Date).AddSeconds($RemainingTime) -format "yyyy-MM-dd HH:mm zzz"

    # Work out expiry in hours by subtracting runing time.
    $ENV:VMPOOLER_Template_Name = $PoolerData.$VMHostname.template
    break
  }
  "Platform9" {
    $ENV:VMPOOLER_Template_Name = $PoolerData.$VMHostname.template
    $BGIFile = "C:\Packer\Config\Platform9.bgi"
    break
  }
  default {break}
}

# Get last boot time (also in ISO Format)
$ENV:VMPOOLER_LastBootTime = Get-Date ((Get-WmiObject win32_operatingsystem -ComputerName $VMHostname| select @{LABEL="LastBootUpTime";EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}).LastBootUpTime) -format "yyyy-MM-dd HH:mm zzz"

if ( Test-Path "$ENV:CYGWINDIR\bin\sh.exe" ) {
    # Cygwin version
    $CygWinShell = "$ENV:CYGWINDIR\bin\sh.exe"
    $ENV:VMPOOLER_Cygwin_Version = & $CygWinShell --login -c "uname -r"
}

# Run BGInfo to display data using bginfo file in C:\Packer\Config

bginfo.exe $BGIFile /timer:0 /nolicprompt /silent

# So long farewell, Auf Wiedersehn, Goodbye
