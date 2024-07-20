@echo off
setlocal enabledelayedexpansion

echo Script started.

:: Detect Safe Mode
set "SafeMode=0"
systeminfo | findstr /B /C:"Boot Mode" | findstr /C:"Safe Mode" >nul && set "SafeMode=1"
if "%SafeMode%"=="1" (
    echo Running in Safe Mode. Proceeding with caution.
)

:: Set the file path
set "FilePath=%windir%\System32\drivers\CrowdStrike\C-00000291*.sys"

:: Check if any matching files exist
if not exist "%FilePath%" (
    echo The CrowdStrike Falcon Sensor file was not found. This system may not be affected.
    pause
    exit /b 0
)

:: Process each matching file
for %%F in ("%FilePath%") do (
    echo File found: %%~nxF
)

echo Script execution complete. Press any key to exit.
pause
exit /b 0