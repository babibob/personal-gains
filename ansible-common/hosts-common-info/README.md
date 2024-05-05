### Show info about docker containers from hosts file
``` shell
ansible-playbook docker_info.yml
```
### Show commom info about hosts from hosts file
``` shell
ansible-playbook main.yml --skip-tags "check_ip_in_rules"
```
### Check if CHECKED_IP exists in iptables rules
``` shell
ansible-playbook main.yml --tags "check_ip_in_rules"
```
### Ansible update PACKEGE on hosts from hosts file
``` shell
ansible ${HOST} -m command -a "test -e /usr/bin/apt && (apt -y update && apt-get install --only-upgrade ${PACKEGE}) || (yum update ${PACKEGE} -y)"
```