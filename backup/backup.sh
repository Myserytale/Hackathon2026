#!/bin/sh
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backups"
BACKUP_FILE="${BACKUP_DIR}/farmdb_${TIMESTAMP}.sql.gz"

echo "[$(date)] Starting backup..."

PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump \
  -h "${POSTGRES_HOST}" \
  -p "${POSTGRES_PORT:-5432}" \
  -U "${POSTGRES_USER}" \
  -d "${POSTGRES_DB}" \
  --no-owner \
  --no-privileges \
  | gzip > "${BACKUP_FILE}"

echo "[$(date)] Backup saved to ${BACKUP_FILE} ($(du -h ${BACKUP_FILE} | cut -f1))"

# Rotate: delete backups older than 1 hour
find "${BACKUP_DIR}" -name "farmdb_*.sql.gz" -mmin +60 -delete
echo "[$(date)] Old backups cleaned up. Current backups:"
ls -lh "${BACKUP_DIR}"/farmdb_*.sql.gz 2>/dev/null || echo "  (none)"
