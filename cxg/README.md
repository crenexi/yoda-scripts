# Release Scripts

## Overview

Automates the process of managing releases in a Git Flow environment. These scripts handle versioning, branch management, and post-release tasks to streamline the release workflow.

- `cxg-release-start.sh`: Initiates a new release cycle, updates the project version, starts a Git Flow release, and prepares the stage branch with the latest release changes.
- `cxg-release-finish.sh`: Finalizes the release process, merges the release branch into `main`, pushes version tags, and performs post-release tasks.
- `cxg-stage.sh`: Stages the latest changes from the `develop` branch, useful for updates outside the formal release process.

## Prerequisites

- Bash
- Git and Git Flow
- Node.js and npm
- Utilities: awk, grep, sed

## Scripts Usage and Workflow

### Start Release (`cxg-release-start.sh`)

#### Usage

Run `cxg-release-start.sh`. The script:

1. Validates system readiness.
2. Prompts for a new version.
3. Initiates a Git Flow release.
4. Updates `package.json` with the new version.
5. Optionally updates the stage branch with changes from the new release branch.

#### Functions

- `preflight_checks`: Runs all pre-release validations.
- `prompt_version`: Asks for and validates a new version.
- `start_flow_release`: Manages Git commands for a new release.
- `bump_packagejson`: Updates and commits new version in `package.json`.
- `prompt_update_stage`: Optionally updates the stage branch with the release changes.

### Finish Release (`cxg-release-finish.sh`)

#### Usage

Run `cxg-release-finish.sh`. The script:

1. Executes pre-release validations.
2. Confirms that you're ready to release.
3. Merges the release branch into `main` and tags the release.
4. Backmerges into `develop` and pushes all changes to remote branches.
5. Performs post-release tasks like updating Notion and considering CloudFront invalidation.

#### Functions

- `preflight_checks`: Performs all pre-release validations.
- `confirm_release`: Asks for confirmation to proceed with the release.
- `finish_release`: Executes Git commands to finalize the release.
- `prompt_notion`: Prompts to update Notion.
- `prompt_invalidation`: Prompts to perform CloudFront invalidation.

### Stage (`cxg-stage.sh`)

#### Usage

Run `cxg-stage.sh` to update the stage branch with the latest changes from the `develop` branch outside the formal release process.

#### Functions

- `sync_develop`: Checks out `develop`, pulls the latest changes, and reads the current version.
- `prompt_update_stage`: Updates the stage branch with changes from `develop`.

## General Notes

- Always run these scripts in a clean working directory to avoid unexpected issues.
- Understand the current branch and version before proceeding with any script.
- The scripts are designed to be run in sequence (`start` -> `finish`) for a complete release cycle.
- Use `cxg-stage.sh` for interim updates to the stage branch from `develop`.

## Troubleshooting

- If a script fails, check the console output for error messages.
- Ensure Git Flow is correctly initialized in your repository.
- Validate that your local repository is up-to-date with the remote.
