#!/bin/bash
#PBS -N QSUB_TEST2
#PBS -o qtest02.o
#PBS -e qtest02.e

#qsystem test
echo `date`
echo `pwd`
echo $PBS_O_WORKDIR

if [ ! -z ${PBS_O_WORKDIR} ]; then
  cd ${PBS_O_WORKDIR} # PBS_O_WORKDIR 変数が存在している場合、そのディレクトリへ移動
fi

echo `pwd`