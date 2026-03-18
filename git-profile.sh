#!/usr/bin/env bash

set -euo pipefail

if [ -z "${BASH_VERSINFO:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  echo "This script requires Bash 4 or newer." >&2
  echo "If not, change line 1 to zsh or sh" >&2
  exit 1
fi

declare -A PROFILE_NAMES
declare -A PROFILE_EMAILS

PROFILE_NAMES[work]="John Doe"
PROFILE_EMAILS[work]="john.doe@example.com"

PROFILE_NAMES[personal]="John Doe"
PROFILE_EMAILS[personal]="john.doe@gmail.com"

usage() {
    cat <<EOF
Usage: git-profile [profile-name|--current|--help]

Examples:
  git-profile
  git-profile --current
  git-profile work
  git-profile personal
  git-profile --help
EOF
}

show_current() {
    echo "Current Git Identity:"
    echo "Name : $(git config --global user.name 2>/dev/null || true)"
    echo "Email: $(git config --global user.email 2>/dev/null || true)"
}

set_profile() {
    local profile="$1"

    if [[ -z "${PROFILE_NAMES[$profile]:-}" || -z "${PROFILE_EMAILS[$profile]:-}" ]]; then
        echo "Unknown profile: $profile" >&2
        echo >&2
        usage >&2
        exit 1
    fi

    git config --global user.name "${PROFILE_NAMES[$profile]}"
    git config --global user.email "${PROFILE_EMAILS[$profile]}"

    echo "Switched to ${profile^^} git profile"
    show_current
}

main() {
    local arg="${1:---current}"

    case "$arg" in
        --help|-h)
            usage
            ;;
        --current|current)
            show_current
            ;;
        *)
            set_profile "$arg"
            ;;
    esac
}

main "$@"
