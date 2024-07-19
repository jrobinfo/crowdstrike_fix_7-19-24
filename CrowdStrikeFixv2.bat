@echo off
setlocal enabledelayedexpansion

:: Set up logging
set "LogFile=%temp%\CrowdStrikeFixLog.txt"
echo %date% %time% - Script started > %LogFile%

:: Check for admin privileges
@REM NET SESSION >nul 2>&1
@REM if %errorLevel% neq 0 (
@REM     echo This script requires administrator privileges.
@REM     echo Please right-click on the script and select "Run as administrator".
@REM     echo %date% %time% - Script exited: No admin privileges >> %LogFile%
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
    echo %date% %time% - Running in Safe Mode >> %LogFile%
)

:: Set the file path
set "FilePath=%windir%\System32\drivers\CrowdStrike\C-00000291*.sys"

:: Check if the file exists
if not exist "%FilePath%" (
    echo The CrowdStrike Falcon Sensor file was not found. This system may not be affected.
    echo %date% %time% - CrowdStrike file not found >> %LogFile%
    pause
    exit /b 0
)

:: Get file creation time
for %%F in ("%FilePath%") do set "FileName=%%~nxF"
for /f "tokens=1-6 delims=/ " %%a in ('wmic path win32_utctime get /format:list ^| findstr "="') do (
    set %%a=%%b
    if "%%a"=="Year" set "UTCYear=%%b"
    if "%%a"=="Month" set "UTCMonth=%%b"
    if "%%a"=="Day" set "UTCDay=%%b"
    if "%%a"=="Hour" set "UTCHour=%%b"
    if "%%a"=="Minute" set "UTCMinute=%%b"
)
for /f "tokens=1-6 delims=/ " %%a in ('dir "%FilePath%" /tc ^| findstr /i /v "volume" ^| findstr /i /v "directory" ^| findstr /i /v "file(s)"') do (
    set "FileDate=%%a"
    set "FileTime=%%c"
)

echo File found: %FileName%
echo File creation date (local time): %FileDate% %FileTime%
echo Current UTC time: %UTCYear%-%UTCMonth%-%UTCDay% %UTCHour%:%UTCMinute%
echo %date% %time% - File found: %FileName%, Created: %FileDate% %FileTime% >> %LogFile%

:: Set known timestamps
set "ProblematicTimestamp=07/19/2024 04:09 AM"
set "FixedTimestamp=07/19/2024 05:27 AM"

:: Check if the file matches the problematic timestamp
if "%FileDate% %FileTime%"=="%ProblematicTimestamp%" (
    echo WARNING: This file matches the timestamp of the problematic version.
    set /p "Confirmation=Do you want to delete this file? (Y/N): "
    if /i "!Confirmation!"=="Y" (
        del "%FilePath%" 2>nul
        if not exist "%FilePath%" (
            echo File deleted successfully.
            echo %date% %time% - Problematic file deleted >> %LogFile%
            if "!SafeMode!"=="1" (
                echo Since you're in Safe Mode, please restart your computer in normal mode to complete the fix.
                echo %date% %time% - Advised restart from Safe Mode >> %LogFile%
            ) else (
                echo Please reboot your system in normal mode to complete the fix.
                set /p "Reboot=Do you want to reboot now? (Y/N): "
                if /i "!Reboot!"=="Y" (
                    echo %date% %time% - System reboot initiated >> %LogFile%
                    shutdown /r /t 5 /c "Rebooting to complete BSOD fix"
                ) else (
                    echo Please remember to reboot your system as soon as possible.
                    echo %date% %time% - Reboot postponed by user >> %LogFile%
                )
            )
        ) else (
            echo Error deleting file. Please try to delete the file manually and then reboot your system.
            echo %date% %time% - Error deleting file >> %LogFile%
        )
    ) else (
        echo File was not deleted. Please note that your system may still be affected.
        echo %date% %time% - User chose not to delete problematic file >> %LogFile%
    )
) else if "%FileDate% %FileTime%"=="%FixedTimestamp%" (
    echo Good news! The file on this system appears to be the fixed version.
    echo No action is required.
    echo %date% %time% - Fixed version detected, no action taken >> %LogFile%
) else (
    echo The file timestamp does not match known problematic or fixed versions.
    echo Please consult with your IT department for further guidance.
    echo %date% %time% - Unknown file version detected >> %LogFile%
)

echo Script execution complete.
echo %date% %time% - Script execution completed >> %LogFile%
pause