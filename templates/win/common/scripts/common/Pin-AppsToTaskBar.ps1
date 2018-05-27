
# This code has been adopted from https://gallery.technet.microsoft.com/scriptcenter/b66434f1-4b3f-4a94-8dc3-e406eb30b750
# and modified to be a single script to pin selected items to the taskbar.


function Set-PinnedApplication 
{ 
  param( 
    [Parameter(Mandatory=$true)][string]$Action,  
    [Parameter(Mandatory=$true)][string]$FilePath 
  )


  $verbs = @{  
    "PintoStartMenu"=5381
    "UnpinfromStartMenu"=5382 
    "PintoTaskbar"=5386 
    "UnpinfromTaskbar"=5387
    }
    function InvokeVerb { 
        param([string]$FilePath,$verb) 
        $verb = $verb.Replace("&","") 
        $path= split-path $FilePath 
        $shell=new-object -com "Shell.Application"  
        $folder=$shell.Namespace($path)    
        $item = $folder.Parsename((split-path $FilePath -leaf)) 
        $itemVerb = $item.Verbs() | ? {$_.Name.Replace("&","") -eq $verb} 
        if($itemVerb -eq $null){ 
            throw "Verb $verb not found."
        } else { 
            $itemVerb.DoIt() 
        } 
    } 
    function GetVerb { 
        param([int]$verbId) 
        try { 
            $t = [type]"CosmosKey.Util.MuiHelper" 
        } catch { 
            $def = [Text.StringBuilder]"" 
            [void]$def.AppendLine('[DllImport("user32.dll")]') 
            [void]$def.AppendLine('public static extern int LoadString(IntPtr h,uint id, System.Text.StringBuilder sb,int maxBuffer);') 
            [void]$def.AppendLine('[DllImport("kernel32.dll")]') 
            [void]$def.AppendLine('public static extern IntPtr LoadLibrary(string s);') 
            add-type -MemberDefinition $def.ToString() -name MuiHelper -namespace CosmosKey.Util             
        } 
        if($global:CosmosKey_Utils_MuiHelper_Shell32 -eq $null){         
            $global:CosmosKey_Utils_MuiHelper_Shell32 = [CosmosKey.Util.MuiHelper]::LoadLibrary("shell32.dll") 
        } 
        $maxVerbLength=255 
        $verbBuilder = new-object Text.StringBuilder "",$maxVerbLength 
        [void][CosmosKey.Util.MuiHelper]::LoadString($CosmosKey_Utils_MuiHelper_Shell32,$verbId,$verbBuilder,$maxVerbLength) 
        return $verbBuilder.ToString() 
    } 


  if(-not (test-path $FilePath)) {  
     throw "FilePath does not exist."   
  } 

  if($verbs.$Action -eq $null){ 
     Throw "Action $action not supported`nSupported actions are:`n`tPintoStartMenu`n`tUnpinfromStartMenu`n`tPintoTaskbar`n`tUnpinfromTaskbar" 
  }

  InvokeVerb -FilePath $FilePath -Verb $(GetVerb -VerbId $verbs.$action) 
} 

# Unable to get File Explorer or Documents pinned, so start with these apps initially.
Set-PinnedApplication -Action PintoTaskbar -FilePath "$ENV:ProgramFiles\Notepad++\Notepad++.exe"
Set-PinnedApplication -Action PintoTaskbar -FilePath "$ENV:Windir\system32\WindowsPowerShell\v1.0\powershell.exe"
