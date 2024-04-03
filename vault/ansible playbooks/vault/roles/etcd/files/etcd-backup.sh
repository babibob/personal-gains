#!/bin/bash
#
# etcd backup script
# Southbridge LLC, 2018 A.D.
#
# set -x
set -o nounset
set -o errtrace
set -o pipefail

readonly TERM=xterm-color
export TERM

# DEFAULTS BEGIN
declare BACKUP_DIR=/var/backups/etcd
declare BACKUP_KEEP_DAYS=90
declare BACKUP_ARC=gzip
declare ETCD_CERT_DIR=/etc/ssl/etcd
declare ETCD_CA_CERT_FILE=${ETCD_CERT_DIR}/ca.crt
declare ETCD_ADMIN_CERT_FILE=${ETCD_CERT_DIR}/admin.crt
declare ETCD_ADMIN_KEY_FILE=${ETCD_CERT_DIR}/admin.key
declare ETCD_URL=https://127.0.0.1:2379

declare MAILTO=""
# DEFAULTS END

# CONSTANTS BEGIN
export ETCDCTL_API=3
readonly PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
readonly bn="$(basename "$0")"
readonly currdir="$(dirname "$0")"
readonly BIN_REQUIRED="etcdctl"
# CONSTANTS END

DATE="$(date +%Y-%m-%d_%H%M)"                            # Datestamp e.g 2002-09-21

if [ -f "$currdir/etcd-backup.conf" ]; then
  . "$currdir/etcd-backup.conf"
fi

snapshot_save() {
    local fn=${FUNCNAME[0]}
    local file=$1
    trap 'except $LINENO' ERR
    trap _exit EXIT

    etcdctl \
      --cacert="$ETCD_CA_CERT_FILE" \
      --cert="$ETCD_ADMIN_CERT_FILE" \
      --key="$ETCD_ADMIN_KEY_FILE" \
      --endpoints="$ETCD_URL" \
      snapshot save "$file" >/dev/null 2>&1
}

snapshot_gzip() {
    local fn=${FUNCNAME[0]}
    local file=$1
    trap 'except $LINENO' ERR
    trap _exit EXIT

    if [ "$BACKUP_ARC" == gzip ]; then
      gzip "$file"
    fi
}

_checks() {
    local fn=${FUNCNAME[0]}
    # Required binaries check
    for i in $BIN_REQUIRED; do
        if ! command -v "$i" >/dev/null
        then
            echo_err "required binary '$i' is not installed"
            false
        fi
    done
}

except() {
    local ret=$?
    local no=${1:-no_line}

    echo_fatal "error occured in function '$fn' on line ${no}."

    logger -p user.err -t "$bn" "* FATAL: error occured in function '$fn' on line ${no}."
    exit $ret
}

_exit() {
    local ret=$?

    exit $ret
}

readonly C_RST="tput sgr0"
readonly C_RED="tput setaf 1"
readonly C_GREEN="tput setaf 2"
readonly C_YELLOW="tput setaf 3"
readonly C_BLUE="tput setaf 4"
readonly C_CYAN="tput setaf 6"
readonly C_WHITE="tput setaf 7"

echo_err() { $C_WHITE; echo "* ERROR: $*" 1>&2; $C_RST; }
echo_fatal() { $C_RED; echo "* FATAL: $*" 1>&2; $C_RST; }
echo_warn() { $C_YELLOW; echo "* WARNING: $*" 1>&2; $C_RST; }
echo_info() { $C_CYAN; echo "* INFO: $*" 1>&2; $C_RST; }
echo_ok() { $C_GREEN; echo "* OK" 1>&2; $C_RST; }

_checks
mkdir -p "${BACKUP_DIR}"
snapshot_save "${BACKUP_DIR}/etcd-snapshot-${DATE}.db"
snapshot_gzip "${BACKUP_DIR}/etcd-snapshot-${DATE}.db"

# remove old backups
/usr/bin/find "$BACKUP_DIR/" -mtime "+$BACKUP_KEEP_DAYS" -type f -delete

## EOF ##
