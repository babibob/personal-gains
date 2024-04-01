# Counting network connects from unique IP
ss -ntu | awk '{print $5}' | grep -vE "(Address|Local|servers|127.0.0.1)" | sort | uniq -c | sort -n| sed 's/^[ \t]*//' | awk '{if ($1 > 1) print $1" "$2}'

# Counting nginx requests from IPs (last 1000 lines)
tail -n 1000 /var/log/nginx/access.log | awk '{print $1}' | sort -n | uniq -c | sort -n | tail -n1000 | awk '{if ($1 > 10 ) print $2}'
# or
cat /var/log/nginx/access.log | awk '{print $1}' | sort -n | uniq -c | sort -n | tail -n1000 | awk '{if ($1 > 10 ) print $2}'

# List of established connections
ss -lantp | grep ESTAB | awk '{print $5}' | awk -F: '{print $1}' | sort -u

# Show how iptables works
watch -n 2 -d iptables -nvL

# It will only allow ten connection for single IP
iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 32 -j REJECT --reject-with tcp-reset