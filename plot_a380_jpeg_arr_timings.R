#! /usr/bin/env Rscript

### Make a bar plot with slanted axis
## source ("C:/Users/Tom/Documents/R/plot_a380_jpeg_arr_timings.R")

maxapts=length(arrt2)
end_point=0.5+maxapts+maxapts-1

tlab=arrt2[maxapts:0]
xdat=arr2[maxapts:0]

setcolor="blue"
plot_title="Daily A380 Arrivals Within Time Intervals"
yaxmax=20
yaxmin=0
ylabel="Arrivals Inside Time Interval"

# Fitting Labels
par(las=2) # make label text perpendicular to axis
par(mar=c(5,8,4,2)) # increase y-axis margin.

barplot(xdat, col=setcolor,main=plot_title, space=0.3, 
        xlim=c(yaxmin,yaxmax), horiz=TRUE, xlab=ylabel,
        names.arg=c(tlab), cex.names=0.8, axis.lty=0)