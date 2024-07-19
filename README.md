https://supportportal.crowdstrike.com/s/article/Tech-Alert-Windows-crashes-related-to-Falcon-Sensor-2024-07-19

# Comprehensive Fix Plan for Windows BSOD Issue

## 1. Brief summary of the issue
Windows hosts are experiencing crashes (blue screen errors) related to a problematic update of the CrowdStrike Falcon Sensor. The issue is caused by a specific channel file deployed between 0409 UTC and 0527 UTC on July 19, 2024.

## 2. Scope of affected systems
- Windows hosts that received the problematic update between 0409 UTC and 0527 UTC on July 19, 2024
- Excludes: Windows 7/2008 R2, Mac-based hosts, Linux-based hosts, and systems brought online after 0527 UTC

## 3. Step-by-step implementation plan

### A. For systems that can stay online:
1. Identify affected systems by checking the timestamp of the "C-00000291*.sys" file in the %WINDIR%\System32\drivers\CrowdStrike directory
2. If the timestamp is 0409 UTC, proceed with the fix
3. Reboot the system to allow it to download the reverted channel file
4. Verify that the new "C-00000291*.sys" file has a timestamp of 0527 UTC or later

### B. For systems that cannot stay online:
1. Boot the system into Safe Mode with Networking (preferably using a wired connection)
2. Navigate to %WINDIR%\System32\drivers\CrowdStrike
3. Delete the file matching "C-00000291*.sys"
4. Reboot the system normally

### C. For cloud or virtual environments:
1. Detach the operating system disk volume from the affected virtual server
2. Create a snapshot or backup of the disk volume
3. Attach the volume to a new virtual server
4. Navigate to %WINDIR%\System32\drivers\CrowdStrike
5. Delete the file matching "C-00000291*.sys"
6. Detach the volume from the new virtual server
7. Reattach the fixed volume to the affected virtual server
8. Boot the system

## 4. Considerations for different environments
- On-premises: Use method A or B depending on system stability
- Cloud (AWS, Azure): Use method C, following cloud-specific documentation for volume management
- Virtual: Use method C, adapting steps to your virtualization platform

## 5. Potential complications and how to address them
- BitLocker encryption: Have recovery keys ready before attempting fixes
  - For Azure: Refer to "BitLocker recovery in Microsoft Azure" documentation
  - For on-premises: Use appropriate recovery method (SCCM, Active Directory, GPOs, or Ivanti Endpoint Manager)
- Network connectivity in Safe Mode: Ensure wired connection availability for faster and more stable remediation
- Volume snapshot failures: If unable to create a snapshot, proceed with caution and maintain detailed logs of all actions

## 6. Post-implementation verification steps
1. Confirm system boots normally without BSOD
2. Verify the presence of "C-00000291*.sys" with a timestamp of 0527 UTC or later
3. Check CrowdStrike Falcon Sensor functionality
4. Monitor system stability for at least 24 hours
5. Conduct a sample check of critical applications and services
6. Review system and application logs for any residual errors