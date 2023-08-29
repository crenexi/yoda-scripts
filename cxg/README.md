# Start Release

## Overview

Automates the process of starting a new release in a Git Flow environment. The scripts handle preflight checks and bump the project version in `package.json`.

## Prerequisites
- Bash
- Git
- Git Flow
- Node.js and npm
- awk, grep, sed

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
