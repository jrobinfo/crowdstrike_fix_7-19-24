@echo off
setlocal enabledelayedexpansion

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please right-click on the script and select "Run as administrator".
    pause
    exit /b 1
)

:: Set up logging
set "LOGFILE=%TEMP%\CrowdStrikeFixLog.txt"
call :LOG "Script started."

:: Detect Safe Mode
set "SafeMode="
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /C:"Boot Mode"') do set "BootMode=%%a"
if "!BootMode!"==" Normal boot" (
    set "SafeMode=0"
) else (
    set "SafeMode=1"
    echo Running in Safe Mode. Proceeding with caution.
    call :LOG "Running in Safe Mode."
)

:: Set the file path
set "FilePath=%windir%\System32\drivers\CrowdStrike\C-00000291*.sys"

:: Check if any matching files exist
forfiles /P "%windir%\System32\drivers\CrowdStrike" /M "C-00000291*.sys" /C "cmd /c exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    echo The CrowdStrike Falcon Sensor file was not found. This system may not be affected.
    call :LOG "CrowdStrike file not found."
    pause
    exit /b 0
)

:: Process each matching file
for /f "delims=" %%F in ('dir /b /a-d "%FilePath%"') do (
    set "FullPath=%windir%\System32\drivers\CrowdStrike\%%F"
    echo File found: %%F
    call :LOG "File found: %%F"

    :: Get file creation time in UTC
    for /f "tokens=2 delims==." %%a in ('wmic datafile where name^="%FullPath:\=\\%" get CreationDate /value') do set "FileTimestamp=%%a"
    set "FileYear=!FileTimestamp:~0,4!"
    set "FileMonth=!FileTimestamp:~4,2!"
    set "FileDay=!FileTimestamp:~6,2!"
    set "FileHour=!FileTimestamp:~8,2!"
    set "FileMinute=!FileTimestamp:~10,2!"
    
    echo File timestamp (UTC): !FileYear!-!FileMonth!-!FileDay! !FileHour!:!FileMinute!
    call :LOG "File timestamp (UTC): !FileYear!-!FileMonth!-!FileDay! !FileHour!:!FileMinute!"

    :: Set comparison timestamps
    set "CriticalTimestamp=20240719041000"
    set "FixedTimestamp=20240719052700"
    set "CurrentTimestamp=!FileYear!!FileMonth!!FileDay!!FileHour!!FileMinute!00"

    if !CurrentTimestamp! equ %CriticalTimestamp% (
        echo WARNING: This file exactly matches the timestamp of the known problematic version.
        call :LOG "Problematic file version detected."
        call :REMOVE_FILE "!FullPath!"
    ) else if !CurrentTimestamp! lss %FixedTimestamp% (
        echo WARNING: This file was created before the fixed version and needs to be deleted.
        call :LOG "Pre-fix version detected, needs deletion."
        call :REMOVE_FILE "!FullPath!"
    ) else (
        echo Good news! This file was created after or very close to when the fixed version was released.
        echo No action is required for this file.
        call :LOG "Post-fix or close to fix version detected, no action needed."
    )
)

echo Script execution complete. Press any key to exit.
call :LOG "Script execution completed."
pause
exit /b 0

:: Logging function
:LOG
echo %DATE% %TIME% - %~1 >> "%LOGFILE%"
exit /b 0

:: File removal function
:REMOVE_FILE
set /p "Confirmation=Do you want to delete this file? (Y/N): "
if /i "%Confirmation%"=="Y" (
    del "%~1" 2>nul
    if not exist "%~1" (
        echo File deleted successfully.
        call :LOG "File deleted successfully."
        if "%SafeMode%"=="1" (
            echo Since you're in Safe Mode, please restart your computer in normal mode to complete the fix.
            call :LOG "Advised restart from Safe Mode."
        ) else (
            echo Please reboot your system in normal mode to complete the fix.
            set /p "Reboot=Do you want to reboot now? (Y/N): "
            if /i "%Reboot%"=="Y" (
                call :LOG "System reboot initiated."
                shutdown /r /t 5 /c "Rebooting to complete CrowdStrike fix"
            ) else (
                echo Please remember to reboot your system as soon as possible.
                call :LOG "Reboot postponed by user."
            )
        )
    ) else (
        echo Error deleting file. Please try to delete the file manually and then reboot your system.
        call :LOG "Error deleting file." 
    )
) else (
    echo File was not deleted. Please note that your system may still be affected.
    call :LOG "User chose not to delete problematic file."
)
exit /b 0