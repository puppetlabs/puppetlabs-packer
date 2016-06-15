@ECHO OFF
SETLOCAL

SET LOGFILE=%SYSTEMROOT%\TEMP\shutdown-packer.bat.log

ECHO shutdown-packer.bat started %date% %time% >> %LOGFILE%

REM Service needs to be disabled, not stopped as it halts
REM Packer if WinRM is suddenly stopped from underneath it
ECHO Disabling the WinRM via service...  >> %LOGFILE%
sc config winrm start= disabled >> %LOGFILE%

ECHO Initiating shutdown...  >> %LOGFILE%
shutdown /s /t 10 /f /d p:4:1 /c "Packer Shutdown"  >> %LOGFILE%

EXIT /B %ERRRORLEVEL%