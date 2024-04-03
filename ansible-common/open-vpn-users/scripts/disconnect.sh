#!/bin/bash
#show connection
echo "disconnected user name ${COMMON_NAME} and ip released ${IFCONFIG_POOL_REMOTE_IP}"

#get list of user routes
HANDLE_LIST=$(nft --handle list chain corp FORWARD | grep $(IFCONFIG_POOL_REMOTE_IP) | awk '{print $NF}')

#drop all user routes from firewall
for ROW in ${HANDLE_LIST};
do
	#echo "handle ${ROW} deleted from nftables";
	nft delete rule corp FORWARD handle ${ROW};
done

