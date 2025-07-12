#!/bin/bash
set -e

# Default to dry-run false
DRY_RUN=false

# Check for --dry-run flag
if [ "$1" = "--dry-run" ]; then
  DRY_RUN=true
  shift # remove --dry-run from arguments
fi

# The backup directory to restore from
SRC_DIR="$1"

if [ -z "$SRC_DIR" ]; then
  echo "Usage: $0 [--dry-run] <path_to_backup_directory>"
  exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
  echo "Backup directory not found: $SRC_DIR"
  exit 1
fi

if [ "$DRY_RUN" = true ]; then
  echo "--- DRY RUN ---"
  echo "Would check for backup files in $SRC_DIR"
  if [ ! -f "$SRC_DIR/redmine_db.sql" ] || [ ! -f "$SRC_DIR/redmine_files.tar.gz" ]; then
    echo "Backup files not found in $SRC_DIR"
    exit 1
  fi
  echo "Backup files found."
  echo "---"
  echo "Would stop Redmine services:"
  echo "docker-compose down"
  echo "---"
  echo "Would restore database with the following commands:"
  echo "docker-compose up -d db"
  echo "cat \"$SRC_DIR/redmine_db.sql\" | docker exec -i redmine-db mysql -u redmine -predminepass redmine"
  echo "docker-compose stop db"
  echo "---"
  echo "Would restore Redmine files with the following command:"
  echo "docker run --rm --volumes-from redmine -v \"$SRC_DIR\":/backup busybox sh -c \"echo 'Would remove and extract files'\""
  echo "---"
  echo "Would restart Redmine services:"
  echo "docker-compose up -d"
  echo "--- DRY RUN COMPLETE ---"
else
  # Stop the services
  echo "Stopping Redmine services..."
  docker-compose down

  # Restore the database
  echo "Restoring database..."
  docker-compose up -d db
  cat "$SRC_DIR/redmine_db.sql" | docker exec -i redmine-db mysql -u redmine -predminepass redmine
  docker-compose stop db

  # Restore the redmine files
  echo "Restoring Redmine files..."
  # The -i flag on docker exec is required for this command to work
  docker run --rm --volumes-from redmine -v "$SRC_DIR":/backup busybox sh -c "rm -rf /usr/src/redmine/files/* && tar xzf /backup/redmine_files.tar.gz -C /"

  # Restart the services
  echo "Starting Redmine services..."
  docker-compose up -d

  echo "Restore complete."
fi
