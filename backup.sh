#!/bin/bash
set -e

# Directory where backups will be stored
BACKUP_DIR="$(dirname "$0")/backup"
# Timestamp for the backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
# Directory for this specific backup
DEST_DIR="$BACKUP_DIR/$TIMESTAMP"

# Create the backup directory
mkdir -p "$DEST_DIR"

# Backup the database
echo "Backing up database..."
docker compose exec -T -e MYSQL_PWD=redminepass db mysqldump -u redmine --no-tablespaces --databases redmine > "$DEST_DIR/redmine_db.sql"

# Backup the redmine files
echo "Backing up Redmine files..."
docker run --rm --volumes-from redmine -v "$DEST_DIR":/backup busybox tar czf /backup/redmine_files.tar.gz /usr/src/redmine/files

echo "Backup complete: $DEST_DIR"
