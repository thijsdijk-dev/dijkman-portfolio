#!/usr/bin/env bash
set -euo pipefail

# Installs (or updates) a daily cron job for USB backups.

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
USB_MOUNT="${USB_MOUNT:-/media/pi/backup-usb}"
BACKUP_SCHEDULE="${BACKUP_SCHEDULE:-30 3 * * *}"
LOG_FILE="${LOG_FILE:-/var/log/dijkman-backup.log}"
CRON_TAG="# dijkman-portfolio-backup"

BACKUP_CMD="cd $PROJECT_DIR && USB_MOUNT=$USB_MOUNT npm run backup:usb >> $LOG_FILE 2>&1"
CRON_LINE="$BACKUP_SCHEDULE $BACKUP_CMD $CRON_TAG"

if [[ -n "${CRON_FILE:-}" ]]; then
  touch "$CRON_FILE"
  EXISTING_CRON="$(cat "$CRON_FILE")"
else
  EXISTING_CRON="$(crontab -l 2>/dev/null || true)"
fi

FILTERED_CRON="$(printf '%s\n' "$EXISTING_CRON" | sed "/$CRON_TAG/d")"
UPDATED_CRON="$(printf '%s\n%s\n' "$FILTERED_CRON" "$CRON_LINE" | sed '/^$/d')"

if [[ -n "${CRON_FILE:-}" ]]; then
  printf '%s\n' "$UPDATED_CRON" > "$CRON_FILE"
else
  printf '%s\n' "$UPDATED_CRON" | crontab -
fi

printf '[cron] Backup cron ingesteld: %s\n' "$CRON_LINE"
