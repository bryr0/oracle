#Mysql to html 

create .my.cnf<br/>
[client]<br/>
user=mysqluser<br/>
password=mysqlpass<br/>
host=localhost<br/>

Usage
=====
very easy usage. xD

  * Body // define to html head
  * EQ arg1 = title, arg2=query  arg3 = database
  
    *example: EQ "bbdd avaliable" "select engine, comment from engines;" "information_schema";
  * DesAll // select and describe all databases
  * Footer // html footer
  * OS // check memory and disk ("linux")

## HTML

<img src="https://github.com/bryr0/oracle/blob/master/Mysql/img/img1.PNG?raw=true">
<img src="https://github.com/bryr0/oracle/blob/master/Mysql/img/img2.PNG?raw=true">
<img src="https://github.com/bryr0/oracle/blob/master/Mysql/img/img3.PNG?raw=true">

Note
============
in case of error first connect and execute

set @@global.show_compatibility_56=on;
  
