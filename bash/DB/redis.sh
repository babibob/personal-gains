# Startup parameters
redis-server --loglevel debug \
    --list-max-ziplist-entries 2048 \
    --list-max-ziplist-value 10000 \
    --list-compress-depth 1 \
    --set-max-intset-entries 2048 \
    --hash-max-ziplist-entries 2048 \
    --hash-max-ziplist-value 10000

# Redis TTL Large Set of Keys
redis-cli --scan --pattern "spribeBetCache::*" | \
    while read LINE ; \
        do TTL=`redis-cli ttl "$LINE"`; \
            if [ $TTL -eq  -1 ]; then 
                echo "$LINE"; redis-cli expire "$LINE" 129600; 
            fi; 
        done;

# Create backup
export FOLDER=$(date '+%y/%m/%d')
mkdir -p /nightly/$FOLDER/redis
echo save | redis-cli -a ${REDIS_PASS} -h ${REDIS_HOST} --rdb /nightly/$FOLDER/redis/dump.rdb