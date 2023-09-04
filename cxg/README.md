# Release Scripts

## Overview

Automates the process of managing releases in a Git Flow environment.

- `cxg-release-start.sh`: Handles preflight checks, prompts for a new version, initiates a Git Flow release, and bumps the project version in `package.json`.

- `cxg-release-finish.sh`: Performs final checks, merges the `release` branch into `main`, and pushes the new version tags.

*Note: this flow is designed for a single `release` branch (not `release/x.y.z` as in Git Flow)*.

## Prerequisites

- Bash
- Git
- Git Flow
- Node.js and npm
- awk, grep, sed

# Start Release

## Usage

Run `cxg-release-start.sh`. The script will:

1. Validate system readiness.
2. Prompt for a new version.
3. Initiate a Git Flow release.
4. Update `package.json` with the new version.

## Functions

- `preflight_checks`: Runs all pre-release validations.
- `prompt_version`: Asks for and validates a new version.
- `start_flow_release`: Manages Git commands for a new release.
- `bump_packagejson`: Updates and commits new version in `package.json`.

# Finish Release

## Usage

Run `cxg-release-finish.sh`. The script will:

1. Execute pre-release validations.
2. Confirm that you're ready to release.
3. Merge the `release` branch into `main` and tag the release.
4. Backmerge into `develop` and push all changes to remote branches.

## Functions

- `preflight_checks`: Performs all pre-release validations.
- `confirm_release`: Asks for confirmation to proceed with the release.
- `finish_release`: Executes Git commands to finalize the release.

