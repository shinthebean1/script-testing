@echo off

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
echo Set UAC = CreateObject("Shell.Application") > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
cls
echo Command Prompt is required to be an Administrator for this to run.
echo Closing in 3 seconds.
timeout 3 > nul
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"

	del /s /q /f %temp%\* > nul 2>&1
	rd /s /q %temp% > nul 2>&1
	mkdir %temp% > nul 2>&1

:menu
cls
echo -------------------------------------
echo     PC CLEANUP PERFORMANCE TWEAKS
echo -------------------------------------
echo.
echo.
echo Select a tool to perform
echo ========================
echo.
echo [1] Enable or Disable GPU Scheduling
echo [2] Run System File Scan
echo [3] Disable Startup Apps
echo [4] Restart PC
echo [5] Exit
echo.

set /p opt="Select an option:" 
if %opt%==1 (
goto 1
)
if %opt%==2 (
goto 2
)
if %opt%==3 (
goto 3
)
if %opt%==4 (
goto 4
)
if %opt%==5 (
echo Exiting..
timeout 2 > nul
exit
)

echo The option you chose isn't an option
echo Please select a valid option
echo.
echo Press any key to go back to the menu.
pause > nul
goto menu

:: Choice 2
:1
echo.
echo Type 1 to Enable GPU Scheduling
echo Type 2 to Disable GPU Scheduling
echo --------------------------------
echo.
set /p gpuch="Select 1 or 2: "
if "%gpuch%"=="1" goto EnableGPU
if "%gpuch%"=="2" goto DisableGPU

:EnableGPU
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
echo.
echo Hardware Accelerated GPU Scheduling has been enabled
echo Restart your PC for changes to apply.
pause
goto menu

:DisableGPU
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers /v HwSchMode /t REG_DWORD /d 1 /f >nul 2>&1
echo.
echo Hardware Accelerated GPU Scheduling has been disabled
echo Restart your PC for changes to apply.
pause
goto menu

:: Choice 4
:2
echo Performing System File Scan..
sfc /scannow
echo.
SFC has finished, restarting your PC is recommended.
echo.
choice /c YN /m "Do you wish to restart your PC now?"
if errorlevel 2 goto c4nr
shutdown /r /t 0

:c4nr
cls
goto menu
