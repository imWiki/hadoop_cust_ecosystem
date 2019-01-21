DROP TABLE assessment;
DROP TABLE assessment_results;

CREATE EXTERNAL TABLE assessment
( 
YearStart string
,YearEnd string
,LocationAbbr string
,LocationDesc string
,Datasource string
,Class string
,Topic string
,Question string
,Data_Value_Unit string
,Data_Value_Type string
,Data_Value string
,Data_Value_Alt string
,Data_Value_Footnote_Symbol string
,Data_Value_Footnote string
,Low_Confidence_Limit string
,High_Confidence_Limit  string
,Sample_Size string
,Total string
,Age_In_Months string
,Gender string
,Race_Ethnicity string
,GeoLocation string
,ClassID string
,TopicID string
,QuestionID string
,DataValueTypeID string
,LocationID string
,StratificationCategory1 string
,Stratification1 string
,StratificationCategoryId1 string
,StratificationID1 string
)
ROW FORMAT SERDE
  'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'quoteChar'='\"',
  'separatorChar'=',')
STORED AS INPUTFORMAT
  'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  'hdfs://vigneshm/user/hive/warehouse/assessment'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE TABLE assessment_results
(
year int,
question string,
avg_data_val decimal(8,4),
record_count int
)
PARTITIONED BY 
(
category string
)
ROW FORMAT SERDE
'org.apache.hadoop.hive.ql.io.orc.OrcSerde'
WITH SERDEPROPERTIES (
'colelction.delim'=',',
'field.delim'='|',
'line.delim'='\n',
'mapkey.delim'='-',
'serialization.format'='|')
STORED AS INPUTFORMAT
'org.apache.hadoop.hive.ql.io.orc.OrcInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.orc.OrcOutputFormat'
LOCATION
'hdfs://vigneshm/user/hive/warehouse/assessment_results'
TBLPROPERTIES ('orc.compress'='ZLIB');
