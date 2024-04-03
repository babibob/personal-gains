# Startup parameters
redis-server --loglevel debug \
    --list-max-ziplist-entries 2048 \
    --list-max-ziplist-value 10000 \
    --list-compress-depth 1 \
    --set-max-intset-entries 2048 \
    --hash-max-ziplist-entries 2048 \
    --hash-max-ziplist-value 10000


# Create backup
export FOLDER=$(date '+%y/%m/%d')
mkdir -p /nightly/$FOLDER/redis
echo save | redis-cli -a ${REDIS_PASS} -h ${REDIS_HOST} --rdb /nightly/$FOLDER/redis/dump.rdb