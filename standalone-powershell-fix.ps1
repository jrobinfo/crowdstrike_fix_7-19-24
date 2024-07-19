# Check if running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Please run this script as an Administrator!"
    Exit
}

# Function to check if running in Safe Mode
function Test-SafeMode {
    return (Get-WmiObject Win32_ComputerSystem).BootupState -eq "Normal boot" ? $false : $true
}

$inSafeMode = Test-SafeMode
if ($inSafeMode) {
    Write-Host "Running in Safe Mode. Proceeding with caution." -ForegroundColor Yellow
}

$filePath = "$env:windir\System32\drivers\CrowdStrike\C-00000291*.sys"
$file = Get-Item $filePath -ErrorAction SilentlyContinue

if ($file -eq $null) {
    Write-Host "The CrowdStrike Falcon Sensor file was not found. This system may not be affected." -ForegroundColor Green
    Exit
}

$fileTimestamp = $file.CreationTime.ToUniversalTime()
$criticalTimestamp = [DateTime]::ParseExact("2024-07-19 04:09:00", "yyyy-MM-dd HH:mm:ss", $null).ToUniversalTime()
$fixedTimestamp = [DateTime]::ParseExact("2024-07-19 05:27:00", "yyyy-MM-dd HH:mm:ss", $null).ToUniversalTime()

Write-Host "File found: $($file.Name)"
Write-Host "File timestamp (UTC): $($fileTimestamp.ToString("yyyy-MM-dd HH:mm:ss"))"

if ($fileTimestamp -eq $criticalTimestamp) {
    Write-Host "WARNING: This file matches the timestamp of the problematic version." -ForegroundColor Red
    $userConfirmation = Read-Host "Do you want to delete this file? (Y/N)"
    
    if ($userConfirmation -eq "Y" -or $userConfirmation -eq "y") {
        try {
            Remove-Item $file.FullName -Force
            Write-Host "File deleted successfully." -ForegroundColor Green
            if ($inSafeMode) {
                Write-Host "Since you're in Safe Mode, please restart your computer in normal mode to complete the fix."
            } else {
                Write-Host "Please reboot your system in normal mode to complete the fix."
                $rebootConfirmation = Read-Host "Do you want to reboot now? (Y/N)"
                if ($rebootConfirmation -eq "Y" -or $rebootConfirmation -eq "y") {
                    Restart-Computer -Force
                } else {
                    Write-Host "Please remember to reboot your system as soon as possible."
                }
            }
        } catch {
            Write-Host "Error deleting file: $_" -ForegroundColor Red
            Write-Host "Please try to delete the file manually and then reboot your system."
        }
    } else {
        Write-Host "File was not deleted. Please note that your system may still be affected."
    }
} elseif ($fileTimestamp -ge $fixedTimestamp) {
    Write-Host "Good news! The file on this system appears to be the fixed version." -ForegroundColor Green
    Write-Host "No action is required."
} else {
    Write-Host "The file timestamp does not match known problematic or fixed versions." -ForegroundColor Yellow
    Write-Host "Please consult with your IT department for further guidance."
}

Write-Host "Script execution complete. Press any key to exit."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")