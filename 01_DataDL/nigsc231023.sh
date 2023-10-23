#!/bin/bash

cd ~/hmiwa1/rawdata/
#scp hmiwa-spc:~/hmiwa/downloads/XXXXX ~/hmiwa1/rawdata/XXXXX

XXXXX=""
scp hmiwa-spc:~/hmiwa/downloads/${XXXXX} ${XXXXX}
tar xvzf ${XXXXX}
