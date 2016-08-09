
#! /usr/bin/env Rscript
#
### To run this code
### source ("C:/Users/Tom/Documents/R/process_a380.R")
###
### This script will scrape A380 flights data from A380 flights.net
### and output the number of scheduled daily flights from each airport.
### The code will also output the number of flights within a set 3hr time
### window. In reality the code provides the maximum number of flights on any
### given day of the week since not all airlines operate the same route 7 days 
### a week with the same aircraft. 
###
### This code is provided without warranty and the author accepts 
### no responsibility for its use.
###
### Notes --
### SET READ_SITE = 1 to use rvest to scrape the flight data
###
### Written by Tom Breider June 2016. 
###################################################

### First use the rvest package to get scrape the html code
READ_SITE=0
if(READ_SITE == 1 ) {
   #Step 1= install the rvest package
   install.packages("rvest", repos="http://cran.rstudio.com/", dependencies=TRUE)

   #step 2 = load the package 
   library("rvest")

   #read the website html
   htmlpage <- read_html("http://a380flights.net/")

   #use the selectorGadget bookmark in firefox to find the page text that you want
   #highlight the text you want = and paste the code in the bottom box (in this case "li")
   forecasthtml2 <- html_nodes(htmlpage, "li")

   #remove the html text
   forecast2 <- html_text(forecasthtml2)

} 

###########################################
### Now process the flight info into 
### a list of departure and arrival airports and times. 
###
### note --- some flights have 2 legs so initialize some extra flights.
### Multi-leg flights are dealt with below.

secndlegextras=50
leg2count=1
ydep=length(forecast2)+secndlegextras
yarr=length(forecast2)+secndlegextras
yarr_t=length(forecast2)+secndlegextras
ydep_t=length(forecast2)+secndlegextras
#Initialize the arrays with NaNs
yarr_t[0:length(ydep)]=NaN
ydep_t[0:length(ydep)]=NaN

## Loop over forecast2 and split the strings to pull
## out departure and arrival airports
## Note again that multi-leg flights are dealt with below
for (i in 1:length(forecast2)) {
	y <-strsplit (forecast2 ,"\\(" ) [[i]]
	yd <- strsplit(y,"\\)") [[2]]
	ydep[i] <- yd[1]
	ya <-strsplit (y,"\\)" ) [[3]]
	yarr[i] <- ya[1]
	
	## Now pull out the departure and arrival times
	p=as.numeric(gsub("[^0-9]","",y[3]))
	if((nchar(p) > 8)) {
	  #print(c(i,nchar(p),p))
	  ydep_t[i] <- substr(p,nchar(p)-7,nchar(p)-4)
	  yarr_t[i] <- substr(p,nchar(p)-3,nchar(p)) 
	}
  
  if(length(y) == 7) {
	  p=as.numeric(gsub("[^0-9]","",y[6]))
	  ydep_t[i] <- substr(p,nchar(p)-7,nchar(p)-4)
	  yarr_t[i] <- substr(p,nchar(p)-3,nchar(p))
	}
	  
	
### Now add 2nd legs of multi-leg flights 
### .... add the second legs at the end of the list. 
### initialize leg2count=0
	if((length(y) > 7) & (length(y) <= 11)) {
    
	  p=as.numeric(gsub("[^0-9]","",y[6]))
	  if((nchar(p) >= 8)) {
	  ydep_t[i] <- substr(p,nchar(p)-7,nchar(p)-4)
	  yarr_t[i] <- substr(p,nchar(p)-3,nchar(p)) 	
	  }
	  # For some arrays it is too long
	  if((nchar(p) < 8)) {
	    p=as.numeric(gsub("[^0-9]","",y[7]))
	    ydep_t[i] <- substr(p,nchar(p)-7,nchar(p)-4)
	    yarr_t[i] <- substr(p,nchar(p)-3,nchar(p)) 	
	  }
	  
 		yd <- strsplit(y,"\\)") [[3]]
 		ydep[length(forecast2)+leg2count] <- yd[1]
 		ya <-strsplit (y,"\\)" ) [[4]]
 		yarr[length(forecast2)+leg2count] <- ya[1]
 		
 		
    #Now add in the time of the 2nd leg flights
 		#The Y [element] does not always find the dep time so give it different elements
 		p=as.numeric(gsub("[^0-9]","",y[8]))
 		if((nchar(p) >= 8)) {
 		ydep_t[length(forecast2)+leg2count] <- substr(p,nchar(p)-7,nchar(p)-4)
 		yarr_t[length(forecast2)+leg2count] <- substr(p,nchar(p)-3,nchar(p)) 
 		}
 		if((nchar(p) < 8)) {
 		  p=as.numeric(gsub("[^0-9]","",y[10]))
 		  ydep_t[length(forecast2)+leg2count] <- substr(p,nchar(p)-7,nchar(p)-4)
 		  yarr_t[length(forecast2)+leg2count] <- substr(p,nchar(p)-3,nchar(p)) 
 		}
 		if((nchar(p) < 8)) {
 		  p=as.numeric(gsub("[^0-9]","",y[9]))
 		  ydep_t[length(forecast2)+leg2count] <- substr(p,nchar(p)-7,nchar(p)-4)
 		  yarr_t[length(forecast2)+leg2count] <- substr(p,nchar(p)-3,nchar(p)) 
 		}
 		
 		f=length(forecast2)+leg2count
 		#print(c(i,f,nchar(p),p,length(y),ydep_t[f]))
 		leg2count=leg2count+1
	}
}
#### Finished cleaning the data arrays 

