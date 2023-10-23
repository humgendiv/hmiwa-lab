#!/bin/bash
#PBS -j oe 
#PBS -o /home/hmiwa/hmiwa/hmiwa-labserver/99_log/qtest06.log
#PBS -e /home/hmiwa/hmiwa/hmiwa-labserver/99_log/qtest06.log

sshpass=~/homebrew/bin/sshpass

if [ ! -z ${PBS_O_WORKDIR} ]; then
  cd ${PBS_O_WORKDIR} # PBS_O_WORKDIR 変数が存在している場合、そのディレクトリへ移動
fi

$sshpass -p $PASS scp hmiwa-spc:~/hmiwa/${FILENAME} ${FILENAME}
#scp hmiwa-spc:~/hmiwa/downloads/XXXXX ~/hmiwa1/rawdata/XXXXX

#FILENAME=tmp.sh
#qsub -N SCP_$FILENAME -v FILENAME=$FILENAME -v PASS=... qtest01.sh