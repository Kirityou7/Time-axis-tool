@echo off
set vspipe="D:\Han\Time\Vapoursynth_getkf_batch\Vapoursynth\VSPipe.exe"
set VSPIPE_LOG_LEVEL=2

:start
IF "%~1"=="" GOTO :End

"%vspipe%" -i -a "name=%~dp1%~nx1" -y "%~dp0get_kf.vpy" .
del "%~dp1%~nx1.lwi"

:then
SHIFT /1
GOTO :start

:End
::pause