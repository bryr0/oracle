#!/bin/bash
#################################
# Check TABLE_SPACE             #
#                               #
# Version 1.1                   #
# Created by: Bryan A.          #
# Date:       27-Feb-17         #
# EMAIL: xx.bryan.xx@msn.com    #
#################################

#correo  
EMAIL=xx.bryan.xx@msn.com
#Porcentaje de uso
PORCENT=85;
#tamaño para autoextensible ( unlimited=32768 )
SIZE=32768

CLIENT="test"
HOSTNAME=$(hostname)

DPATH=/tmp

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

sqlplus / as sysdba  << EOF > $DPATH/table_space.log
select df.tablespace_name "Tablespace",
totalusedspace "Used MB",
df.totalspace "Total MB",
autoextensible,
cantidad_datafiles
from
(select tablespace_name,
round(sum(bytes) / 1048576) TotalSpace,
max(autoextensible) autoextensible,
count(tablespace_name) cantidad_datafiles
from dba_data_files 
group by tablespace_name) df,
(select round(sum(bytes)/(1024*1024)) totalusedspace, tablespace_name
from dba_segments 
group by tablespace_name) tu
where df.tablespace_name = tu.tablespace_name
order by 3 desc;
EOF
#eliminamos datos de conexion y espacios en blanco
Sanear(){
	sed '1,13d' $DPATH/$1.log > $DPATH/log.log
	sed '/^$/d' $DPATH/log.log > $DPATH/$1.log
	sed '/AUT/d' $DPATH/$1.log > $DPATH/tmp.log
	sed '/rows/d' $DPATH/tmp.log > $DPATH/log.log
	sed '/SQL>/d' $DPATH/log.log > $DPATH/tmp.log
	sed '/Automatic/d' $DPATH/tmp.log > $DPATH/$1.log
	sed '/TABLESPACE_NAME/d' $DPATH/$1.log > $DPATH/log.log
	sed '/----/d' $DPATH/log.log > $DPATH/$1.log
}
Sanear table_space

while read -r values
do
  
  T_NAME=$(echo $values | awk '{print $1}')
  T_USED=$(echo $values | awk '{print $2}')
  T_SIZE=$(echo $values | awk '{print $3}') 
  A_E=$(echo $values | awk '{print $4}')
  T_CON=$(echo $values | awk '{print $5}')
  TOTAL=0

if [ $A_E == YES ] && [ $T_CON -eq 1 ]; then
	T_PU_A=$(( ( $T_USED * 100 ) / $SIZE  ))
fi

if [ $A_E == NO ] && [ $T_CON -eq 1 ]; then
        T_PU_A=$(( ( $T_USED * 100 ) / $T_SIZE  ))
fi

if [ $T_CON -ge  2 ]; then

sqlplus / as sysdba  << EOF > $DPATH/table_cont.log
select autoextensible,round( ( bytes/1024 )/1024,0 ) from dba_data_files where tablespace_name='$T_NAME';
EOF

Sanear table_cont

while read -r line
do

A_UT=$(echo $line | awk '{print $1}')
A_TS=$(echo $line | awk '{print $2}')

if [ $A_UT == YES ]; then
 TOTAL=$(( $TOTAL + $SIZE ))
else
 TOTAL=$(( $TOTAL + $A_TS ))
fi

done < $DPATH/table_cont.log

T_PU_A=$(( ( $T_USED * 100 ) / $TOTAL  ))

fi

if [ $PORCENT -le $T_PU_A ]; then
#echo "es $T_PU_A $T_NAME con $T_CON y total es $TOTAL"

echo "EL table space $T_NAME SE ENCUENTRA al $T_PU_A% de uso" |  mail -s "CUSTOMER: $CLIENT,ALERTA $ORACLE_SID TABLE SPACE $T_NAME"  $EMAIL
fi

done <  $DPATH/table_space.log

#eliminar archivos creados
rm -rf $DPATH/log.log
rm -rf $DPATH/tmp.log
rm -rf $DPATH/table_cont.log
