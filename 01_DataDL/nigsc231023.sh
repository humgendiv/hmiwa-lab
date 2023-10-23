#!/bin/bash
#PBS -N SCP
#PBS -o qtest03.o
#PBS -e qtest03.e

#qsub -v pwd=`pwd` qtest01.sh

cd ~/hmiwa1/rawdata/
#scp hmiwa-spc:~/hmiwa/downloads/XXXXX ~/hmiwa1/rawdata/XXXXX

XXX=""
scp hmiwa-spc:~/hmiwa/downloads/${XXX}.tar.gz ${XXX}.tar.gz
tar xvzf ${XXX}.tar.gz