# git-profile

A small CLI script for switching your global Git identity between predefined profiles.

## Features

- Switch between named Git profiles
- Show the currently active global Git identity
- Simple to extend with additional profiles

## Usage

`./git-profile.sh` Shows the current global Git identity.

`./git-profile.sh --current` Also shows the current global Git identity.

`./git-profile.sh work` Switches to the work profile.

`./git-profile.sh personal` Switches to the personal profile.

`./git-profile.sh --help` Shows help output.

## Configuration

Profiles are defined directly in the script. Add new profiles there as needed.

Example profile definitions may look like:

```bash
PROFILE_NAMES[work]="John Doe"
PROFILE_EMAILS[work]="john.doe@example.com"

PROFILE_NAMES[personal]="John Doe"
PROFILE_EMAILS[personal]="john.doe@gmail.com"

...
```

## What it changes

This script updates your global Git config (`user.name` and `user.email`)

Equivalent to:

```bash
git config --global user.name "John Doe"
git config --global user.email "john.doe@example.com"
```

## Make it executable

Mkae sure you do this: `chmod +x git-profile.sh` - before running 

## Note

This changes your **global identity** for Git commits. If you need different identities per repository, use local repository config instead:

```bash
git config user.name "John Doe"
git config user.email "john.doe@example.com"
```
