#!/bin/sh
##########################
# Check ASM SPACE        #
#                        #
# Version 1.1            #
# Created by: Bryan A.   #
# Date:       18-Jan-17  #
##########################

DPATH=$HOME/scripts

EMAIL=USER@GMAIL.com
DISK=90
CLIENT="COMPANY"
DPATH=/home/grid/scripts
#HOSTNAME=$(hostname -f)

if [ -z $1 ]; then
 echo $"Usage: $0 {Database name}";
 exit 1;
fi

DSO(){

    OS="`uname`"
    case $OS in
    'Linux')
      source $HOME/.bash_profile
	[ ! -z $1 ] && export ORACLE_SID=$1 
    ;;
    'AIX')
     source $HOME/.profile
	[ ! -z $1 ] && export ORACLE_SID=$1 
    ;;

    *) ;;
        esac
}
DSO $1

QUERY="SELECT name, ROUND(total_mb/100,0) AS total, 100-ROUND(((free_mb*100)/total_mb),0) AS used FROM v\$asm_diskgroup;"


sqlplus / as sysasm  << EOF > $DPATH/space_asm.log
$QUERY
EOF


Sanear(){
	sed '1,13d' $DPATH/$1.log > $DPATH/log.log
	sed '/^$/d' $DPATH/log.log > $DPATH/$1.log
	sed '/AUT/d' $DPATH/$1.log > $DPATH/tmp.log
	sed '/rows/d' $DPATH/tmp.log > $DPATH/log.log
	sed '/SQL>/d' $DPATH/log.log > $DPATH/tmp.log
	sed '/Automatic/d' $DPATH/tmp.log > $DPATH/$1.log
	sed '/NAME/d' $DPATH/$1.log > $DPATH/log.log
	sed '/----/d' $DPATH/log.log > $DPATH/$1.log
}

##########################
Sanear space_asm

while read -r values
do
  DISKNAME=$(echo $values | awk '{print $1}')
  USED=$(echo $values | awk '{print $3+1}')

  #re='^[0-9]+$'

 # if ! [[ $USED =~ $re ]] ; then
  #	 echo "Not is a number" #>&2; exit 1
 # fi

  if [ $USED -ge $DISK ] ; then	
      
      echo "EL DISKGROUP " $DISKNAME "SE ENCUENTRA AL " $USED"%" | mail -s "CLIENTE: $CLIENT,ALERTA DISGROUP $DISKNAME"  $EMAIL 
  fi

done <  $DPATH/space_asm.log

#####
rm -rf $DPATH/log.log
rm -rf $DPATH/tmp.log
