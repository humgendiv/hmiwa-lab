#!/bin/bash
#PBS -j oe 
#PBS -o qtest04.log
#PBS -e qtest04.log

#qsystem test
echo `date`
echo `pwd`

echo $PBS_O_WORKDIR

if [ ! -z ${PBS_O_WORKDIR} ]; then
  cd ${PBS_O_WORKDIR} # PBS_O_WORKDIR 変数が存在している場合、そのディレクトリへ移動
fi
echo `pwd`

cd ~/hmiwa1/rawdata
echo `pwd`

echo $PBS_JOBNAME