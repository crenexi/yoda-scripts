# `backup.sh`

## Summary
The `backup.sh` script is a Bash script that automates the backup process for specified sources to a destination location. It utilizes the `rsync` command for efficient file synchronization and includes features such as configurable intervals, exclusion and inclusion files, and notification upon completion. The script ensures that recent backups are skipped to avoid unnecessary duplication.

## Usage
Before running the `backup.sh` script, the following configurations need to be set:

1. **Variables**: Ensure that the necessary variables are defined and not empty. These variables include `id`, `user`, `is_dry_run`, `interval`, `delay`, `sources`, `dest_parent`, and `log_parent`.
2. **Dependency Scripts**: Verify that the required dependency scripts, namely `mnt-pandora.sh` and `cxx-notify.sh`, are present in the specified locations.
3. **Exclude and Include Files**: Create the exclude and include files. The exclude file is shared across all backups and should be located at `$dot/../exclude.txt`, while the backup-specific include file should be located at `$dot/include.txt`.

## Functionality
The `backup.sh` script follows the following flow and includes the following functions:

1. **Verification Helpers**: These functions validate the script's configuration and dependencies to ensure smooth execution.
    - `catch_config_dne()`: Checks if the necessary variables are defined and not empty. Exits with an error if any variables are missing.
    - `catch_script_deps()`: Verifies the existence of the required dependency scripts. Exits with an error if any scripts are missing.
    - `catch_recent_backup()`: Checks if a recent backup has been performed. Skips the backup if the time difference is within the specified interval.

2. **Misc Helpers**: These functions provide various utility functionalities.
    - `info()`: Displays an informational message.
    - `info_stamped()`: Displays a timestamped informational message and sends a backup notification.
    - `cancel()`: Cancels the backup operation with an optional message.
    - `configure_vars()`: Configures the script variables and paths.
    - `await_pandora()`: Waits for the specified destination parent to be mounted if it is on the Pandora file system.
    - `on_complete()`: Handles actions to be performed upon completion of the backup.

3. **Backup Process**: This section includes functions related to the backup process.
    - `backup_from()`: Performs the backup from a specified source to the destination using `rsync` with the provided parameters.
    - `run_backup()`: Executes the backup process by setting up necessary conditions, performing the backup for each source, and handling exceptions.

## Assumptions
The `backup.sh` script assumes the following:
- The script is being executed in a Bash environment.
- The necessary variables are correctly configured before running the script.
- The required dependency scripts (`mnt-pandora.sh` and `cxx-notify.sh`) are available in the specified locations.
- The exclude and include files (`exclude.txt` and `include.txt`) are created and located in the appropriate paths.
- The script has appropriate permissions to access and write to the specified destination and log directories.
- The `rsync` command is installed and available on the system.
- The `systemctl` command is available for checking the status of the `autofs` service.
- The script is run with appropriate user privileges to perform the required actions (e.g., creating directories, executing commands).
