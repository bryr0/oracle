#!/bin/bash
#################################
# Gap sequence standby          #
#                               #
# Version 1.1                   #
# Created by: Bryan A.          #
# Date:       10-FEB-17         #
# EMAIL: xx.bryan.xx@msn.com    #
#################################

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


$ORACLE_HOME/bin/sqlplus / as sysdba  << EOF
spool $HOME/standby_check.log
select  'Last Applied on Standby  : ' Logs, 
                to_char(max(FIRST_TIME),'DD-MON-YY:HH24:MI:SS') Time, 
                max(sequence#) sequence#
from    v\$log_history
where first_time >= (SELECT MAX(FIRST_TIME) FROM V\$LOG_HISTORY GROUP BY THREAD#);
spool off;
exit;
EOF

