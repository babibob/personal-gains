#!/usr/bin/env bash

STORAGE_DIR=/opt/backup
DATE=$(date +%F)
STORE_DAYS=6
REMOTE_HOST=backup.storage.local
REMOTE_DIR=/projects
REMOTE_USER=ansadm
CURRENT_HOST=$(hostname)
SSH_KEY_PATH=/root/.ssh/id-rsa

function log_delimiter() {
  echo "================================================================="
}

function log() {
  echo "[$(date +"%F %T")] $1"
}

function timer() {
  [ "$1" == "start" ] && {
    _STIME=$(date +%s)
  } || {
    _ETIME=$(date +%s)
    _DURATION=$(($_ETIME - $_STIME))
    (echo "[$(date +"%F %T")] $1 for $_DURATION seconds")
  }
}

function create_project_dir() {
  [ ! -d "${WORKDIR}" ] && mkdir -p ${WORKDIR}
}

function backup_rpm() {
  timer start
  log_delimiter
  log "Remove backups older than ${STORE_DAYS} days"
    find ${WORKDIR} -type f -ctime +${STORE_DAYS} -delete
    [[ "$?" -ne 0 ]] && exit 1
  log "Getting installed packages list"
    rpm -qa > ${WORKDIR}/${PROJECT}_${DATE}.txt
    [[ "$?" -ne 0 ]] && exit 1
  log "Creating md5sum of ${PROJECT} backup archive"
    md5sum ${WORKDIR}/${PROJECT}_${DATE}.txt > ${WORKDIR}/${PROJECT}_${DATE}.txt.md5sum
    [[ "$?" -ne 0 ]] && exit 1
  log "md5sum is $(cat ${WORKDIR}/${PROJECT}_${DATE}.txt.md5sum)"
  timer "Done"
  log_delimiter
}

function backup_dpkg() {
  timer start
  log_delimiter
  log "Remove backups older than ${STORE_DAYS} days"
    find ${WORKDIR} -type f -ctime +${STORE_DAYS} -delete
    [[ "$?" -ne 0 ]] && exit 1
  log "Getting installed packages list"
    dpkg-query -f '${binary:Package}=${source:Version} ${Status}\n' -W |grep installed |cut -d' ' -f1 > ${WORKDIR}/${PROJECT}_${DATE}.txt
    [[ "$?" -ne 0 ]] && exit 1
  log "Creating md5sum of ${PROJECT} backup archive"
    md5sum ${WORKDIR}/${PROJECT}_${DATE}.txt > ${WORKDIR}/${PROJECT}_${DATE}.txt.md5sum
    [[ "$?" -ne 0 ]] && exit 1
  log "md5sum is $(cat ${WORKDIR}/${PROJECT}_${DATE}.txt.md5sum)"
  timer "Done"
  log_delimiter
}

function backup_etc() {
  timer start
  log_delimiter
  log "Creating archive for /etc/ dir"
    tar -czf ${WORKDIR}/${PROJECT}_${DATE}.tar.gz /etc/
    [[ "$?" -ne 0 ]] && exit 1
#  log "Adding and committing new changes to git"
#    cd /etc
#    git add -A
#    git commit -am "Autocommit ${DATE}"
#  log "Pushing new changes to git"
#    git push -u origin $(hostname -f)
  timer "Done"
  log_delimiter
}

function remote_copy() {
  timer start
  log_delimiter
  log "Creating today's directory on ${REMOTE_HOST} if it doesn't exists"
    ssh -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}/${CURRENT_HOST}/${DATE}"
    [[ "$?" -ne 0 ]] && exit 1
  log "Copying backup to ${REMOTE_HOST}"
    rsync -avH -e "ssh -i ${SSH_KEY_PATH}" ${WORKDIR}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/${CURRENT_HOST}/${DATE}
    [[ "$?" -ne 0 ]] && exit 1
  timer "Done"
  log_delimiter
}

case "$1" in
  rpm )
    PROJECT=packages
    WORKDIR=${STORAGE_DIR}/${PROJECT}
    SERVER=$2
    create_project_dir
    backup_rpm ;;
  dpkg )
    PROJECT=packages
    WORKDIR=${STORAGE_DIR}/${PROJECT}
    create_project_dir
    backup_dpkg ;;
  etc )
    PROJECT=etc
    WORKDIR=${STORAGE_DIR}/${PROJECT}
    create_project_dir
    backup_etc ;;
  copy )
    WORKDIR=${STORAGE_DIR}
    remote_copy ;;
esac
