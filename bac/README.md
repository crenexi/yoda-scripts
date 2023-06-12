# Backup to NAS

This is a Bash script that automates a backup procedure. It can operate in either automatic mode (if `auto=true`) or manual mode (if `auto=false`). Below is a breakdown of the script's functionality:

## Functionality

1. **Main Function:** The script starts with the `main` function. This function verifies the configuration, prepares the necessary variables, and then kicks off the backup process.

2. **Automatic Mode:** If `auto=true`, the script will perform a check to ensure there's no recent backup. If a recent backup exists, it will not execute another backup to avoid redundancy.

3. **Manual Mode:** If `auto=false`, the script will ask for confirmation before proceeding at each step. This allows you to confirm the directory key and perform a dry-run backup before proceeding with the actual backup.

4. **Configuration of Variables:** The `configure_vars` function sets up essential variables, like source and destination paths, exclude and include files, log files, and some commands.

5. **Check for Missing Configurations:** The `catch_config_dne` function looks for missing configurations by iterating through a list of essential variables. If any variables are unset, it will throw an error message and exit.

6. **Check for Recent Backup:** The `catch_recent_backup` function checks if a recent backup has been performed. If the time difference between the current time and the last backup time is less than the set `interval`, it will exit the script, indicating a recent backup has already been done.

7. **Backup Process:** The `backup_from` function executes the `rsync` command, synchronizing source and destination directories. It uses various parameters to preserve file attributes and handle links, deletions, exclusions, and inclusions. If `is_dry_run=true`, it will only simulate the backup operation.

8. **Upon Completion:** The `on_complete` function runs after a successful backup. It logs the timestamp of the backup in a stamp file, logs `rsync` output, and sends a completion notification.

9. **Helper Functions:** The script includes several helper functions for displaying informative messages (`info`), handling script cancellation (`cancel`), and asking for user confirmation (`confirm_dir_key` and `confirm_run`).

## Usage

Before running this script, ensure all required variables (`id`, `user`, `auto`, `interval`, `delay`, `sources`, `dest_parent`, `log_parent`) are set correctly. If the script is in manual mode, interact with the prompts to confirm the operations.

## Assumptions

1. Dependency on `rsync`, `cxx-notify.sh` and `mtn-pandora.sh`: assumes `rsync` is installed; assumes the two scripts exist, are executable, and are located at the specified paths

2. Variable Settings: assumes that all required variables (`id`, `user`, `auto`, `interval`, `delay`, `sources`, `dest_parent`, `log_parent`) are set before it runs

3. File and Directory Existence: assumes the existence of certain files and directories. For instance, the exclude and include files are expected to exist at the specified locations

4. Read/Write: assumes necessary permissions to read from the source directories, write to the destination directories, and create or modify the log files.
