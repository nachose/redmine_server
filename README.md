# redmine_server

Personal Redmine server using Docker.

## Prerequisites

- Docker
- Docker Compose

## Installation

1.  Clone this repository.
2.  (Optional) If you want to run Redmine as a systemd service, edit `redmine.service` and replace `youruser` with your actual username. Then run:
    ```bash
    sudo cp redmine.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable --now redmine
    ```

## Usage

To start Redmine:
```bash
docker-compose up -d
```

To stop Redmine:
```bash
docker-compose down
```

## Backup and Restore

### Backup

To create a backup of the database and Redmine files, run the `backup.sh` script:

```bash
./backup.sh
```

A new timestamped directory will be created in the `backup` folder containing the database dump (`redmine_db.sql`) and the files (`redmine_files.tar.gz`).

### Restore

To restore from a backup, run the `restore.sh` script with the path to the backup directory as an argument:

```bash
./restore.sh backup/YYYYMMDD_HHMMSS
```

Replace `YYYYMMDD_HHMMSS` with the actual timestamp of the backup you want to restore.

To test the restore process without actually changing any files, use the `--dry-run` flag:

```bash
./restore.sh --dry-run backup/YYYYMMDD_HHMMSS
```

**Warning:** This will overwrite the current database and files with the content of the backup.
