@echo off
title DISM
echo Prompting UAC to user..
if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)
cls
echo                    Created by shinthebean for PC Help Hub Discord
echo                  Any issues/queries contact shinthebean on Discord
echo              https://github.com/PC-Help-Hub/pchh-main/tree/main/scripts 
echo                                Credits to: jheden
echo.
curl www.google.com >nul 2>&1
if %errorlevel% neq 0 (
echo No active Network Connection detected..
echo Unable to check for corruption.
echo Performing System File Check...
goto sfc
)

echo "DISM /Online /Cleanup-Image /ScanHealth"
DISM /Online /Cleanup-Image /ScanHealth
echo "DISM /Online /Cleanup-Image /StartComponentCleanup"
DISM /Online /Cleanup-Image /StartComponentCleanup
echo "DISM /Online /Cleanup-Image /RestoreHealth"
DISM /Online /Cleanup-Image /RestoreHealth
echo "sfc /scannow"
:sfc
sfc /scannow
echo.
echo "Script is complete, press any key to exit the script."
pause > nul
exit