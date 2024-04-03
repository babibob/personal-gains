# Create postgresssql backup
export FOLDER=$(date '+%y/%m/%d')
mkdir -p /nightly/$FOLDER/postgres
PGPASSWORD="${POSTGRES_PASS}" pg_dump   --no-owner \
                                        -h ${POSTGRES_HOST} \
                                        -p ${POSTGRES_PORT} \
                                        -U ${POSTGRES_USER} \
                                        ${POSTGRES_DB} > /nightly/$FOLDER/postgres/postgres.sql

# Restore postgress from database backup
pg_restore --host=HOSTNAME --username=USERNAME --password -f ./backup_file.sql
psql --host=HOSTNAME --username=USERNAME --password -d DBNAME < ./db_dump.sql


