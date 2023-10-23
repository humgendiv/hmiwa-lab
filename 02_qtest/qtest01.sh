#!/bin/bash
#PBS -N QSUB_TEST
#PBS -o ~/hmiwa/99_log/qtest01.log
#PBS -e ~/hmiwa/99_log/qtest01.log

#qsystem test
cd `pwd`
echo "This is a test trial." > output.txt
echo `date` >> output.txt 
for i in {1..22}
do
echo "count $i" >> output.txt
done