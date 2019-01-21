from pyspark.sql import *
from pyspark import SparkContext, SparkConf
import sys
import datetime
import os

rundate=str(datetime.date.today())
print(str(datetime.datetime.today())[:19] + " INFO  Initiating PySpark Program")

def queryexecutor(queryip,targetHiveTable):
	try:
		conf =  SparkConf().setAppName('assessment_job')\
		.set('spark.kryoserializer.buffer.max','1024')\
		.set('spark.kryoserializer.buffer','1024')\
		.set('spark.yarn.queue', 'default')\
		.set('spark.executor.heartbeatInterval','60s')
		
		spark=SparkSession.builder.appName('assessment_job')\
		.config("hive.exec.dynamic.partition", "true")\
		.config("hive.exec.dynamic.partition.mode","nonstrict").enableHiveSupport().getOrCreate()
		spark.sparkContext.setLogLevel('ERROR')

		print(str(datetime.datetime.today())[:19] + " INFO  Spark Session created")
		print(str(datetime.datetime.today())[:19] + " INFO  Target Table Name: " + targetHiveTable)
		AggregatedDF = spark.sql(queryip)
		print(str(datetime.datetime.today())[:19] + " INFO  Assessment ResultSet DataFrame Completed")
		print(str(datetime.datetime.today())[:19] + " INFO  Mapping data frame into temporary view")
		AggregatedDF.createOrReplaceTempView("txn_tmp_vw") 
		print(str(datetime.datetime.today())[:19] + " INFO  Inserting data into Target table")
		orcTabSql="INSERT OVERWRITE TABLE "+targetHiveTable+ " PARTITION (category)\
		 SELECT yearstart,question,avg_data_value,count_of_records,category\
		 FROM txn_tmp_vw\
		  order by category"
		spark.sql(orcTabSql)
		print(str(datetime.datetime.today())[:19] + " INFO  Assessment ResultSet Insert Completed Successfully! Ignore above key provider Error")
	
	finally:
		print (str(datetime.datetime.today())[:19] + " INFO  Exiting Program Now!")
		spark.stop()


if __name__ == '__main__':
	query="SELECT 'All Age Bands' as category,YearStart,Question,AVG(Data_Value) AS Avg_Data_Value, COUNT(*) AS COUNT_OF_RECORDS\
		FROM ASSESSMENT\
		WHERE StratificationCategoryId1='AGEMO'\
		GROUP BY YearStart,Question\
		UNION\
		SELECT 'Females Only' as category,YearStart,Question,AVG(Data_Value) AS Avg_Data_Value, COUNT(*) AS COUNT_OF_RECORDS\
		FROM ASSESSMENT\
		WHERE StratificationCategoryId1='GEN' AND StratificationID1='FEMALE'\
		GROUP BY YearStart,Question"
	queryexecutor(query,"ASSESSMENT_RESULTS")
