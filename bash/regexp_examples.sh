# Find '.' after ':' , but befor ' [A-Z]' (without that letters)
egrep (:?\.)\s(?=[A-Z])

# Find iptables rules path
cat /usr/lib/systemd/system/iptables.service | grep AssertPathExists | grep -oP '(?<=\w=).*'

# Removing duplicates
awk '!seen[$0]++' <NAME> >  <NEW_NAME>

# Removing comments in file <NAME>
grep -E -v '[;#]|^$' <NAME>
# OR
sed '/^[;|#]/d' <NAME> | sed '/^$/d'
