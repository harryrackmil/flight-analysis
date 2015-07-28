#!/bin/bash


touch year.length

for YEAR in {1987..2008}
do
	if [ ! -f data/$YEAR.csv ]
	then
		wget http://stat-computing.org/dataexpo/2009/$YEAR.csv.bz2 -O data/$YEAR.csv.bz2
		bunzip2 data/$YEAR.csv.bz2
		rm data/$YEAR.csv.bz2
	fi
	echo $YEAR downloaded
done

wc -l data/* >> year.length

NUM08 = "$(hdfs dfs -tail flights/allYears.csv | grep '^2008' | wc -l)"

if [ $NUM08 == '0']
then
	hdfs dfs -rmr flights
	hdfs dfs -mkdir flights
	hdfs dfs -touchz flights/allYears.csv
	for YEAR in {1987..2008}
	do
		hdfs dfs -appendToFile data/$YEAR.csv flights/allYears.csv
	done
fi

echo "hdfs up to date"

hdfs dfs -rmr output/*
gradle clean jar
hadoop jar ./build/libs/flights.jar flights/allYears.csv output/year output/month output/weekday


