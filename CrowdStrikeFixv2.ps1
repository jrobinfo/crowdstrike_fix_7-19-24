[CmdletBinding()]
param()

# Function to write log messages
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"
    Add-Content -Path "$env:TEMP\CrowdStrikeFixLog.txt" -Value $logMessage
    if ($Verbose) {
        Write-Host $logMessage
    }
}

# Function to check if running in Safe Mode
function Test-SafeMode {
    return (Get-WmiObject Win32_ComputerSystem).BootupState -ne "Normal boot"
}

# Function to check and delete the problematic file
function Remove-ProblematicFile {
    param(
        [string]$FilePath,
        [bool]$InSafeMode
    )
    $userConfirmation = Read-Host "Do you want to delete this file? (Y/N)"
    if ($userConfirmation -eq "Y" -or $userConfirmation -eq "y") {
        try {
            Remove-Item $FilePath -Force
            Write-Host "File deleted successfully." -ForegroundColor Green
            Write-Log "File deleted successfully."
            if ($InSafeMode) {
                Write-Host "Since you're in Safe Mode, please restart your computer in normal mode to complete the fix." -ForegroundColor Yellow
                Write-Log "Advised restart from Safe Mode."
            } else {
                Write-Host "Please reboot your system in normal mode to complete the fix." -ForegroundColor Yellow
                $rebootConfirmation = Read-Host "Do you want to reboot now? (Y/N)"
                if ($rebootConfirmation -eq "Y" -or $rebootConfirmation -eq "y") {
                    Write-Log "System reboot initiated."
                    Restart-Computer -Force
                } else {
                    Write-Host "Please remember to reboot your system as soon as possible." -ForegroundColor Yellow
                    Write-Log "Reboot postponed by user."
                }
            }
        } catch {
            Write-Host "Error deleting file: $_" -ForegroundColor Red
            Write-Log "Error deleting file: $_" -Level "ERROR"
            Write-Host "Please try to delete the file manually and then reboot your system." -ForegroundColor Yellow
        }
    } else {
        Write-Host "File was not deleted. Please note that your system may still be affected." -ForegroundColor Yellow
        Write-Log "User chose not to delete problematic file."
    }
}

# Main script execution
try {
    # Check if running with administrator privileges
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "Please run this script as an Administrator!"
        Write-Log "Script execution failed: No admin privileges" -Level "ERROR"
        Exit
    }

    Write-Log "Script started."

    $inSafeMode = Test-SafeMode
    if ($inSafeMode) {
        Write-Host "Running in Safe Mode. Proceeding with caution." -ForegroundColor Yellow
        Write-Log "Running in Safe Mode."
    }

    $filePath = "$env:windir\System32\drivers\CrowdStrike\C-00000291*.sys"
    $file = Get-Item $filePath -ErrorAction SilentlyContinue

    if ($null -eq $file) {
        Write-Host "The CrowdStrike Falcon Sensor file was not found. This system may not be affected." -ForegroundColor Green
        Write-Log "CrowdStrike file not found."
        Exit
    }

    $fileTimestamp = $file.CreationTime.ToUniversalTime()
    $criticalTimestamp = [DateTime]::ParseExact("2024-07-19 04:09:00", "yyyy-MM-dd HH:mm:ss", $null).ToUniversalTime()
    $fixedTimestamp = [DateTime]::ParseExact("2024-07-19 05:27:00", "yyyy-MM-dd HH:mm:ss", $null).ToUniversalTime()

    Write-Host "File found: $($file.Name)"
    Write-Host "File timestamp (UTC): $($fileTimestamp.ToString("yyyy-MM-dd HH:mm:ss"))"
    Write-Log "File found: $($file.Name), Timestamp: $($fileTimestamp.ToString("yyyy-MM-dd HH:mm:ss"))"

    if ($fileTimestamp -eq $criticalTimestamp) {
        Write-Host "WARNING: This file matches the timestamp of the problematic version." -ForegroundColor Red
        Write-Log "Problematic file version detected."
        Remove-ProblematicFile -FilePath $file.FullName -InSafeMode $inSafeMode
    } elseif ($fileTimestamp -ge $fixedTimestamp) {
        Write-Host "Good news! The file on this system appears to be the fixed version." -ForegroundColor Green
        Write-Host "No action is required."
        Write-Log "Fixed version detected, no action taken."
    } else {
        Write-Host "The file timestamp does not match known problematic or fixed versions." -ForegroundColor Yellow
        Write-Host "Please consult with your IT department for further guidance."
        Write-Log "Unknown file version detected."
    }

    Write-Host "Script execution complete. Press any key to exit."
    Write-Log "Script execution completed."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Write-Host "An unexpected error occurred: $_" -ForegroundColor Red
    Write-Log "An unexpected error occurred: $_" -Level "ERROR"
}