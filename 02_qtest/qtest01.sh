#!/bin/bash
#qsystem test
echo "This is a test trial." > output.txt
echo `date` >> output.txt 
for i in {1..22}
do
echo "count $i" >> output.txt
done