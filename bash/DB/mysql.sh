# Create mysql backup specific DB
mysqldump -hHOST -uUSERNAME -p DBNAME > DBNAME.sql

# Create mysql backup all DB
mysqldump -A --opt --flush-privileges --routines > mysql.sql

# Restore mysql from database backup
pv /path/to/base | mysql -hdbs.<STAGE>.local -u USERNAME -p DB_NAME

# Create backups separetly
export FOLDER=$(date '+%y/%m/%d')
mkdir -p /nightly/$FOLDER/mysql_n8n
for db in $(mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASS} -e 'SHOW DATABASES' -s --skip-column-names | grep -v 'information_schema\|performance_schema'); \
do \
    echo $db; \
    mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASS} --opt $db > /nightly/$FOLDER/mysql/$db.sql; \
done

# Create dump of bacula database
mysqldump -h${BACULA_MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASS} --opt bacula --column-statistics=0 > bacula.sql