#!/bin/bash
#PBS -N QSUB_TEST
#PBS -o ~/hmiwa/hmiwa_labserver/99_log/qtest01.log
#PBS -e ~/hmiwa/hmiwa_labserver/99_log/qtest01.log

#qsystem test
#qsub -v pwd=`pwd` qtest01.sh
OUTFILE=$pwd/output.txt
echo "This is a test trial." > $OUTFILE
echo `date` >> $OUTFILE
for i in {1..22}
do
echo "count $i" >> $OUTFILE
done