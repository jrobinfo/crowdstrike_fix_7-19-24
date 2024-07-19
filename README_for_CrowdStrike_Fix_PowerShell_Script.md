# CrowdStrike Falcon Sensor Fix Script (PowerShell)

## Disclaimer

This script is provided "AS IS" without warranty of any kind, express or implied. The author and distributor of this script are not responsible for any damage or data loss that may occur from its use. Use of this script is at your own risk.

It is the sole responsibility of the end user to evaluate the script, understand its functionality, and determine its appropriateness for their environment. Always test scripts in a controlled environment before deploying them widely.

## Description

This PowerShell script is designed to address a specific issue with the CrowdStrike Falcon Sensor that may cause Windows systems to experience blue screen errors (BSODs). The script identifies and, if necessary, removes a problematic version of a CrowdStrike file, potentially resolving BSOD issues.

Key features:
- Checks for administrator privileges
- Detects if the system is running in Safe Mode
- Identifies the CrowdStrike Falcon Sensor file and its creation timestamp
- Compares the file timestamp to known problematic and fixed versions
- Offers to delete the problematic file if found
- Provides options for system reboot after file deletion
- Logs all actions taken
- Includes a verbose mode for detailed output

## How to Use

1. Download the `CrowdStrikeFixv2.ps1` file to the affected system.
2. Open PowerShell as an administrator.
3. Navigate to the directory containing the script.
4. Run the script using the following command:
   ```
   .\CrowdStrikeFixv2.ps1
   ```
   For verbose output, use:
   ```
   .\CrowdStrikeFixv2.ps1 -Verbose
   ```
5. Follow the on-screen prompts.
6. If prompted to delete a file, carefully consider the action before confirming.
7. Reboot the system when instructed, either through the script or manually.

## Requirements

- Windows operating system
- PowerShell 3.0 or later
- Administrator privileges
- CrowdStrike Falcon Sensor installed
- Execution policy that allows running PowerShell scripts (e.g., RemoteSigned or Unrestricted)

## Logging

The script creates a log file at `$env:TEMP\CrowdStrikeFixLog.txt`. Review this log for a detailed record of the script's actions.

## Important Notes

- This script should only be used on systems experiencing issues related to the specific CrowdStrike Falcon Sensor problem it addresses.
- Always ensure you have current backups before running system modification scripts.
- If you're unsure about using this script, consult with your IT department or CrowdStrike support.
- The script uses UTC times for comparison. Ensure your system's time and timezone settings are correct.

## Support

This script is not officially supported. If you encounter issues, please consult with your IT department or CrowdStrike support.

For more information about the issue this script addresses, refer to the official CrowdStrike documentation.

## Security Considerations

- The script requires administrator privileges to run.
- It only targets a specific CrowdStrike file in a system directory.
- User confirmation is required before any file deletion.
- No sensitive data or credentials are handled by the script.

Always review scripts before running them in your environment.