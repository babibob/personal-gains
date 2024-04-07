# cat purge-bareos-db-and-files.sh
#!/bin/bash

set -eox

# several days ago
DATEFROM=`date --date='190 days ago' '+%Y-%m-%d'`
BACKUPFOLDER="/mnt/bpool"

if [ $# -eq 1 ] ;
then
FILTER="$1%"
echo -e "Useing filter : \"${FILTER}\""
else
FILTER=""
echo -e "Filter is not using..."
fi

echo -e "Check all backups before ${DATEFROM}"

# get list of files to prune
#
echo "Reading VolumeName list from catalog"
if [ -z "${FILTER}" ] ;
then
DELETELIST=`echo -e "sqlquery\nselect VolumeName from Media where LastWritten < '${DATEFROM}' order by VolumeName;\n.\nexit" | \
    bconsole | \
    grep '^|' | \
    grep -v ' VolumeName ' | \
    sed -e 's/[ ]*|[ ]*//g' | \
    sed -e '/^[ \t]*$/d'`
else
DELETELIST=`echo -e "sqlquery\nselect VolumeName from Media where VolumeName LIKE '${FILTER}' order by VolumeName;\n.\nexit" | \
    bconsole | \
    grep '^|' | \
    grep -v ' VolumeName ' | \
    sed -e 's/[ ]*|[ ]*//g' | \
    sed -e '/^[ \t]*$/d'`
fi
if [[ -z "${DELETELIST}" ]] ;
then
echo "No records found earlier than ${DATEFROM}"
exit 1
else
DELETELISTRECORDCOUNT=`echo -e "${DELETELIST}" | wc -l`
echo " ${DELETELISTRECORDCOUNT} records found earlier than ${DATEFROM}"
read -p 'Type Y if you want to display it: ' input
echo
if [[ ${input,,} =~ ^y$  ]];
then
    echo -e "${DELETELIST}" | sed -e 's/^./  -x- &/;'
    read -p 'Press ENTER to continue: ' input
fi
fi

LONGESTLINE=`echo -e "${DELETELIST}" | sed -e 's|^.|'${BACKUPFOLDER}'/&|' | wc -L`
# Count file size in MB
echo -e "${DELETELIST}" | \
xargs -I{} stat --format="%n:%s" "${BACKUPFOLDER}/{}" | \
awk -v format="%${LONGESTLINE}s  %15d\n" -F: 'BEGIN{size=0}{size=size+$2; printf(format, $1, $2);} END {print "\nCommon file size: "size/1024/1024" M"}'

echo
echo "WARNING: IT WILL DESTROY THAT FILES ON THE DISK"
echo "Are you sure you want to proceed?"
read -p 'Type YES if you really want to proceed: ' input
echo
if [[ ${input} != "YES"  ]];
then
echo "Ok. Aborting."
exit 1
fi

# delete records from catalog database
echo -e "${DELETELIST}" | xargs -I '{}' echo delete yes volume='{}' | bconsole

# show command and execute
echo -e "${DELETELIST}" | \
xargs -I '{}' echo -e rm ${BACKUPFOLDER}/'{}' | \
while read LINE ; \
do
    echo -e "${LINE}"; \
    ${LINE}; \
done