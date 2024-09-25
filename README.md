# Rclone-Batch-Mount

## Overview
This script facilitates the batch mounting of Rclone remotes and is suitable for external hard drives.

It offers a convenient way to mount and unmount Rclone remotes with a single click, while prioritizing privacy and utilizing local Rclone paths if available.

## Main Features
- Convenience: Batch mount Rclone remotes with one-click mount/unmount functionality.
- Privacy: Conceal the password input process, automatically clear the password after mounting, and remove cache after unmounting.
- Portability: Prefer using the Rclone path found on an external hard drive if available.

## Usage
- Configure Parameters: Edit the beginning of the script to set the drive labels, mount paths, and Rclone configuration paths.
- **Batch Mount**: Double-click the .ps1 file to execute.
- **Batch Unmount**: Run the .ps1 file again to shutdown all rclone processes.

Note: Ensure that Rclone is correctly installed and that the specified drive labels and paths are accurate before running the script.

