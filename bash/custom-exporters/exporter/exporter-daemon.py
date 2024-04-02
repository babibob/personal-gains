#!/usr/bin/env python3
# locate - /usr/local/bin/

import os
import sys
import time
import yaml
from yaml.loader import SafeLoader
draftfile = "/tmp/exporter-daemon.file.draft"
result = "/var/lib/prometheus/node-exporter/exporter-daemon.prom"
while(True):
    # clear draft file
    os.popen("echo > /tmp/exporter-daemon.file.draft")

    # Open the file and load the data
    with open('/usr/local/etc/exporter-daemon.conf.yaml') as f:
        data = yaml.load(f, Loader=SafeLoader)
        #print(data['trace'])
        #print(data['systemd'])

    trace = data['trace'].split(' ')
    for key in trace:
        trace_up = os.popen("ping "+key+" -c 1 | grep packets | cut -d ' ' -f1").read()
        if trace_up == '':
            trace_up = '0'
        trace_latency = os.popen("ping "+key+" -c 1 | grep avg | cut -d '/' -f6").read()
        if trace_latency == '':
            trace_latency = '0'
        os.system("echo 'exporter_daemon_trace_up{target=\""+key+"\"} "+trace_up[:-1]+"' >> "+draftfile)
        os.system("echo 'exporter_daemon_trace_latency{target=\""+key+"\"} "+trace_latency[:-1]+"' >> "+draftfile)
    now = int(os.popen("date '+%s'").read())
    systemd = data['systemd'].split(' ')
    for key in systemd:
        # calculate systemd data
        systemd_up_temp = os.popen("systemctl show "+key+" --property ActiveState | cut -d'=' -f2").read()
        if systemd_up_temp == "active\n" :
            systemd_up = "1"
        else :
            systemd_up = "0"
        systemd_uptime_temp = os.popen("systemctl show "+key+" --property StateChangeTimestamp | cut -d'=' -f2 | xargs -I line date -d 'line' '+%s'").read()
        if systemd_uptime_temp == '' :
            systemd_uptime = '0'
        else:
            systemd_uptime = now - int(systemd_uptime_temp)
        # print it in file
        os.system("echo 'exporter_daemon_systemd_up{target=\""+key+"\"} "+systemd_up+"' >> "+draftfile)
        os.system("echo 'exporter_daemon_systemd_uptime{target=\""+key+"\"} "+str(systemd_uptime)+"' >> "+draftfile)
    fileModify = data['fileModify'].split(' ')
    for key in fileModify:
        modify_time_temp = os.popen("stat -c '%Y' "+key).read()
        modify_time = str(now - int(modify_time_temp))
        print(modify_time,now,modify_time_temp)
        os.system("echo 'exporter_daemon_file_modify{target=\""+key+"\"} "+modify_time+"' >> "+draftfile)
    os.system("mv "+draftfile+" "+result)
    time.sleep(15)