#########################################
### MANUAL CORRECTIONS HERE
###  -- Error in website code that misses one flight
###^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   ### Error in Read = manually adjust for BKK to HKG (page text is missing "-")
   ydep[length(ydep)-1]="BKK"
   yarr[length(ydep)-1]="HKG"
   ydep_t[length(ydep)-1]="1345"
   yarr_t[length(ydep)-1]="1740"

   ### Error in Read = manually adjust for MXP to NYC (page text is missing "-")
   ydep[length(ydep)]="MXP"
   yarr[length(ydep)]="NYC"
   ydep_t[length(ydep)]="1610"
   yarr_t[length(ydep)]="1900"

### END OF MANUAL CORRECTIONS
#######################################


## Convert times info to numeric
dept <- as.numeric(ydep_t)
arrt <- as.numeric(yarr_t)


###################################################
## Now sort and count the daily airport departures

## Sort the elements by the departures array
od=order(ydep)
dep_s <- (c(ydep[od]))
arr_s <- (c(yarr[od]))
dept_s <- (dept[od])
arrt_s <- (arrt[od])

## Now find the unique airports
print("find unique airports")
airports=unique(dep_s)
airports_count=length(airports)

## Count the number of departures from each airport
for (i in 1:length(airports)) {
airports_count[i] <-length(which(dep_s == airports[i]))
}

#sort the airports in descending order
od=order(-airports_count)
airports_s<- (c(airports[od]))
airports_count_s<- (c(airports_count[od]))

print(c("----------------------------------------------") )
print(c("The Number of departures from each airport is"))
print(c("-----------------------------------------------") )
for (i in 1:length(airports)) {
print(c(airports_s[i],airports_count_s[i]))
}

print(c(""))
print(c("-----------------------------------------------") )
print(c("Departure and Arrival Timings"))
print(c("-----------------------------------------------") )
#Declare an array to hold departues every 3 hours
airports_dept_count<-matrix(0,ncol=8,nrow=length(airports_s))
airports_arrt_count<-matrix(0,ncol=8,nrow=length(airports_s))


# Set 3hr time intervals 
times<-c(0,300,600,900,1200,1500,1800,2100,2400)
times_s<-c("0-3AM",'3-6AM','6-9AM','9-12AM','12-3PM','3-6PM','6-9PM','9-12PM')

# Count the number of times the airport appears in a given time window
for (a in 1:length(airports)) {
 for (i in 1:length(dep_s)) {
  for (t in 1:8) {
      #Now count depature times
      if(dep_s[i] == airports[a] & dept_s[i] >= times[t] & dept_s[i] < times[t+1]) {
        #print(c(airports[a],dep_s[i],dept_s[i]))
        airports_dept_count[a,t] <- airports_dept_count[a,t]+1
      }  
      # Now repeat for arrivals info
    if(arr_s[i] == airports[a] & arrt_s[i] >= times[t] & arrt_s[i] < times[t+1]) {
      airports_arrt_count[a,t] <- airports_arrt_count[a,t]+1
    }
  } # time
 } # dep_s
} # airports


print(c(""))
print(c("-----------------------------------------------") )
print(c("The timing of departures in 3-hr slots"))
print(c("-----------------------------------------------") )
print(c(times_s))
for (i in 1:length(airports)) {
  print(c(airports[i],airports_dept_count[i,]))
}

print(c(""))
print(c("-----------------------------------------------") )
print(c("The timing of arrivals in 3-hr slots"))
print(c("-----------------------------------------------") )
for (i in 1:length(airports)) {
  print(c(airports[i],airports_arrt_count[i,]))
}


## Now find the airports with the most dep / arr in a 3 hr time slots
#Declare an array to hold departues every 3 hours
#find how manny time slots have >= 5 flights per time interval
dep_at_ct<-matrix(0,2,nrow=length(airports_dept_count[airports_dept_count >=5]))
arr_at_ct<-matrix(0,2,nrow=length(airports_arrt_count[airports_arrt_count >=5]))

#initialize 
ctd=1
cta=1
mylist=length(0)
for (a in 1:length(airports)) {
  for (t in 1:8) {
    if(airports_dept_count[a,t] >=5) {
      dep_at_ct[ctd,1] <-paste(airports[a],times_s[t])
      dep_at_ct[ctd,2] <- airports_dept_count[a,t]
      ctd=ctd+1 
    }
    if(airports_arrt_count[a,t] >=5) {
      arr_at_ct[cta,1] <-paste(airports[a],times_s[t])
      arr_at_ct[cta,2] <- airports_arrt_count[a,t]
      cta=cta+1 
    }
  }
}

stop
#Now sort the results - Departures - DESC
d<-as.numeric(dep_at_ct[,2])
od2=order(-d)
dep2<-d[od2]
dept2<-dep_at_ct[od2,1]
#Repeat for Arrivals - DESC
a<-as.numeric(arr_at_ct[,2])
od3=order(-a)
arr2<-a[od3]
arrt2<-arr_at_ct[od3,1]

print(c("Departures in time windows"))
print(paste(dept2,dep2))
print(c(""))
print(c("Arrivals in time windows"))
print(paste(arrt2,arr2))
print(c(""))

###write the output to a file as a dataframe
OUTPUT_DATA_TO_FILE = 0
if(OUTPUT_DATA_TO_FILE == 1) {
  mydata <- data.frame(ydep,yarr,dept,arrt)
  names(mydata) <- c("Dep_Airport","Arr_Airport","Dep_time","Arr_Time") # variable names
  print("Write the output to a file")  
  output <- file("a380_flights.txt", "w")
  write(mydata, file = output)
  close(output)
  stop
}



