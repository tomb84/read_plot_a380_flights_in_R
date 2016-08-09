
#! /usr/bin/env Rscript
##
## Make a bar plot with slanted axis
## source ("C:/Users/Tom/Documents/R/plot_a380_jpeg_gt4airports.R")
##
##
####################################################

maxapts=20
end_point=0.5+maxapts+maxapts-1

tlab=airports_s[0:maxapts]
xdat=airports_count_s[0:maxapts]

setcolor="blue"
plot_title="Daily A380 Departures (airports with > 4 flights per day)"
yaxmax=80
yaxmin=0
ylabel="Daily Departures"

barplot(xdat,col=setcolor,main=plot_title,ylim=c(yaxmin,yaxmax),
las=2,xant="n",space=1.0,ylab=ylabel,lty=1,
cex.lab=1.5,cex.axis=1.5,cex.main=1.5)
text(seq(1.5,end_point,by=2), par("usr")[3]-0.7,srt = 60, adj= 1.4, xpd = TRUE,labels = paste(tlab), cex=1.2)

### Code to plot the slated xaxis labels comes from the link below
# http://stackoverflow.com/questions/10286473/rotating-x-axis-labels-in-r-for-barplot 