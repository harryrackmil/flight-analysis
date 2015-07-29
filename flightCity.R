

library(ggplot2)

normalizeByDest = function(df, byCity) {
	normed =  100 * apply( df, 1, function(row){return(as.numeric(row[3])/byCity$x[byCity$Group.1 == row[1]])})
	newdf = data.frame(cbind(df, normed))
	names(newdf) = c(names(df), "normCount")
	return(newdf)
}

joinWithCodes = function(df) {
	return(merge(x = df, y = airCodes, by = "Dest", all.x = FALSE))
}

filteredTopn = function(df, n, totBound, countBound, func = sd, dec = TRUE) {
	highCities = monthAvg$Group.1[monthAvg$x > totBound]
	newdf = df[df$city %in% highCities,]
	normSD = aggregate(newdf$normCount, by = list(newdf$city), FUN = function(x){if (length(x) < countBound){return(NA)} else {return(func(x))}})
	volatileCities = head(normSD[order(normSD$x, decreasing = dec),], n)$Group.1
	topn = newdf[newdf$city %in% volatileCities,]
	return(topn)
}

savePlot = function(p, name) {
    pdf(paste(name,"pdf", sep = "."))
    print(p)
}


n = 10
lowerCnt = 60000
funcToMaximize = sd

airCodes = read.csv("data/codes.clean", header = FALSE)
names(airCodes) = c("name", "city", "country", "Dest")



month = read.csv("out/month.csv", header = TRUE)
month = joinWithCodes(month)
month = aggregate(month$count, by = list(month$city, month$Month), FUN = sum)
names(month) = c("city", "Month", "count")
monthAvg = aggregate(month$count, by = list(month$city), mean)
monthNorm = normalizeByDest(month, monthAvg)
monthTopn = filteredTopn(monthNorm, n, lowerCnt, 12, func = funcToMaximize)
monthTopn = monthTopn[order(monthTopn$Month),]
p = ggplot(monthTopn) + geom_path(aes(Month,normCount, group=city)) +
	aes(colour=factor(city), linetype=factor(city)) + ggtitle("Total Flights by Month, 1987-2008")
savePlot(p, "plots/month")


weekday = read.csv("out/weekday.csv", header = TRUE)
weekday = joinWithCodes(weekday)
weekday = aggregate(weekday$count, by = list(weekday$city, weekday$DayOfWeek), FUN = sum)
names(weekday) = c("city", "DayOfWeek", "count")
weekdayAvg = aggregate(weekday$count, by = list(weekday$city), mean)
weekdayNorm = normalizeByDest(weekday, weekdayAvg)
weekdayTopn = filteredTopn(weekdayNorm, n, lowerCnt, 7, func = funcToMaximize)
weekdayTopn = weekdayTopn[order(weekdayTopn$DayOfWeek),]
p = ggplot(weekdayTopn) + geom_path(aes(DayOfWeek,normCount, group=city)) +
	aes(colour=factor(city), linetype=factor(city)) + ggtitle("Total Flights by Day of Week, 1987-2008")
savePlot(p, "plots/weekday")


year = read.csv("out/year.csv", header = TRUE)
year = joinWithCodes(year)
year = aggregate(year$count, by = list(year$city, year$Year), FUN = sum)
names(year) = c("city", "Year", "count")
yearAvg = aggregate(year$count, by = list(year$city), mean)
yearNorm = normalizeByDest(year, yearAvg)
yearTopn = filteredTopn(yearNorm, n, lowerCnt, 20, func = funcToMaximize)
yearTopn = yearTopn[order(yearTopn$Year),]
p = ggplot(yearTopn) + geom_path(aes(Year,normCount, group=city)) +
	aes(colour=factor(city), linetype=factor(city)) + ggtitle("Total Flights by Year, 1987-2008")
savePlot(p, "plots/year")




