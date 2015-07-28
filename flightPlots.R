library(ggplot2)


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

savePlot = function(p, name) {
        pdf(paste(name,"pdf", sep = "."))
        print(p)
        dev.off()
}


weekday = read.csv("out/weekday.csv", header = TRUE)
avgByCity = aggregate(weekday$count, by = list(weekday$Dest), FUN = mean)

weekdayNorm = normalizeByDest(weekday, avgByCity)
weekdayTopn = filteredTopn(weekdayNorm, 10, 50000, 7)
p = ggplot(weekdayTopn) + geom_path(aes(DayOfWeek,count, group=Dest)) +
	aes(colour=factor(Dest)) + ggtitle("Total Flights by Day of Week, 1987-2008")
savePlot(p, "plots/weekday")

month = read.csv("out/month.csv", header = TRUE)
monthNorm = normalizeByDest(month, avgByCity)
monthTopn = filteredTopn(monthNorm, 10, 50000, 12)
monthTopn = monthTopn[order(monthTopn$Month),]
p = ggplot(monthTopn) + geom_path(aes(Month,count, group=Dest)) +
	aes(colour=factor(Dest)) + ggtitle("Total Flights by Month, 1987-2008")
savePlot(p, "plots/month")


year = read.csv("out/year.csv", header = TRUE)
yearNorm = normalizeByDest(year, avgByCity)
yearTopn = filteredTopn(yearNorm, 10, 50000, 20)
p = ggplot(yearTopn) + geom_path(aes(Year,count, group=Dest)) +
	aes(colour=factor(Dest)) + ggtitle("Total Flights by Year, 1987-2008")
savePlot(p, "plots/year")



