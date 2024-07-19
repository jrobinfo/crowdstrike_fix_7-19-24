# Comprehensive Fix Plan for CrowdStrike Falcon Sensor BSOD Issue

## Table of Contents
1. [Issue Overview](#issue-overview)
2. [Scope of Affected Systems](#scope-of-affected-systems)
3. [Fix Plan](#fix-plan)
4. [Available Scripts](#available-scripts)
5. [Considerations for Different Environments](#considerations-for-different-environments)
6. [Potential Complications](#potential-complications)
7. [Post-Implementation Verification](#post-implementation-verification)
8. [Additional Resources](#additional-resources)

## Issue Overview

On July 19, 2024, a problematic update to the CrowdStrike Falcon Sensor caused Windows hosts to experience crashes (blue screen errors). The issue is related to a specific channel file deployed between 0409 UTC and 0527 UTC on that day.

## Scope of Affected Systems

- Windows hosts that received the problematic update between 0409 UTC and 0527 UTC on July 19, 2024
- Excludes:
  - Windows 7/2008 R2
  - Mac-based hosts
  - Linux-based hosts
  - Systems brought online after 0527 UTC

## Fix Plan

### For systems that can stay online:
1. Identify affected systems by checking the timestamp of the "C-00000291*.sys" file in the %WINDIR%\System32\drivers\CrowdStrike directory
2. If the timestamp is 0409 UTC, proceed with the fix
3. Reboot the system to allow it to download the reverted channel file
4. Verify that the new "C-00000291*.sys" file has a timestamp of 0527 UTC or later

### For systems that cannot stay online:
1. Boot the system into Safe Mode with Networking (preferably using a wired connection)
2. Navigate to %WINDIR%\System32\drivers\CrowdStrike
3. Delete the file matching "C-00000291*.sys"
4. Reboot the system normally

### For cloud or virtual environments:
1. Detach the operating system disk volume from the affected virtual server
2. Create a snapshot or backup of the disk volume
3. Attach the volume to a new virtual server
4. Navigate to %WINDIR%\System32\drivers\CrowdStrike
5. Delete the file matching "C-00000291*.sys"
6. Detach the volume from the new virtual server
7. Reattach the fixed volume to the affected virtual server
8. Boot the system

## Available Scripts

To assist with the fix process, we have provided two scripts:

1. **Batch Script**: [README for CrowdStrike Fix Batch Script](https://github.com/jrobinfo/crowdstrike_fix_7-19-24/blob/main/README_for_CrowdStrike_Fix_Batch_Script.md)
   - This script is designed for Windows environments and can be run directly from the command prompt.

2. **PowerShell Script**: [README for CrowdStrike Fix PowerShell Script](https://github.com/jrobinfo/crowdstrike_fix_7-19-24/blob/main/README_for_CrowdStrike_Fix_PowerShell_Script.md)
   - This script offers more advanced features and logging capabilities, suitable for environments where PowerShell is preferred.

Please refer to the individual README files for each script for detailed usage instructions, requirements, and important considerations.

## Considerations for Different Environments

- **On-premises**: Use the method for systems that can stay online or the method for systems that cannot stay online, depending on system stability.
- **Cloud (AWS, Azure)**: Use the method for cloud or virtual environments, following cloud-specific documentation for volume management.
- **Virtual**: Use the method for cloud or virtual environments, adapting steps to your specific virtualization platform.

## Potential Complications

- **BitLocker encryption**: Have recovery keys ready before attempting fixes
  - For Azure: Refer to "BitLocker recovery in Microsoft Azure" documentation
  - For on-premises: Use appropriate recovery method (SCCM, Active Directory, GPOs, or Ivanti Endpoint Manager)
- **Network connectivity in Safe Mode**: Ensure wired connection availability for faster and more stable remediation
- **Volume snapshot failures**: If unable to create a snapshot, proceed with caution and maintain detailed logs of all actions

## Post-Implementation Verification

1. Confirm system boots normally without BSOD
2. Verify the presence of "C-00000291*.sys" with a timestamp of 0527 UTC or later
3. Check CrowdStrike Falcon Sensor functionality
4. Monitor system stability for at least 24 hours
5. Conduct a sample check of critical applications and services
6. Review system and application logs for any residual errors

## Additional Resources

- [Official CrowdStrike Tech Alert](https://supportportal.crowdstrike.com/s/article/Tech-Alert-Windows-crashes-related-to-Falcon-Sensor-2024-07-19)
- For AWS-specific guidance: [Attach an EBS volume to an instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-attaching-volume.html)
- For Azure-specific guidance: [Attach a data disk to a Windows VM](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/attach-managed-disk-portal)

For any additional questions or concerns, please contact your IT department or CrowdStrike support.