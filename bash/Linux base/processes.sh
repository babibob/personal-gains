
# List of 10 processes, that occupy the most RAM
ps axo rss,comm,pid | \
awk '{ proc_list[$2] += $1 ; } END { for (proc in proc_list) { printf("%d\t%s\n", proc_list[proc],proc) ; }}' | \
sort -n | \
tail -n 10 | \
sort -rn | \
awk '{ $1/=1024 ; printf "%.0fMB\t",$1 }{ print $2 }'

# Processes which use SWAP
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r | head -n 15

# CPU utilization in %
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
# OR
awk '{ u=$2+$4 ; t=$2+$4+$5 ; if (NR==1){u1=u ; t1=t ; } else print ($2+$4-u1) * 100 / (t-t1) "%" ; }' <(grep 'cpu ' /proc/stat) <(sleep 1 ; grep 'cpu ' /proc/stat)

# Show 5 processes which have the most copies
ps -ef | \
awk '{ print $8 }' | \
sort -n | \
uniq -c | \
sort -n | \
tail -5

# Kill all <NAME> process
for pid in $(ps aux | grep '<NAME>' | awk '{ print $2 }'); do kill -9 $pid ; done

# How much RAM use procces by <NAME>
ps -o vsz,rss,cmd --pid $(pgrep <NAME>)

# Show procces state by <NAME>
top -c -p $(pgrep -d',' -f <NAME>)

# Show utilization CPU cores
mpstat -P ALL

