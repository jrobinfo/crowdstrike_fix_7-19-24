# CrowdStrike Falcon Sensor Fix Script (Batch)

## Disclaimer

This script is provided "AS IS" without warranty of any kind, express or implied. The author and distributor of this script are not responsible for any damage or data loss that may occur from its use. Use of this script is at your own risk.

It is the sole responsibility of the end user to evaluate the script, understand its functionality, and determine its appropriateness for their environment. Always test scripts in a controlled environment before deploying them widely.

## Description

This batch script is designed to address a specific issue with the CrowdStrike Falcon Sensor that may cause Windows systems to experience blue screen errors (BSODs). The script identifies and, if necessary, removes a problematic version of a CrowdStrike file, potentially resolving BSOD issues.

Key features:
- Checks for administrator privileges
- Detects if the system is running in Safe Mode
- Identifies the CrowdStrike Falcon Sensor file and its creation timestamp
- Compares the file timestamp to known problematic and fixed versions
- Offers to delete the problematic file if found
- Provides options for system reboot after file deletion
- Logs all actions taken

## How to Use

1. Download the `CrowdStrikeFixv2.bat` file to the affected system.
2. Right-click on the file and select "Run as administrator".
3. Follow the on-screen prompts.
4. If prompted to delete a file, carefully consider the action before confirming.
5. Reboot the system when instructed, either through the script or manually.

## Requirements

- Windows operating system
- Administrator privileges
- CrowdStrike Falcon Sensor installed

## Logging

The script creates a log file at `%temp%\CrowdStrikeFixLog.txt`. Review this log for a detailed record of the script's actions.

## Important Notes

- This script should only be used on systems experiencing issues related to the specific CrowdStrike Falcon Sensor problem it addresses.
- Always ensure you have current backups before running system modification scripts.
- If you're unsure about using this script, consult with your IT department or CrowdStrike support.

## Support

This script is not officially supported. If you encounter issues, please consult with your IT department or CrowdStrike support.

For more information about the issue this script addresses, refer to the official CrowdStrike documentation.