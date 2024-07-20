@echo off
setlocal enabledelayedexpansion

:: Set up logging
set "LOGFILE=%TEMP%\CrowdStrikeFixLog.txt"
echo %DATE% %TIME% - Script started. >> "%LOGFILE%"

echo Script started.

:: Detect Safe Mode
set "SafeMode=0"
systeminfo | findstr /B /C:"Boot Mode" | findstr /C:"Safe Mode" >nul && set "SafeMode=1"
if "%SafeMode%"=="1" (
    echo Running in Safe Mode. Proceeding with caution.
    echo %DATE% %TIME% - Running in Safe Mode. >> "%LOGFILE%"
)

:: Set the file path
set "FilePath=%windir%\System32\drivers\CrowdStrike\C-00000291*.sys"

:: Check if any matching files exist
if not exist "%FilePath%" (
    echo The CrowdStrike Falcon Sensor file was not found. This system may not be affected.
    echo %DATE% %TIME% - CrowdStrike file not found. >> "%LOGFILE%"
    pause
    exit /b 0
)

:: Set comparison timestamps
set "CriticalTimestamp=20240719041000"
set "FixedTimestamp=20240719052700"

:: Process each matching file
for %%F in (%FilePath%) do (
    echo File found: %%~nxF
    echo %DATE% %TIME% - File found: %%~nxF >> "%LOGFILE%"

    :: Get file creation time in UTC
    for /f "tokens=2 delims==." %%a in ('wmic datafile where name^="%%~fF" get CreationDate /value') do set "FileTimestamp=%%a"
    
    if defined FileTimestamp (
        set "FileYear=!FileTimestamp:~0,4!"
        set "FileMonth=!FileTimestamp:~4,2!"
        set "FileDay=!FileTimestamp:~6,2!"
        set "FileHour=!FileTimestamp:~8,2!"
        set "FileMinute=!FileTimestamp:~10,2!"
        
        echo File timestamp (UTC): !FileYear!-!FileMonth!-!FileDay! !FileHour!:!FileMinute!
        echo %DATE% %TIME% - File timestamp (UTC): !FileYear!-!FileMonth!-!FileDay! !FileHour!:!FileMinute! >> "%LOGFILE%"

        set "CurrentTimestamp=!FileYear!!FileMonth!!FileDay!!FileHour!!FileMinute!00"

        if !CurrentTimestamp! equ %CriticalTimestamp% (
            echo WARNING: This file exactly matches the timestamp of the known problematic version.
            echo %DATE% %TIME% - Problematic file version detected. >> "%LOGFILE%"
            call :REMOVE_FILE "%%~fF"
        ) else if !CurrentTimestamp! lss %FixedTimestamp% (
            echo WARNING: This file was created before the fixed version and needs to be deleted.
            echo %DATE% %TIME% - Pre-fix version detected, needs deletion. >> "%LOGFILE%"
            call :REMOVE_FILE "%%~fF"
        ) else (
            echo Good news! This file was created after or very close to when the fixed version was released.
            echo No action is required for this file.
            echo %DATE% %TIME% - Post-fix or close to fix version detected, no action needed. >> "%LOGFILE%"
        )
    ) else (
        echo Error: Unable to get file timestamp for %%~nxF
        echo %DATE% %TIME% - Error: Unable to get file timestamp for %%~nxF >> "%LOGFILE%"
    )
)

echo Script execution complete. Press any key to exit.
echo %DATE% %TIME% - Script execution completed. >> "%LOGFILE%"
pause
exit /b 0

:: File removal function
:REMOVE_FILE
set /p "Confirmation=Do you want to delete this file? (Y/N): "
if /i "%Confirmation%"=="Y" (
    del "%~1" 2>nul
    if not exist "%~1" (
        echo File deleted successfully.
        echo %DATE% %TIME% - File deleted successfully. >> "%LOGFILE%"
        if "%SafeMode%"=="1" (
            echo Since you're in Safe Mode, please restart your computer in normal mode to complete the fix.
            echo %DATE% %TIME% - Advised restart from Safe Mode. >> "%LOGFILE%"
        ) else (
            echo Please reboot your system in normal mode to complete the fix.
            set /p "Reboot=Do you want to reboot now? (Y/N): "
            if /i "%Reboot%"=="Y" (
                echo %DATE% %TIME% - System reboot initiated. >> "%LOGFILE%"
                shutdown /r /t 5 /c "Rebooting to complete CrowdStrike fix"
            ) else (
                echo Please remember to reboot your system as soon as possible.
                echo %DATE% %TIME% - Reboot postponed by user. >> "%LOGFILE%"
            )
        )
    ) else (
        echo Error deleting file. Please try to delete the file manually and then reboot your system.
        echo %DATE% %TIME% - Error deleting file. >> "%LOGFILE%"
    )
) else (
    echo File was not deleted. Please note that your system may still be affected.
    echo %DATE% %TIME% - User chose not to delete problematic file. >> "%LOGFILE%"
)
exit /b 0