#!/bin/bash

GROUP_PATH="./groups"
USERS_FILE="./list"

LEGAL_LIST=$(ls ${GROUP_PATH})
CURRENT_LIST=$(cat ${USERS_FILE} | cut -d'=' -f2 | tr ',' '\n' | sort -u)

#echo "${LEGAL_LIST}, ${CURRENT_LIST}"

for ROW in ${CURRENT_LIST} ;
do
    if [[ ! ${LEGAL_LIST} =~ ${ROW} ]];
    then
        echo "wrong group name ${ROW}";
        PASS="No";
    fi;
done
if [[ ${PASS} == "No" ]];
then
    echo "group test have not passed";
    exit 1;
fi

RESOLVING=$(cat ${GROUP_PATH}/* | xargs -I line host -t A line | grep -v "10\|192\.168\|has address"|  wc -l )
if [[ ${RESOLVING} != 0 ]];
then
    echo "host {RESOLVING} failed!";
    exit 1;
fi
echo "Group names validation success!"
