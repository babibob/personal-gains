"""Script for OVPN configuration"""
import os
import sys
from basefunc import clear_migration, \
    group_validator, \
    user_validator, \
    dublicate_name_validation, \
    migration, \
    group_from_aggr

#variables
REMOTE="ssh <USER>@<HOST02> sudo "
ISSUED="/root/subCA/pki/issued/"
REVOKED="/root/subCA/pki/revoked"
CURRENT="/etc/openvpn/list"
SYNC_BASH="/etc/openvpn/scripts/synchronizer.sh"

#functions
def list_difference(list1, list2):
    """func for find which rows of list1 not present in list2"""
    result = set(list1) - set(list2)
#    print ("diff start \n", list1, "yo\n", list2, "diff end \n", result)
    return result

def ca_active():
    """func for actual list of issued certificates"""
    list1 = os.popen(REMOTE+"ls "+ISSUED+" | sed 's/\.crt//'").read().split('\n')
#    print(list1)
    return list1

def user_conf():
    """func for actual list of users in ovpn configuration"""
    list1 = os.popen(REMOTE+"cat "+CURRENT+" | cut -d'=' -f1").read().split('\n')
#    print(list1)
    return list1

def users_to_create():
    """func producing list of users to create"""
    active = ca_active()
    user_list = user_conf()
    result = list_difference(user_list, active)
    return result

def users_to_revoke():
    """func producing list of users to revoke"""
    active = ca_active()
    user_list = user_conf()
    result = list_difference(active, user_list)
    return result

def create_user(todo_list):
    """func for calling ansible playbook for every user to create"""
    for row in todo_list:
#        os.popen("ansible-playbook ./user_create.book -e user_name="+row).read()
        print(row)

def revoke_user(todo_list):
    """func for calling ansible playbook for every user to revoke"""
    for row in todo_list:
#        os.popen("ansible-playbook ansible/revoke.user.book -e user=%s",(row)).read()
        print(row)

#arguments
if sys.argv[1] == "create":
    to_create = users_to_create()
    for row in to_create:
        print(row)

if sys.argv[1] == "revoke":
    to_revoke = users_to_revoke()
    for row in to_revoke:
        print(row)

if sys.argv[1] == "check":
    result1 = group_validator()
    result2 = dublicate_name_validation()
    group_from_aggr()
    migration()
    result3 = user_validator()
    if result1 == "error" or result2 == "error" or result3 == "error":
        sys.exit('check failed')

if sys.argv[1] == "migration":
    group_from_aggr()
    migration()

if sys.argv[1] == "clear_migration":
    clear_migration()