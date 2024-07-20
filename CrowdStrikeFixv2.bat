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

:: Get file creation time
for /f "tokens=1-5 delims=/ " %%a in ('dir "%FilePath%" /tc ^| findstr /i /v "volume" ^| findstr /i /v "directory" ^| findstr /i /v "file(s)"') do (
    set "FileDate=%%a"
    set "FileTime=%%c"
    set "FileAMPM=%%d"
)

echo File found: %FilePath%
echo File creation date: %FileDate% %FileTime% %FileAMPM%

:: Convert to 24-hour format if needed
if /i "%FileAMPM%"=="PM" (
    for /f "tokens=1,2 delims=:" %%a in ("%FileTime%") do (
        set /a "Hour=%%a"
        if !Hour! neq 12 set /a "Hour+=12"
        set "FileTime=!Hour!:%%b"
    )
)

:: Remove leading zero from hour if present
set "FileTime=%FileTime: 0=%"

:: Set comparison timestamps
set "ProblematicTimestamp=07/19/2024 4:09"
set "FixedTimestamp=07/19/2024 5:27"

if "%FileDate% %FileTime%" lss "%ProblematicTimestamp%" (
    echo This file predates the problematic version. No action needed.
) else if "%FileDate% %FileTime%" geq "%FixedTimestamp%" (
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