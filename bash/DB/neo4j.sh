#!/usr/bin/env bash
set -euo pipefail

ENV="prod"
DATE="$(date +%d-%m-%Y)"

S3_BUCKET="s3://neo4j-c2-daily-backup"
BACKUP_DIR="/opt/neo4j/daily_backup"

BACKUP_FILE="${BACKUP_DIR}/neo4j-${ENV}-${DATE}.dump"
METRICS_FILE="/var/lib/node_exporter/backup_metrics.prom"
LOG_FILE="/var/log/backup/_daily.log"

[[ -d "${BACKUP_DIR}" ]] || mkdir -p "${BACKUP_DIR}"
[[ -d /var/log/backup ]] || mkdir -p /var/log/backup
[[ -f "${METRICS_FILE}" ]] || touch "${METRICS_FILE}" && chown node-exp:node-exp ${METRICS_FILE}

: > "${LOG_FILE}"
: > "${METRICS_FILE}"
: > /var/log/backup/_backupScript.log

log_message() {
    local message="$1"
    echo "[${DATE}] ${message}" >> "${LOG_FILE}"
}

generate_metrics() {
    cat <<EOF >> "${METRICS_FILE}"
# HELP backup_status based on check_backup and indicates the last backup status (1 = success, 0 = failure)
# TYPE backup_status gauge
backup_status $1
EOF
}

create_backup() {
  log_message "Stopping Neo4j service"
  neo4j stop &>> "${LOG_FILE}"

  log_message "Creating Neo4j daily dump"
  #debug [[ -f "${BACKUP_FILE}" ]] && mv ${BACKUP_FILE} ${BACKUP_FILE}-${RANDOM}
  neo4j-admin dump --database=neo4j --to="${BACKUP_FILE}" --verbose 2>> "${LOG_FILE}" || { neo4j start &>> "${LOG_FILE}" ;}

  log_message "Starting Neo4j service"
  neo4j start &>> "${LOG_FILE}"

  copy_backup
}

copy_backup() {
  log_message "Copying backup to S3 bucket: ${S3_BUCKET}"
  aws s3 cp "${BACKUP_FILE}" "${S3_BUCKET}"

  clean_local_backups
  check_backup
}

clean_local_backups() {
  backup_count=$(find "${BACKUP_DIR}" -type f -name "*.dump" | wc -l)

  if [[ "${backup_count}" -gt 9 ]]; then
    log_message "${backup_count} backups in the ${BACKUP_DIR}. Deleting backups older than 10 days."
    find "${BACKUP_DIR}" -type f -name "*.dump" -mtime +10 -exec rm -f {} \;
    log_message "Backups older than 10 days have been deleted."
  else
    log_message "${backup_count} backups in the ${BACKUP_DIR}. No cleanup required."
  fi
}

check_backup() {
  log_message "Verifying backup in S3 bucket: ${S3_BUCKET}"
  if (aws s3 ls ${S3_BUCKET}/ | awk '{print $4}' | grep --quiet "neo4j-${ENV}-${DATE}.dump") ; then
    log_message "Daily backup is in S3 bucket: ${S3_BUCKET}"
    generate_metrics 1

    clear_s3_backup

  else
    log_message "Backup doesn't found!"
    generate_metrics 0
    exit 1
  fi
  }

clear_s3_backup() {
    file_count=$(aws s3 ls "${S3_BUCKET}/" | wc -l)
    log_message "New backup is in ${S3_BUCKET} and bucket contains ${file_count} files"

    if [[ "${file_count}" -gt 14 ]]; then
    log_message "Cleaning up old backups (older than 14 days)"
    aws s3 ls "${S3_BUCKET}/" | while read -r line; do
      file_date=$(echo "$line" | awk '{print $1}')
      file_name=$(echo "$line" | awk '{print $4}')
        if [[ -n "${file_name}" ]]; then
        file_timestamp=$(date -d "${file_date}" +%s)
        cutoff_timestamp=$(date -d "-14 days" +%s)
          if [[ "${file_timestamp}" -lt "${cutoff_timestamp}" ]]; then
      log_message "Deleting old backup: ${file_name} was created ${file_date}"
      aws s3 rm "${S3_BUCKET}/${file_name}"
          fi
        fi
      done
    fi
}

create_backup

log_message "Backup process completed successfully"
