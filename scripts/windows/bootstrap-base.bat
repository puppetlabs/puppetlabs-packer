@ECHO OFF

SETLOCAL

SET LOGFILE=%WINDIR%\TEMP\bootstrap-base.bat.log

ECHO Script Started >> %LOGFILE%

ECHO Setting PS Execution policy to RemoteSigned (Native) >> %LOGFILE%
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" >> %LOGFILE%

ECHO Setting PS Execution policy to RemoteSigned (32bit on 64bit OS) >> %LOGFILE%
C:\Windows\SysWOW64\cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force" >> %LOGFILE%