@ECHO OFF
SETLOCAL

SET LOGFILE=%SYSTEMROOT%\TEMP\generalize-packer.bat.log

ECHO generalize-packer.bat started %date% %time% >> %LOGFILE%

REM Service needs to be disabled, not stopped as it halts
REM Packer if WinRM is suddenly stopped from underneath it
ECHO Disabling the WinRM via service...  >> %LOGFILE%
sc config winrm start= disabled >> %LOGFILE%

ECHO Initiating sysprep...  >> %LOGFILE%
C:/windows/system32/sysprep/SYSPREP.exe /generalize /oobe /unattend:A:\generalize-packer.autounattend.xml /quiet /shutdown

EXIT /B %ERRRORLEVEL%