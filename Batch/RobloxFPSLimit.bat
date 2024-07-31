@echo off
setlocal enabledelayedexpansion

set "rootDir=%USERPROFILE%\AppData\Local\Roblox\Versions"
set "recentFolder="
set "recentDate="

:beforesetFPS
set /p "fpsCap=Enter the FPS Cap (1-50000): "
rem Trim leading and trailing spaces
set "fpsCap=!fpsCap: =!"

rem Check if fpsCap is numeric and within range
echo !fpsCap!| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo FPS Cap value must be numerical.
    timeout 4 > nul
    goto beforesetFPS
)

rem Convert fpsCap to integer
set /a "fpsCap=fpsCap"

if !fpsCap! leq 0 (
    echo FPS cap must be greater than 0.
    echo Press any key to go back to the start.
    pause > nul
    goto beforesetFPS
)

if !fpsCap! gtr 50000 (
    echo FPS cap exceeds the maximum value of 50000.
    echo Press any key to go back to the start.
    pause > nul
    goto beforesetFPS
)

rem If validation passes, proceed to setting FPS cap
goto StartScript

:StartScript
for /f "delims=" %%D in ('dir /a:d /b /s /o:-d "%rootDir%" 2^>nul') do (
    set "folderDate=%%~tD"
    if not defined recentDate (
        set "recentDate=!folderDate!"
        set "recentFolder=%%D"
    )
    if !folderDate! gtr !recentDate! (
        set "recentDate=!folderDate!"
        set "recentFolder=%%D"
    )
)

if not defined recentFolder (
    echo Failed to find a recent Roblox version folder.
    pause
    exit /b 1
)

rem Ensure ClientSettings folder exists
if not exist "!recentFolder!\ClientSettings" (
    mkdir "!recentFolder!\ClientSettings" > nul 2>&1
    if errorlevel 1 (
        echo Failed to create ClientSettings folder.
        pause
        exit /b 1
    )
)

rem Write FPS cap value to ClientAppSettings.json
(
    echo {
    echo     "DFIntTaskSchedulerTargetFps": !fpsCap!
    echo }
) > "!recentFolder!\ClientSettings\ClientAppSettings.json"

if errorlevel 1 (
    echo Failed to create or update ClientAppSettings.json.
) else (
    echo Successfully set FPS Cap to !fpsCap!
    echo Restart Roblox for changes to apply.
)

pause > nul
