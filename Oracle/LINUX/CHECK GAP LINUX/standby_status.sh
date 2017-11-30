#!/bin/bash
#################################
# CHECK GAP PRIMARY DB   		#
#                      			#
# Version 1.3           		#
# Created by: Bryan A.  		#
# Date:       18-Jan-17  		#
# EMAIL: xx.bryan.xx@msn.com    #
#################################

EMAIL=xx.bryan.xx@msn.com
REMOTEHOST=dbprod2

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

    *)
    echo "sorry unknow: "$OS;
    exit 1;
    ;;
    esac
}

DSO $1


$ORACLE_HOME/bin/sqlplus / as sysdba  << EOF > $HOME/stdbystatus_temp.log
alter system switch logfile;
spool $HOME/primary_check.log
select  'Last Generated on Primary: ' Logs, 
                to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time, 
                sequence#
from    v\$archived_log
where   sequence# = (select cast(to_char(max( decode (archived, 'YES', sequence#, 0)) ) as varchar2(10)) from v\$log group by thread#);
spool off;
exit;
EOF

ssh oracle@$REMOTEHOST "sh $HOME/standby_check.sh $1" >> $HOME/stdbystatus_temp.log
echo "Estado de Sincronizacion $1 y Standby" > $HOME/stdbystatus.log
echo " " >> $HOME/stdbystatus.log
awk 'c-->0;$0~s{if(b)for(c=b+1;c>1;c--)print r[(NR-c+1)%b];print;c=a}b{r[NR%b]=$0}' b=2 a=0 s="Last Generated" $HOME/stdbystatus_temp.log >> $HOME/stdbystatus.log
awk 'c-->0;$0~s{if(b)for(c=b+1;c>1;c--)print r[(NR-c+1)%b];print;c=a}b{r[NR%b]=$0}' b=0 a=0 s="Last Applied" $HOME/stdbystatus_temp.log >> $HOME/stdbystatus.log


PRIMARY=`awk 'c-->0;$0~s{if(b)for(c=b+1;c>1;c--)print r[(NR-c+1)%b];print $6;c=a}b{r[NR%b]=$0}' b=0 a=0 s="Last Generated" $HOME/stdbystatus_temp.log`
STANDBY=`awk 'c-->0;$0~s{if(b)for(c=b+1;c>1;c--)print r[(NR-c+1)%b];print $7;c=a}b{r[NR%b]=$0}' b=0 a=0 s="Last Applied" $HOME/stdbystatus_temp.log`
GAP=`expr $PRIMARY - $STANDBY` 
echo "Gap with Standby Database:                    " $GAP >> $HOME/stdbystatus.log
cat $HOME/stdbystatus.log
mail -s "Estado de Replica de Base de datos: $1" $EMAIL < $HOME/stdbystatus.log
