# Show DNS for cert
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -text | grep -Po 'DNS:\K[^,]+'

# Solted passwword
openssl passwd -1 -salt My_SaltY0u_must-use_another And_another-paSsW0rd

# The use of printf (as opposed to echo) prevents encoding a newline in the password.
printf "my_username:my_password" | openssl base64 -A
