#Mysql to html 

create .my.cnf
[client]
user=mysqluser
password=mysqlpass
host=localhost

Usage
=====
very easy usage. xD

  * Body // define to html head
  * EQ arg1 = title, arg2=query  arg3 = database
  
    *example: EQ "bbdd avaliable" "select engine, comment from engines;" "information_schema";
  * DesAll // select and describe all databases
  * Footer // html footer
  * OS // check memory and disk ("linux")


Note
============
in case of error first connect and execute

set @@global.show_compatibility_56=on;
  
