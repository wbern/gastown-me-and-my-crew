#!/usr/bin/env bash
# Uninstall the gastown-me-and-my-crew preset by restoring the most recent
# .bak.<timestamp> backups created by install.sh.
#
# If no backup is found for a file, it is left as-is and a warning is printed.

set -euo pipefail

GT_HOME="${GT_HOME:-$HOME/gt}"

DST_SETTINGS="$GT_HOME/settings/config.json"
DST_DAEMON="$GT_HOME/mayor/daemon.json"

log()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }

latest_backup() {
  # Print the path to the most recent .bak.<timestamp> for the given file,
  # or nothing if none exists.
  local target="$1"
  local dir base
  dir="$(dirname "$target")"
  base="$(basename "$target")"
  # The timestamp format (YYYYMMDD-HHMMSS) sorts lexicographically.
  # shellcheck disable=SC2012  # filenames are controlled by install.sh
  ls -1 "$dir"/"$base".bak.* 2>/dev/null | sort | tail -n 1 || true
}

restore() {
  local dst="$1"
  local bak
  bak="$(latest_backup "$dst")"
  if [[ -z "$bak" ]]; then
    warn "no backup found for $dst — leaving it in place"
    return
  fi
  cp "$bak" "$dst"
  log "restored $dst from $bak"
}

restore "$DST_SETTINGS"
restore "$DST_DAEMON"

log ""
log "Done. Restart Gas Town for changes to take effect:"
log "  gt down && gt up --restore"
