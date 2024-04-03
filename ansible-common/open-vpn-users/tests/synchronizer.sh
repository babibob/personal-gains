#!/bin/bash

HOME=/etc/openvpn

NFT_PATH=${HOME}/nft
USERS_PATH=${HOME}/users
GROUPS_PATH=${HOME}/groups
PERM_FILE=${HOME}/list

#echo "${HOME}, ${NFT_PATH}, ${USERS_PATH}, ${GROUPS_PATH}, ${PERM_FILE}"

echo "Sync started"
USER_LIST=$(cat /etc/openvpn/list | cut -d '=' -f1)

for USER in ${USER_LIST};
do
    #echo clear $USER config;
    echo > ${NFT_PATH}/${USER} ;
    echo > ${USERS_PATH}/${USER} ;

    #echo add routes to ${USER};
    cat ${PERM_FILE} | grep ${USER} | cut -d'=' -f2 | tr ',' '\n' | xargs -I line cat ${GROUPS_PATH}/line | xargs -I line echo push \"route line\" >> ${USERS_PATH}/${USER} ;
    cat ${PERM_FILE} | grep ${USER} | cut -d'=' -f2 | tr ',' '\n' | xargs -I line cat ${GROUPS_PATH}/line | xargs -I line echo line >> ${NFT_PATH}/${USER} ;
    sed -i 's/\/32/ 255.255.255.255/g' ${USERS_PATH}/${USER};
    sed -i 's/\/24/ 255.255.255.0/g' ${USERS_PATH}/${USER};
    echo "USER ${USER} configured";
done
echo "Work done"