#!/bin/bash
#show connection
echo "Connected user name ${COMMON_NAME} and ip ${IFCONFIG_POOL_REMOTE_IP}"

#get list of user routes
ADDRESS_LIST=$(cat /etc/openvpn/nft/${COMMON_NAME})
LOCAL_NET=10.22.20.0/22

#add all user routes to firewall
for ROW in ${ADDRESS_LIST};
do
	echo added route ${ROW} for ${COMMON_NAME};
	nft add rule corp FORWARD ip saddr ${IFCONFIG_POOL_REMOTE_IP} ip daddr ${ROW} accept;
done
#drop all other routes
nft add rule corp FORWARD ip saddr ${IFCONFIG_POOL_REMOTE_IP} ip daddr ${LOCAL_NET} accept
nft add rule corp FORWARD ip saddr ${IFCONFIG_POOL_REMOTE_IP} ip daddr 8.8.8.8/32 accept
nft add rule corp FORWARD ip saddr ${IFCONFIG_POOL_REMOTE_IP} ip daddr 1.1.1.1/32 accept
nft add rule corp FORWARD ip saddr ${IFCONFIG_POOL_REMOTE_IP} ip daddr 0.0.0.0/0 drop
