library(ggplot2)
avgByCity = aggregate(Year$count, by = list(weekday$Dest), FUN = mean)


normalizeByDest = function(df, byCity) {
	normed =  100 * apply( df, 1, function(row){return(as.numeric(row[3])/byCity$x[byCity$Group.1 == row[1]])})
	newdf = data.frame(cbind(df, normed))
	names(newdf) = c(names(df), "normCount")
	return(newdf)
}


filteredTopn = function(df, n, totBound, countBound, dec = TRUE) {
	highCities = avgByCity$Group.1[avgByCity$x > totBound]
	newdf = df[df$Dest %in% highCities,]
	normSD = aggregate(newdf$normCount, by = list(newdf$Dest), FUN = function(x){if (length(x) < countBound){return(NA)} else {return(sd(x))}})
	volatileDest = head(normSD[order(normSD$x, decreasing = dec),], n)$Group.1
	topn = newdf[newdf$Dest %in% volatileDest,]
	return(topn)
}

ggSeries = function(topn) {
	return(ggplot(topn) + geom_path(aes(DayOfWeek,normCount, group=Dest)) + aes(colour=factor(Dest)))

}


weekday = read.csv("out/weekday.csv", header = TRUE)
weekdayNorm = normalizeByDest(weekday, avgByCity)
weekdayTopn = filteredTopn(weekdayNorm, 10, 50000, 7)
ggplot(weekdayTopn) + geom_path(aes(DayOfWeek,count, group=Dest)) + aes(colour=factor(Dest))


month = read.csv("out/month.csv", header = TRUE)
monthNorm = normalizeByDest(month, avgByCity)
monthTopn = filteredTopn(monthNorm, 10, 50000, 12)
monthTopn = monthTopn[order(monthTopn$Month),]
ggplot(monthTopn) + geom_path(aes(Month,count, group=Dest)) + aes(colour=factor(Dest))


year = read.csv("out/year.csv", header = TRUE)
yearNorm = normalizeByDest(year, avgByCity)
yearTopn = filteredTopn(yearNorm, 10, 50000, 20)
ggplot(yearTopn) + geom_path(aes(Year,count, group=Dest)) + aes(colour=factor(Dest))



