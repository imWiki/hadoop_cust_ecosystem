#!/bin/bash

echo "`date '+%Y-%m-%d %H:%M:%S'`: Initiating Data Processing Wrapper Shell"
scr_dir='/vagrant/scripts/'
data_dir='/vagrant/temp/'
zep_dir='/home/ubuntu/zeppelin-0.8.0-bin-netinst/bin/'
url='https://chronicdata.cdc.gov/views/735e-byxc/rows.csv'
cd $data_dir
[ "$?" -eq "0" ] && { wget $url; echo "`date '+%Y-%m-%d %H:%M:%S'`: Given CSV File Downloaded"; } || { echo "`date '+%Y-%m-%d %H:%M:%S'`: Couldn't find temp data directory, Aborting the script"; exit 1; }

[ -f $scr_dir/hive_ddl.hql ] && { beeline -u 'jdbc:hive2://vigneshm:10000/default;' -n vagrant - p vagrant --color=true  -f $scr_dir/hive_ddl.hql; echo "`date '+%Y-%m-%d %H:%M:%S'`: Input & Result Tables Created at Hive Default Database"; } || { echo "`date '+%Y-%m-%d %H:%M:%S'`: Hive DDL File Not Found"; exit 1; }

if [ -f $data_dir/rows.csv ]
then
	hdfs dfs -put rows.csv /user/hive/warehouse/assessment/
	[ "$?" -eq "0" ] && { rm -f $data_dir/rows.csv; } || { echo "File not moved into HDFS. Aborting the Script"; rm -f $data_dir/rows.csv; exit 1; }
	beeline -u 'jdbc:hive2://vigneshm:10000/default;' -n vagrant - p vagrant --color=true -e "msck repair table assessment;"
	echo -e "`date '+%Y-%m-%d %H:%M:%S'`: Table Assessment has been loaded with rows.csv file data\n"
	echo -e "/t/t/t`date '+%Y-%m-%d %H:%M:%S'`: Starting PySpark Program to load Output Table"
	spark-submit --num-executors 2 --executor-cores 2 --executor-memory 256m $scr_dir/asmt_results.py
	[ "$?" -eq "0" ] && { echo "`date '+%Y-%m-%d %H:%M:%S'`: Loaded Result Tables, You can query the tables ASSESSMENT & ASSESSMENT_RESULTS Now!!"; } || { echo "`date '+%Y-%m-%d %H:%M:%S'`: PySpark Failure, Please check the logs"; exit 1; }
	echo "`date '+%Y-%m-%d %H:%M:%S'`: Results from output table below"
	beeline -u 'jdbc:hive2://vigneshm:10000/default;' -n vagrant - p vagrant --color=true -e "select category,year,question,avg_data_val from assessment_results;"
	cd $zep_dir
	sudo ./zeppelin-daemon.sh restart
	[ "$?" -eq "0" ] && { echo "`date '+%Y-%m-%d %H:%M:%S'`: Started Zeppelin Server, Please visit http://vigneshm:8080/#/notebook/2E4H2MXP3 for dashboard outcome of Assessment"; } || { echo "`date '+%Y-%m-%d %H:%M:%S'`: Zeppelin Startup Failed, Will not be able to view Dashboard"; } 
else
	rm -f 
	echo "`date '+%Y-%m-%d %H:%M:%S'`: Issue in downloading rows.csv file";
	exit 1
fi
