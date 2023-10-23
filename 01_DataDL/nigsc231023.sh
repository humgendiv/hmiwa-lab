#!/bin/bash

cd ~/hmiwa1/rawdata/
#scp hmiwa-spc:~/hmiwa/downloads/XXXXX ~/hmiwa1/rawdata/XXXXX

XXXXX=""
scp hmiwa-spc:~/hmiwa/downloads/${XXXXX}.tar.gz ${XXXXX}.tar.gz
tar xvzf ${XXXXX}.tar.gz
