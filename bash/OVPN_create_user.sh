#!/bin/bash

if [ $# -ne 2 ]; then
  echo "usage $0 <USERNAME> <ZIPFILE>"
  echo "example :"
  echo "    $0 itstest /root/itstest.zip"
  exit 1
fi

USERNAME=$1
ZIPFILE=$2

cd /etc/openvpn/easy-rsa
echo '' | ./easyrsa gen-req "${USERNAME}" nopass
#echo 'yes'|./easyrsa sign-req client "${USERNAME}"
expect -c   'set timeout -1; \
            spawn ./easyrsa --batch sign-req client '"${USERNAME}"'; \
            expect "Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:"; \
            send -- "greatejob\n"; \
            expect eof'

rm -f /tmp/openvpn.conf

cat <<EOF > /tmp/openvpn.conf
client
dev tun
proto udp
remote <OVPN_SERVER_ADDR>
port 443
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
ca ca.crt
cert ${USERNAME}.crt
key ${USERNAME}.key
auth-user-pass
tls-auth ta.key 1
EOF

zip -j "${ZIPFILE}" ./pki/ca.crt ./pki/ta.key ./pki/issued/"${USERNAME}".crt ./pki/private/"${USERNAME}".key /tmp/openvpn.conf

rm -f /tmp/openvpn.conf
