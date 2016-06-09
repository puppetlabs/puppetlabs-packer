@ECHO OFF
SETLOCAL

SET LOGFILE=%SYSTEMROOT%\TEMP\SetupComplete.cmd.log
ECHO SetupComplete.cmd started %date% %time% >> %LOGFILE%

REM Turn on the WinRM firewall exception
REM This allows Packer to connect via WinRM and then initiate shutdown
ECHO Enabling WinRM Service... >> %LOGFILE%
sc config winrm start= automatic >> %LOGFILE%

ECHO Starting the WinRM Service... >> %LOGFILE%
NET START WinRM >> %LOGFILE%

ECHO Enabling Firewall Rule for WinRM... >> %LOGFILE%
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=allow >> %LOGFILE%