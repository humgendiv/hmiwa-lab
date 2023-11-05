#!/bin/bash
#PBS -N QSUB_TEST3
#PBS -o qtest03.o
#PBS -e qtest03.e

if [ ! -z ${PBS_O_WORKDIR} ]; then
  cd ${PBS_O_WORKDIR} # PBS_O_WORKDIR 変数が存在している場合、そのディレクトリへ移動
fi

#qsystem test
OUTFILE=output3.txt
echo "This is a test trial." > $OUTFILE
echo `date` >> $OUTFILE
for i in {1..22}
do
echo "count $i" >> $OUTFILE
done
cat $OUTFILE
echo `date`