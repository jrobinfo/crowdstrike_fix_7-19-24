@echo off
setlocal enabledelayedexpansion

:: Check for admin privileges
@REM NET SESSION >nul 2>&1
@REM if %errorLevel% neq 0 (
@REM     echo This script requires administrator privileges.
@REM     echo Please right-click on the script and select "Run as administrator".
@REM     pause
@REM     exit /b 1
@REM )

:: Detect Safe Mode
set "SafeMode="
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /C:"Boot Mode"') do set "BootMode=%%a"
if "!BootMode!"==" Normal boot" (
    set "SafeMode=0"
) else (
    set "SafeMode=1"
    echo Running in Safe Mode. Proceeding with caution.
)

:: Set the file path
set "FilePath=%windir%\System32\drivers\CrowdStrike\C-00000291*.sys"

:: Check if the file exists
if not exist "%FilePath%" (
    echo The CrowdStrike Falcon Sensor file was not found. This system may not be affected.
    pause
    exit /b 0
)

:: Get file creation time in UTC
for /f "tokens=2 delims==" %%a in ('wmic datafile where name^="%FilePath:\=\\%" get CreationDate /value') do set "FileDate=%%a"
set "FileYear=%FileDate:~0,4%"
set "FileMonth=%FileDate:~4,2%"
set "FileDay=%FileDate:~6,2%"
set "FileHour=%FileDate:~8,2%"
set "FileMinute=%FileDate:~10,2%"

echo File found: %FilePath%
echo File creation date (UTC): %FileYear%-%FileMonth%-%FileDay% %FileHour%:%FileMinute%

set "ProblematicTimestamp=2024-07-19 04:09"
set "FixedTimestamp=2024-07-19 05:27"

set "FileTimestamp=%FileYear%-%FileMonth%-%FileDay% %FileHour%:%FileMinute%"

if "%FileTimestamp%" lss "%ProblematicTimestamp%" (
    echo This file predates the problematic version. No action needed.
) else if "%FileTimestamp%" geq "%FixedTimestamp%" (
    echo Good news! The file on this system appears to be the fixed version.
    echo No action is required.
) else (
    echo WARNING: This file matches the timestamp of the problematic version.
    set /p "Confirmation=Do you want to delete this file? (Y/N): "
    if /i "!Confirmation!"=="Y" (
        del "%FilePath%" 2>nul
        if not exist "%FilePath%" (
            echo File deleted successfully.
            if "!SafeMode!"=="1" (
                echo Since you're in Safe Mode, please restart your computer in normal mode to complete the fix.
            ) else (
                echo Please reboot your system in normal mode to complete the fix.
                set /p "Reboot=Do you want to reboot now? (Y/N): "
                if /i "!Reboot!"=="Y" (
                    shutdown /r /t 5 /c "Rebooting to complete BSOD fix"
                ) else (
                    echo Please remember to reboot your system as soon as possible.
                )
            )
        ) else (
            echo Error deleting file. Please try to delete the file manually and then reboot your system.
        )
    ) else (
        echo File was not deleted. Please note that your system may still be affected.
    )
)

echo Script execution complete.
pause