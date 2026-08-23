# git-profile

A small CLI script for switching your global Git identity and commit-signing settings between predefined profiles. An optional pre-commit hook can also prevent commits made with the wrong identity for a repository.

## Features

- Switch between named Git profiles stored in `profiles.txt`
- Configure `user.name`, `user.email`, and optional GPG signing per profile
- Show the current global Git identity and signing status
- List the available profiles
- Check repository/profile mappings before a commit
- Override the profile and repository-mapping file locations with environment variables

## Requirements

- Git
- zsh or Bash 4+
- A configured GPG signing key for each signing-enabled profile

On macOS, the script automatically uses zsh when the system Bash is older than version 4.

## Installation

1. Copy the script and configuration files to your home directory:

   ```bash
   cp git-profile.sh profiles.txt repo-profiles.txt ~/
   cp -R .git-hooks ~/
   ```

2. Make the script and hook executable:

   ```bash
   chmod +x ~/git-profile.sh ~/.git-hooks/pre-commit
   ```

3. Configure Git to use the hook directory:

   ```bash
   git config --global core.hooksPath ~/.git-hooks
   ```

Run the script as `~/git-profile.sh`, or place it somewhere on your `PATH` under the name `git-profile`.

## Usage

```text
git-profile [profile-name|--current|--list|--help]
```

Examples:

```bash
# Show the current global identity and GPG signing status
git-profile
git-profile --current

# List configured profile names
git-profile --list

# Switch profiles
git-profile work
git-profile personal

# Show help
git-profile --help
```

`current`, `-l`, and `-h` are also accepted as aliases for `--current`, `--list`, and `--help`.

## Profile configuration

Profiles are defined in `profiles.txt`, one per line, using four pipe-delimited fields:

```text
profile|name|email|signing-key
```

For example:

```text
# profile|name|email|signing-key
work|John Doe|john.doe@example.com|0123456789ABCDEF0123456789ABCDEF01234567
personal|John Doe|john.doe@gmail.com|
```

Blank lines and lines beginning with `#` are ignored. The signing-key field may be left empty for a profile that does not sign commits or tags.

By default, the script reads `profiles.txt` from the directory containing `git-profile.sh`. Set `GIT_PROFILE_FILE` to use a different file:

```bash
GIT_PROFILE_FILE="$HOME/.config/git-profiles/profiles.txt" git-profile work
```

## What switching a profile changes

Every profile switch updates these global Git settings:

```text
user.name
user.email
```

If the profile has a signing key, the script also sets:

```text
user.signingkey = <the profile's signing key>
commit.gpgsign = true
tag.gpgSign = true
```

If the signing-key field is empty, the script removes `user.signingkey` and sets both signing flags to `false`.

These are global settings. A repository-local Git configuration can override them.

## Repository profile checks

The optional pre-commit hook reads `repo-profiles.txt` and checks that the effective Git name and email match the profile assigned to the current repository. Mappings use the repository directory name and this format:

```text
repository-directory:profile
```

For example:

```text
company-api:work
personal-site:personal
```

Blank lines and lines beginning with `#` are ignored. Repositories without a mapping are allowed to commit without a profile check. The hook checks the name and email; it does not validate the signing key.

The hook reads `~/profiles.txt` and `~/repo-profiles.txt` by default. Their locations can be overridden with `GIT_PROFILE_FILE` and `GIT_REPO_PROFILE_FILE` respectively.

## Local repository identities

If you prefer to configure an identity directly in one repository, run these commands inside that repository:

```bash
git config user.name "John Doe"
git config user.email "john.doe@example.com"
```

Local values take precedence over the global identity selected by this script.
