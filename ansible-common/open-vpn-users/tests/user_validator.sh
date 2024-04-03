#!/bin/bash

CONFIG_PATH="./list"

LEGAL=$(cat ${CONFIG_PATH} | egrep "^[^0-9|A-Z]{1}\.?[^0-9|A-Z|\.]{2,20}=" | wc -l)
CURRENT=$(cat ${CONFIG_PATH} | wc -l)

if [[ ${LEGAL} != ${CURRENT} ]];
then
    echo "User validation failed!";
    exit 1;
fi
echo "User validation succeed!"