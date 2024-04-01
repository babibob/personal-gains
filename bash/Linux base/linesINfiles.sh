# Removing duplicates
awk '!seen[$0]++' <NAME> >  <NEW_NAME>

# Removing comments
sed '/^;/d' <NAME> | sed '/^$/d'

sed '/^#/d' <NAME> | sed '/^$/d'

grep -E -v ';|^$' <NAME>