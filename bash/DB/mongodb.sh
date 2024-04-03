# Create backup mongo
FOLDER=$(date '+%y/%m/%d')
mkdir -p /nightly/$FOLDER/mongo
mongodump --host ${MONGO_HOST01},${MONGO_HOST02} \
    -u ${MONGO_USER} \
    -p ${MONGO_PASS} \
    --readPreference=secondary \
    --out=/nightly/$FOLDER/mongo/

tar czvf archive.tgz ./<DUMPNAME>