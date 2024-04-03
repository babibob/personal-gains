# Backup etcd database
export ETCDCTL_API=3
touch "ca.pem"
touch "host.pem"
touch "host-key.pem"

echo "${CA_PEM_ETCD}" >> ca.pem
echo "${PEM_ETCD}" >> host.pem
echo "${PEM_KEY_ETCD}" >> host-key.pem

etcdctl --cacert="./ca.pem" --cert="./host.pem" --key="./host-key.pem" --endpoints=${ETCD_ENDPOINT} snapshot save /nightly/$FOLDER/etcd_vault/yoh2.db