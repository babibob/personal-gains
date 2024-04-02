#### Configuration file parameters
```
trace :
    name (correct if it will be 'fqdn')
In this part we will create 2 metrics:
1. exporter-daemon_trace_up{target="name"} (0,1)
2. exporter-daemon_trace_latency{target="name"} (int, ms)

systemd :
    name (Systemd service name. for example, mysql)
In this part we will create 2 metrics:
1. exporter-daemon_systemd_up{target="name"} (0,1)
2. exporter-daemon_systemd_uptime{target="name"} (int, s)

fileModify :
    name (We will look to than file date)
In this part we will create 1 metric:
1. exporter-daemon_file_modify{target="name"} (int, s)
```
#### Usefull commands
```
trace_up ping yc-mysql01.local.maf.io -c 1 | grep packets | cut -d ' ' -f1
trace_latency ping yc-mysql01.local.maf.io -c 1 | grep round-trip | cut -d '/' -f6
systemd_up systemctl show exim4 --property ActiveState | cut -d'=' -f2
systemd_uptime systemctl show exim4 --property StateChangeTimestamp | cut -d'=' -f2 | xargs -I line date -d 'line' '+%s'
file_modify stat -c '%Y' /home/mora/.bashrc
```