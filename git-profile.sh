#!/bin/sh

# Prefer zsh when running under old bash/sh on macOS.
if [ -n "${ZSH_VERSION:-}" ]; then
  :
elif [ -n "${BASH_VERSION:-}" ]; then
  bash_major="${BASH_VERSINFO:-}"
  if [ -n "${BASH_VERSINFO:-}" ]; then
    bash_major="${BASH_VERSINFO%% *}"
    bash_major="${BASH_VERSINFO[0]}"
  else
    bash_major="$(printf '%s' "$BASH_VERSION" | cut -d. -f1)"
  fi

  if [ "$bash_major" -lt 4 ] 2>/dev/null; then
    if command -v zsh >/dev/null 2>&1; then
      exec zsh "$0" "$@"
    fi
    echo "This script requires Bash 4+ when using bash." >&2
    echo "Use zsh instead, or upgrade to Bash 4 or newer." >&2
    exit 1
  fi
else
  if command -v zsh >/dev/null 2>&1; then
    exec zsh "$0" "$@"
  elif command -v bash >/dev/null 2>&1; then
    bash_major="$(bash -c 'printf "%s" "${BASH_VERSION%%.*}"' 2>/dev/null || printf '0')"
    if [ "$bash_major" -ge 4 ] 2>/dev/null; then
      exec bash "$0" "$@"
    fi
  fi
  echo "This script requires zsh or Bash 4+." >&2
  exit 1
fi

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_FILE="${GIT_PROFILE_FILE:-$SCRIPT_DIR/profiles.txt}"

usage() {
  cat <<EOF
Usage: git-profile [profile-name|--current|--list|--help]

Examples:
  git-profile
  git-profile --current
  git-profile --list
  git-profile work
  git-profile personal
  git-profile --help

Profiles file:
  $PROFILE_FILE
EOF
}

show_current() {
  echo "Current Git Identity:"
  echo "Name : $(git config --global user.name 2>/dev/null || true)"
  echo "Email: $(git config --global user.email 2>/dev/null || true)"
}

require_profiles_file() {
  if [ ! -f "$PROFILE_FILE" ]; then
    echo "Profiles file not found: $PROFILE_FILE" >&2
    exit 1
  fi
}

get_profile() {
  wanted_profile="$1"
  PROFILE_NAME=""
  PROFILE_EMAIL=""

  require_profiles_file

  while IFS='|' read -r key name email; do
    [ -z "${key:-}" ] && continue
    case "$key" in
      \#*) continue ;;
    esac

    if [ "$key" = "$wanted_profile" ]; then
      PROFILE_NAME="$name"
      PROFILE_EMAIL="$email"
      return 0
    fi
  done < "$PROFILE_FILE"

  return 1
}

list_profiles() {
  require_profiles_file
  echo "Available profiles:"
  while IFS='|' read -r key name email; do
    [ -z "${key:-}" ] && continue
    case "$key" in
      \#*) continue ;;
    esac
    printf '  %s\n' "$key"
  done < "$PROFILE_FILE"
}

set_profile() {
  profile="$1"

  if ! get_profile "$profile"; then
    echo "Unknown profile: $profile" >&2
    echo >&2
    list_profiles >&2 || true
    exit 1
  fi

  git config --global user.name "$PROFILE_NAME"
  git config --global user.email "$PROFILE_EMAIL"

  echo "Switched to $profile git profile"
  show_current
}

main() {
  arg="${1:---current}"

  case "$arg" in
    --help|-h)
      usage
      ;;
    --current|current)
      show_current
      ;;
    --list|-l)
      list_profiles
      ;;
    *)
      set_profile "$arg"
      ;;
  esac
}

main "$@"
