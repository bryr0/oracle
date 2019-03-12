#!/bin/bash

# /_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
# _/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
# /_/_/_/_/                                      _/_/_/_/_/
# _/_/_/_/  _____  ____  _  ___ ___  _    __    _/_/_/_/_/
# /_/_/_/  / __  \/ __ \/ |/  / __ |/ \  / /   _/_/_/_/_/
# _/_/_/  / /_/ _/ /_/ /\   _/ /_/ /   \/ /   _/_/_/_/_/
# /_/_/  / /__/ / _, _/ /  // _,  / /\   /   _/_/_/_/_/
# _/_/   \_____/_/ |_/ /__//_/ \_/_/  \_/   _/_/_/_/_/
# /_/                                      _/_/_/_/_/
# _/                                      _/_/_/_/_/
# /_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
# _/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#
#           +============================+
#           |        [MysqlReport]       |
#           |     xx.bryan.xx@msn.com    |
#           +============================+
#           |         Version 1.4        |
#           |       Date:14-SEP-17       |
#           |      [Bryro.comli.com]     |
#           +----------------------------+


#### in case of error first connect and execute
#         set @@global.show_compatibility_56=on;


INAME="REPORT 1"

# if [ -z $1 ]; then
# echo "pls define host";
# exit 1;
# fi

####################
TMPF="/tmp"
HOSTNAME=$(hostname);
CONN="mysql --defaults-file=~/.my.cnf"
NOW=$(date +"%d-%m-%Y %l:%M:%S")

tput sc
echo "" > $TMPF/dbt.log
echo "" > ./check.html

