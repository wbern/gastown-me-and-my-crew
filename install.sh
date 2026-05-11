#!/usr/bin/env bash
# Install the gastown-me-and-my-crew preset (manual mode / crew-only).
#
# Backs up existing ~/gt/settings/config.json and ~/gt/mayor/daemon.json
# to .bak.<timestamp> before overwriting. Safe to re-run.

set -euo pipefail

GT_HOME="${GT_HOME:-$HOME/gt}"
SUPPORTED_GT_VERSION="v1.0.0-78"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_SETTINGS="$SCRIPT_DIR/config/settings.config.json"
SRC_DAEMON="$SCRIPT_DIR/config/mayor.daemon.json"

DST_SETTINGS="$GT_HOME/settings/config.json"
DST_DAEMON="$GT_HOME/mayor/daemon.json"

log()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

[[ -f "$SRC_SETTINGS" ]] || die "missing source file: $SRC_SETTINGS"
[[ -f "$SRC_DAEMON"   ]] || die "missing source file: $SRC_DAEMON"

if ! command -v gt >/dev/null 2>&1; then
  die "'gt' not found on PATH. Install Gas Town first: https://github.com/steveyegge/gastown"
fi

GT_VERSION="$(gt version 2>/dev/null | awk '{print $3}' | head -1 || true)"
if [[ -z "$GT_VERSION" ]]; then
  warn "could not parse 'gt version' output — proceeding anyway"
elif [[ "$GT_VERSION" != "$SUPPORTED_GT_VERSION" ]]; then
  warn "gt version is $GT_VERSION; this preset was tested against $SUPPORTED_GT_VERSION."
  warn "It will likely still work, but the schema may have drifted."
fi

[[ -d "$GT_HOME" ]]              || die "GT_HOME not found: $GT_HOME (set GT_HOME if non-default)"
[[ -d "$GT_HOME/settings" ]]     || die "expected directory missing: $GT_HOME/settings"
[[ -d "$GT_HOME/mayor" ]]        || die "expected directory missing: $GT_HOME/mayor"

TS="$(date +%Y%m%d-%H%M%S)"

backup_and_install() {
  local src="$1" dst="$2"
  if [[ -f "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      log "= $dst already matches preset, skipping"
      return
    fi
    local bak="${dst}.bak.${TS}"
    cp "$dst" "$bak"
    log "backed up $dst -> $bak"
  fi
  cp "$src" "$dst"
  log "installed $dst"
}

backup_and_install "$SRC_SETTINGS" "$DST_SETTINGS"
backup_and_install "$SRC_DAEMON"   "$DST_DAEMON"

log ""
log "Done. Restart Gas Town for changes to take effect:"
log "  gt down && gt up --restore"
log ""
log "To revert: ./uninstall.sh"
