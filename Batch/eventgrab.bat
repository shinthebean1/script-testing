@echo off
setlocal enabledelayedexpansion

title System Event Grabber

set logfile=%temp%\eventlogs_%random%
set systemeventfile=%logfile%\SystemEvents.evtx
set applicationeventfile=%logfile%\ApplicationEvents.evtx
set ziptar=%temp%\EventLogs_%random%.zip

if not exist %logfile% mkdir %logfile%

echo Grabbing System Events..
wevtutil epl System !systemeventfile! >nul 2>&1
wevtutil epl Application !applicationeventfile! >nul 2>&1
echo.

powershell -ExecutionPolicy Bypass -Command "Compress-Archive -Path !logfile!\* -DestinationPath !ziptar!"

:filecheck
if exist !ziptar! (
    del /q /f !logfile!\*
    rmdir !logfile!
) else (
    goto filecheck
)

if exist %ziptar% (
    powershell -ExecutionPolicy Bypass -Command "Set-Clipboard -Path !ziptar!"
    echo ------------------------------
    echo  FILES ARE READY TO BE SHARED
    echo ------------------------------
    start explorer.exe !ziptar!
    echo Press any key to exit..
    pause > nul
    exit
)

echo A event type or archive failed to create/export.
echo Press any key to exit..
pause > nul
exit