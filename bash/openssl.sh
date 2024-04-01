# Show DNS for cert
echo | openssl s_client -connect test-corporate.g5e.com:443 2>/dev/null | openssl x509 -noout -text | grep -Po 'DNS:\K[^,]+'