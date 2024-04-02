#!/bin/bash
DATE=`date -d"-31 days" +%Y%m%d`
LIST=`curl -s 'http://<USER>:<PASSWORD>@localhost:9200/_cat/indices?v' | awk '/gb|mb/' | awk '{print $3}'`

while IFS= read -r line;
do
    INDEX_DATE=`echo $line | awk -F"-" '{print $NF}' | sed 's/\.//g'`
    if [ ${INDEX_DATE} -lt ${DATE} ];
    then
        COMMAND=`curl -XDELETE "http://<USER>:<PASSWORD>@localhost:9200/$line"` ;
    fi
done <<< "${LIST}"
