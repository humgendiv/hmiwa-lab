#!/hmiwa/
#$ -cwd
#$ -l medium
#$ -l d_rt=384:00:00
#$ -l s_rt=384:00:00
#$ -l s_vmem=512G
#$ -l mem_req=512G
#$ -S /bin/bash
#$ -o ~/hmiwa/log/tmp.o
#$ -e ~/hmiwa/log/tmp.e
#$ -N tmp
date;tar cvzf output-cramchallege-err.tar.gz output/cramchallege/ERR/ 2>&1 >> README_output-cramchallege-err;date
