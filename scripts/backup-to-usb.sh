#!/usr/bin/env bash
set -euo pipefail

# Backup utility for Raspberry Pi deployments.
# Creates compressed archives of npm data, build output, and docker compose files.

SOURCE_ROOT="${SOURCE_ROOT:-$(pwd)}"
USB_MOUNT="${USB_MOUNT:-/media/pi/backup-usb}"
BACKUP_DIR="${BACKUP_DIR:-$USB_MOUNT/dijkman-portfolio-backups}"
NPM_DATA_PATH="${NPM_DATA_PATH:-$HOME/.npm}"
DIST_PATH="${DIST_PATH:-$SOURCE_ROOT/dist}"
COMPOSE_FILE="${COMPOSE_FILE:-$SOURCE_ROOT/docker-compose.yml}"

TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

log() {
  printf '[backup] %s\n' "$1"
}

require_path_exists() {
  local path="$1"
  local label="$2"
  if [[ ! -e "$path" ]]; then
    log "Overslaan: $label niet gevonden op '$path'"
    return 1
  fi
  return 0
}

create_archive() {
  local source_path="$1"
  local archive_name="$2"

  tar -czf "$BACKUP_DIR/$archive_name" -C "$(dirname "$source_path")" "$(basename "$source_path")"
  log "Gemaakt: $BACKUP_DIR/$archive_name"
}

if [[ ! -d "$USB_MOUNT" ]]; then
  log "USB mountpunt niet gevonden: '$USB_MOUNT'"
  log "Mount eerst je USB stick (bijv. via /etc/fstab) en draai daarna opnieuw."
  exit 1
fi

mkdir -p "$BACKUP_DIR"

log "Start backup naar $BACKUP_DIR"

if require_path_exists "$NPM_DATA_PATH" "NPM data"; then
  create_archive "$NPM_DATA_PATH" "npm-data-$TIMESTAMP.tar.gz"
fi

if require_path_exists "$DIST_PATH" "dist output"; then
  create_archive "$DIST_PATH" "dist-$TIMESTAMP.tar.gz"
fi

if require_path_exists "$COMPOSE_FILE" "docker-compose"; then
  create_archive "$COMPOSE_FILE" "compose-$TIMESTAMP.tar.gz"
fi

cat > "$TMP_DIR/manifest.txt" <<MANIFEST
backup_timestamp=$TIMESTAMP
source_root=$SOURCE_ROOT
usb_mount=$USB_MOUNT
npm_data_path=$NPM_DATA_PATH
dist_path=$DIST_PATH
compose_file=$COMPOSE_FILE
MANIFEST

cp "$TMP_DIR/manifest.txt" "$BACKUP_DIR/manifest-$TIMESTAMP.txt"
log "Manifest opgeslagen: $BACKUP_DIR/manifest-$TIMESTAMP.txt"
log "Backup afgerond"
