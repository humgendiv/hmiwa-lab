#!/bin/bash
#PBS -j oe 
#PBS -o /home/hmiwa/hmiwa/hmiwa-labserver/99_log/qtest06.log
#PBS -e /home/hmiwa/hmiwa/hmiwa-labserver/99_log/qtest06.log
#PBS -N $JN

#qsystem test
echo `date`
echo `pwd`

echo $PBS_O_WORKDIR

if [ ! -z ${PBS_O_WORKDIR} ]; then
  cd ${PBS_O_WORKDIR} # PBS_O_WORKDIR 変数が存在している場合、そのディレクトリへ移動
fi
echo `pwd`

#qsub -v pwd=`pwd` qtest01.sh

#scp hmiwa-spc:~/hmiwa/downloads/XXXXX ~/hmiwa1/rawdata/XXXXX

XXX=""
scp hmiwa-spc:~/hmiwa/${XXX} ${XXX}