Body(){
tput rc; tput el
printf "[+] exportando datos espere...."
echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>'$HOSTNAME'</title><style>body{font-family:Roboto,sans-serif;font-size:12.5px;line-height:1.5;color:#555;width:100%;background-color:#fafafa;text-align:center}section{margin-bottom:4rem;}.responsive-table,pre{text-align:left;background-color:#fff}*{box-sizing:border-box}h1.title{font-size:40px;font-weight:400;margin-top:50px;line-height:1.2;color:Tomato}h2.pre-title{margin-top:40px;font-weight:400}pre{min-width:240px;max-width:400px;margin:0 auto 40px;padding:8px 15px;border-radius:6px;box-shadow:0 0 3px rgba(0,0,0,.5) inset;overflow:auto}a{text-decoration:none}#stable>p{cursor:pointer}.responsive-table{border-collapse:collapse;margin:40px auto}.colaps{display:none}.responsive-table tr{border:1px solid #ccc}.responsive-table tr:hover{background-color:#f5f5f5}.responsive-table td,.responsive-table th{padding:3px 10px}.responsive-table th{text-align:center;color:#2EAFEA}@media(max-width:480px){.responsive-table{width:100%}.responsive-table thead{display:none}.responsive-table tbody tr:nth-of-type(even){background-color:#eee}.responsive-table tbody td{display:block}.responsive-table tbody td:before{content:attr(data-table);display:block;float:left;width:40%;margin-right:10px;padding-right:10px;font-weight:700;color:#2EAFEA;border-right:1px solid #ccc}.responsive-table tbody td:after{content:'';display:block;clear:both}}footer{position:fixed;left:0;bottom:0;height:50px;width:100%;background:#2EAFEA}footer p{color:#fff;margin-top:15px}</style></head><body><section><h1 class="title">'$INAME $NOW'</h1>' > ./check.html

}

Footer(){
echo '</section><footer><p>© 2017 <a href="https://github.com/bryr0/">bryr0</a> THANKS.</p></footer><script>var $=s=>document.querySelectorAll(s);document.addEventListener("click", function(e){"P"==e.target.tagName &&(t=document.getElementById("S_"+e.target.innerText),t.style.display=("none"==t.style.display||""==t.style.display)?"initial":"none")});</script></body></html>' >> ./check.html
tput rc; tput el
printf "[+] todos los datos exportando...."
tput rc; tput ed;
}

sanearb(){
        cat $1 | sed 's/[[:blank:]]//g' > $TMPF/sa.log
        cat $TMPF/sa.log > $1
}

sanear(){
  cat $1 | sed 's/\*//g'| sed -e 's/\<row\>//g'  > $TMPF/sa.log
  cat $TMPF/sa.log | sed '/^\s*$/d' > $1
}

OS(){
tput rc; tput el
printf "[+] exportando OS info espere...."
echo "" > $TMPF/so.log
echo "<h1 class='title'>$1</h1><table class='responsive-table'>" >> ./check.html
$2 > $TMPF/so.log
NLCC=0
sanear $TMPF/so.log

while read -r valuese
do
TD="td";

if [ $NLCC -eq 0 ]; then
    NLSS=$( echo "$valuese" | awk '{print NF}' | sort -n | uniq );
    TD="th"
    NLCC=1
fi

    echo "<tr>" >> ./check.html
        
  for i in `seq 1 $NLSS`
        do  
    DISK=$(echo "$valuese" | awk '{print $'$i'}')
                echo "<$TD>$DISK<$TD>" >> ./check.html
        done
    
    echo "</tr>" >> ./check.html
########## FINISH DEFINE COLUMMS ###########
done < $TMPF/so.log 

echo "</table>" >> ./check.html
}

EQ(){
tput rc; tput el
printf "[+] exportando Querys info espere...."

[ ! -z $3 ] && DTTS="use $3" #|| DTTS="use information_schema;"

NLCC=0 

$CONN<< EOFDB > $TMPF/tmpq.log
        $DTTS;
        $2
EOFDB

NEMPTY=$(cat $TMPF/tmpq.log);

if [ "$NEMPTY" != "" ]; then
 
sanear $TMPF/tmpq.log

echo "<h1 class='title'>$1</h1><table class='responsive-table'>" >> ./check.html

while read -r valuese
do
TD="td";


if [ $NLCC -eq 0 ]; then
    NLSS=$( echo "$valuese" | awk '{print NF}' | sort -n | uniq );
    TD="th"
    NLCC=1
fi

    echo "<tr>" >> ./check.html
        
  for i in `seq 1 $NLSS`
        do  
    DBDD=$(echo "$valuese" | awk -F'\t' '{print $'$i'}')
                echo "<$TD>$DBDD<$TD>" >> ./check.html
        done
    
    echo "</tr>" >> ./check.html
########## FINISH DEFINE COLUMMS ###########
done < $TMPF/tmpq.log

echo "</table>" >> ./check.html

fi
}

Querys(){

#######verision db
EQ "version db" "SELECT @@version, @@version_comment;"

###uptime######
EQ "uptime database" "select TIME_FORMAT(SEC_TO_TIME(VARIABLE_VALUE ),'%Hh %im') as Uptime from information_schema.GLOBAL_STATUS where VARIABLE_NAME='Uptime';";

EQ "hosts" "show variables where Variable_name like '%host%';"

#Motores de bases de datos disponibles#
EQ "Motores de bases de datos disponibles" "select engine, comment from information_schema.engines;"

#Privilegios de Usuario#
EQ "Privilegios de Usuarios" "select grantee, table_schema, privilege_type, is_grantable from information_schema.schema_privileges;"

#Bases de datos en el servidor#
EQ "Bases de datos en el servidor" "select schema_name, default_character_set_name,default_collation_name from information_schema.schemata;"

#memoria de base de datos#
EQ "Informacion de la base de datos" "select table_schema, round(sum(data_length)/1024/1024,2) as 'mb', round(sum(max_data_length)/1024/1024,2) as 'max_mb', round(sum(index_length)/1024/1024,2) as 'index_mb' from information_schema.tables group by table_schema;"

#Informacion de Usuarios#
EQ "Informacion de Usuarios" "select User, Host,Grant_priv, password_expired, ssl_type, max_questions, max_updates, max_connections,max_user_connections, Repl_slave_priv, Repl_client_priv from mysql.user;"

### warnings ###
EQ "WARNINGS" "SHOW WARNINGS;"

# connections ####
EQ "check connection" "show processlist;"

###read/write
EQ "read write" "SELECT SUM(IF(variable_name='Com_select', variable_value, 0)) AS 'Total reads', SUM(IF(variable_name IN ('Com_delete', 'Com_insert', 'Com_update', 'Com_replace'), variable_value, 0)) AS 'Total writes'  FROM information_schema.GLOBAL_STATUS;"

###inodb buffer
EQ "innodb buffer" "SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';"

#Informacion de Indices#
EQ "Informacion de Indices" "select index_name, index_type, index_schema, table_name, table_schema, column_name, seq_in_index, collation, cardinality, sub_part, packed from information_schema.statistics;"

}

DesAll(){
tput rc; tput el
printf "[+] exportando all tables espere...."

echo "" > $TMPF/dbt.log
echo "<h1 class='title'>ALL DATABASE</h1>" >> ./check.html

########## show databases; ###########

$CONN<< EOFDB > $TMPF/db.log
        SHOW DATABASES;
EOFDB

while read -r values
do

DBS=$(echo $values | awk '{print $1}')
tput rc; tput el
printf "[+] exportando DATABASE $DBS espere..."

if [ "$DBS" != "Database" ]; then

echo "<h1 class='title'>BBDD: $DBS</h1>" >> ./check.html

########## SHOW TABLES ###############

$CONN<< EOFDB > $TMPF/dbt.log
        use $DBS
        SHOW TABLES;
EOFDB

########## READ TABLES ###########
while read -r value
do

TDB=$(echo $value | awk '{print $1}')
TBI=$(echo $TDB | grep '^Tables_in_' ) > /dev/null

if [ "$TBI" == "" ]; then

echo "<div id='stable'><p>$TDB</p><table class='responsive-table colaps' id='S_"$TDB"' style='display: none;'>" >> ./check.html

########## DESCRIBE TABLES ###############
$CONN<< EOFDB > $TMPF/dbd.log
        use $DBS;
        describe $TDB;
EOFDB


FF=$(cat $TMPF/dbd.log);
NLC=0

if [  "$FF" != "" ]; then
########## DEFINE COLUMMS ###########

while read -r valuese
do
TD="td"

if [ $NLC -eq 0 ]; then
    NLS=$( echo $valuese | awk '{print NF}' | sort -n | uniq );
    TD="th"
  NLC=1
    fi

    echo "<tr>" >> ./check.html

    for i in `seq 1 $NLS`
    do
            DBD=$(echo $valuese | awk '{print $'$i'}')
            echo "<$TD>$DBD<$TD>" >> ./check.html
    done
    
    echo "</tr>" >> ./check.html
########## FINISH DEFINE COLUMMS ###########
  done < /tmp/dbd.log
 fi
echo "</table></div>"  >> ./check.html
fi
########## DESCRIBE TABLES ###########
done < $TMPF/dbt.log
fi
########## READ TABLES ###########
done < $TMPF/db.log
}

#####head html
Body

#### check local server disk 
OS "check disk" "df -h"

#### vheck local server memory
OS "server memory" "cat /proc/meminfo"

##### queryes check 
Querys

####describe all table
DesAll

#### footer html 
Footer

