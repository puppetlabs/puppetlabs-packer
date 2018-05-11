' It seems amazing that we still need to use VBS For some things in the year 2018 AD
' However, Powershell insists on popping up a window (which grabs focus) every time the
' bginfo scheduled task runs
' See Ref: https://www.faqforge.com/windows/how-to-execute-powershell-scripts-without-pop-up-window/

command = "powershell.exe -nologo -WindowStyle Hidden -NonInteractive -command C:\Packer\Scripts\Set-Bginfo.ps1"
 set shell = CreateObject("WScript.Shell")
 shell.Run command,0
