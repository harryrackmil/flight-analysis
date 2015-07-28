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
		if [ $YEAR != '1987' ]
		then
			grep ^[12] data/$YEAR.csv > tmp.csv
			mv tmp.csv data/$YEAR.csv
		fi
		hdfs dfs -appendToFile data/$YEAR.csv flights/allYears.csv
	done
fi

echo "hdfs up to date"

if [ ! -f out/weekday.csv ]
then
	hdfs dfs -rmr output/*
	gradle clean jar
	hadoop jar ./build/libs/flights.jar flights/allYears.csv output/year output/month output/weekday


	mkdir out
	hdfs dfs -copyToLocal output/year/part-00000 out/year.csv
	hdfs dfs -copyToLocal output/month/part-00000 out/month.csv
	hdfs dfs -copyToLocal output/weekday/part-00000 out/weekday.csv

fi


/usr/bin/Rscript flightPlots.R








