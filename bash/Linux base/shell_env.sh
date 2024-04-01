# History full clean
cat /dev/null> ~ /.bash_history && history -c && exit

# Messages about sshd from the last boot in the reverse order:
journalctl -t sshd -b0 -r

# Define PHP_USER and PHP_GROUP values
PHP_USER=$(php -i | grep --only-matching --perl-regexp 'fpm-user=\K[A-Za-z0-9\-\.]*')
PHP_GROUP=$(php -i | grep --only-matching --perl-regexp 'fpm-group=\K[A-Za-z0-9\-\.]*')

# List services
systemctl list-units --type=service

# Show random symbols
alias randpw='< /dev/urandom tr -dc 'a-zA-Z0-9[^\p{L}\d\s@#]' | fold -w 12 | head -n 5'

# Show ssh activity on host
last -i
journalctl -t sshd -b0 -r