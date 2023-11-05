#!/bin/bash
#PBS -N SCP
#PBS -o /home/hmiwa/hmiwa/hmiwa-labserver/99_log/SCP.o
#PBS -e /home/hmiwa/hmiwa/hmiwa-labserver/99_log/SCP.e

cd ~/hmiwa1/rawdata/
#scp hmiwa-spc:~/hmiwa/downloads/XXXXX ~/hmiwa1/rawdata/XXXXX

#以下をちまちま実行していく。
XXX=""
date;scp hmiwa-spc:~/hmiwa/downloads/${XXX}.tar.gz ${XXX}.tar.gz;tar xvzf ${XXX}.tar.gz;echo "$XXX done `date`"