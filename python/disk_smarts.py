#!/usr/bin/env python3
import os
import sys
if sys.argv[1] == 'find':
    count = int(str(os.popen("lsblk | grep disk | grep -v 'zd'| wc -l").read())[:-1])+1
    print ('{')
    print ('"data":[')
    for i in range(1,count) :
        disk_name = str(os.popen("lsblk | grep disk | grep -v 'zd'| cut -d' ' -f1 | head -n "+str(i)+" | tail -n 1").read())[:-1]
        if i < count-1:
            print ('  {  "{#DISK}":"'+disk_name+'" },')
        else:
            print ('  {  "{#DISK}":"'+disk_name+'" }')
    print ('  ]')
    print ('}')
else:
    count = int(os.popen("sudo /usr/sbin/smartctl -a /dev/"+sys.argv[1]+" | sed -n '/SMART Error Log Version: 1/,/SMART Self-test log structure revision number 1/p' | wc -l ").read())
    if count > 5:
        print ('1')
    else:
        print ('0')

