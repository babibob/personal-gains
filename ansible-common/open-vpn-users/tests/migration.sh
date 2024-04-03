#!/bin/bash

HOME=openvpn
#$1 group_file_name
LIST=$(cat groups/$1 )

touch migrator/$1

for DNAME in ${LIST};
do
    MADDR=$(host ${DNAME} | awk '{print $NF}')
    MCOUNT=$(host ${DNAME} | grep "has address" | wc -l)

    if [[ ${MCOUNT} == 1 ]]
    then
        echo ${MADDR} >> migrator/$1 ;
    else
        echo ${DNAME} >> migrator/$1 ;
    fi
done
