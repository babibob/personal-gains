sudo su -
su postgres

BACKUP_FILE="template_name_$(date +%Y_%m_%d).full.gz"
S3_BUCKET=s3://backup_backet_name

export AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXX"
export AWS_SESSION_TOKEN="XXXXXXXXXXX"

pg_dumpall | gzip > ${BACKUP_FILE}
aws s3 cp "${BACKUP_FILE}" "${S3_BUCKET}"

########################################################################################################################v
# Create postgresssql backup
export FOLDER=$(date '+%y/%m/%d')
mkdir -p /nightly/$FOLDER/postgres
PGPASSWORD="${POSTGRES_PASS}" pg_dump   --no-owner \
                                        -h ${POSTGRES_HOST} \
                                        -p ${POSTGRES_PORT} \
                                        -U ${POSTGRES_USER} \
                                        ${POSTGRES_DB} > /nightly/$FOLDER/postgres/postgres.sql

# Restore postgress from database backup
pg_restore --host=<HOSTNAME> --username=<USERNAME> --password -f ./backup_file.sql
psql --host=<HOSTNAME> --username=<USERNAME> --password -d DBNAME < ./db_dump.sql


# Transfer bases from one to another
psql -h <SRV-02> -l                                         # List db on SRV-02
createdb -h <SRV-02>  -T template0 <newbase>                # Create db, before transfer it
apt install postgresql-client-<VERSION>                     # Install client for create remote connection
pg_dump -h <SRV-01> <oldbase> | psql -h <SRV-02> <newbase>  # Transfer db's between servers



#PostgreSQL full dump to s3


sudo su -
su postgres
archive="db_name_$(date +%Y_%m_%d).full.gz"
pg_dumpall | gzip > ${archive}
export AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXX"
export AWS_SESSION_TOKEN="XXXXXXXXXXX"
s3cmd put ${archive} s3://path/to/backet
