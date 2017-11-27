#!/bin/bash
########################## 
# Check Linux Health     #
# 1. CPU                 # 
# 2. Memory & Swap       #
# 3. DISK I/O            #
# 4. Disk free Space     #
#                        #
# Version 1.0            #
# Created by: Carlos S.  #
# Date:       9-Sep-16   # 
##########################

# --- Environment --- #
CUSTOMER="Company name"
MAILTO=user@gmail.com
SERVER=$(uname -n)
 
# --- High Water Marks --- #
typeset -i CPUHWM=90
typeset -i PAGHWM=60
typeset -i TMHWM=90
typeset -i FREEHWM=90
 
# --- Vars --- #
typeset -i CPU PAG TM
 
CPU=$(vmstat 1 1 | tail -1 | awk '{print $13+$14}')
[ $CPU -gt $CPUHWM ] && echo "CPU exceeded $CPU us+sy percent on $SERVER" | mailx -s "Customer: $CUSTOMER  CPU alert for $SERVER (${CPU}%)" $MAILTO
 
free -m | grep -i swap | while read junk SW_TOTAL SW_USED SW_FREE
do
# Use the bc utility in a here document to calculate
# the percentage of free and used swap space.
PERCENT_USED=$(bc <<EOF
scale=4
($SW_USED / $SW_TOTAL) * 100
EOF
)
PERCENT_FREE=$(bc <<EOF
scale=4
($SW_FREE / $SW_TOTAL) * 100
EOF
)
done

PG=`echo "$PERCENT_USED" | bc -l`
PAG=`echo ${PG%.*}`

[ $PAG -gt $PAGHWM ] && echo "PAGING exceeded $PAG pi+po pages on $SERVER" | mailx -s "Customer: $CUSTOMER  Paging alert for $SERVER (${PAG}/s)" $MAILTO
 
for DISK in $(lsblk -io KNAME,TYPE | grep 'disk\|lvm' | awk '{print $1}')
do
  TPS=$(iostat -d $DISK | grep $DISK | awk '{print $2}')
  TM1=`echo "$TPS" | bc -l`
  TM=`echo ${TM1%.*}`
  [ $TM -gt $TMHWM ] && echo "Disk $DISK exceeded ${TM}% tm_act on $SERVER" | mailx -s "Customer: $CUSTOMER  DiskIO alert for $SERVER ($DISK ${TM}%)" $MAILTO
done
 
# Excluded mount points *must* be pipe delimited
# "/proc|/export/home|Mounted" should always be included

EXCLUDE=/proc|/export/home|Mounted

df -HlP | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
    do
      usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1 )
      partition=$(echo $output | awk '{ print $2 }' )
     
        if [ $usep -ge ${FREEHWM} ]; then
        echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" |
        echo "DISK SPACE ALERT: $output" | mailx -s "Customer: $CUSTOMER  Disk Space Alert: ${output} used on `hostname `" $MAILTO
        fi
    done


