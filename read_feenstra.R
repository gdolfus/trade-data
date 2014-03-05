# 	Gero Dolfus
# 	University of Helsinki, HECER
# 	Start: February 24, 2014.
#
#	Read Feenstra et al. data and 
#	create a panel for Finnish exports to the USSR.
#	
#
#
# Data Source:
#
# http://cid.econ.ucdavis.edu/nberus.html
#
#
#
#



# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Setup.
#
# - - - - - - - - - - - - - - - - - - - - - - 

# Clear workspace.
rm(list = ls())

# Packages.
# Enable reading Stata data.
library(foreign)

# Directories.
# Data.
dirname.data <- "~/RRR_finn/data/feenstra/"


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Finland - USSR
#
# - - - - - - - - - - - - - - - - - - - - - - 

years = 75:91

tmp.old <- NULL

for (i in years) {

	# Read the data.
	tmp.dat <- read.dta(paste(dirname.data, "/wtf", i, "/wtf", 
		i, ".dta", sep = ""))
	tmp.dat <- tmp.dat[tmp.dat$exporter == "Finland" & tmp.dat$importer == 
		"Fm USSR", ]
		
				# Remove columns that I don't need.
tmp.dat<-tmp.dat[,-match(c('icode','ecode','unit','dot','quantity'),names(tmp.dat))]

		


		
	if (length(tmp.dat$sitc4) - length(unique(tmp.dat$sitc4)) != 
		0) {
		print(paste("Same codes used more than once in", i, unique(tmp.dat$importer)))
		
		
	}
	
	# Add total exports.
		tmp.total <- tmp.dat[1, ]
		tmp.total$sitc4 = "total"
		tmp.total$value = sum(as.numeric(tmp.dat$value))

	# Combine it with the data for earlier years.
	tmp.old = rbind(tmp.old, tmp.dat,tmp.total)
}


# Housekeeping.
write.table(tmp.old, paste(dirname.data, "fin-ex-su-panel.csv", 
	sep = ""), row.names = F, sep = ",")

# "Fm USSR" is not in the data past 1991.
tmp.dat <- read.dta(paste(dirname.data, "/wtf", 92, "/wtf", 92, 
	".dta", sep = ""))
tmp.dat[tmp.dat$exporter == "Finland" & tmp.dat$importer == "Fm USSR", 
	]
# If I want to use that, I will have to aggregate it somehow.

rm(list = ls(pattern = "tmp"))


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Finland - World
#
# - - - - - - - - - - - - - - - - - - - - - - 

years = 75:95

tmp.old <- NULL

for (i in years) {

	# Read the data.
	tmp.dat <- read.dta(paste(dirname.data, "/wtf", i, "/wtf", 
		i, ".dta", sep = ""))
	tmp.dat <- tmp.dat[tmp.dat$exporter == "Finland" & tmp.dat$importer == 
		"World", ]
		# Remove columns that I don't need.
tmp.dat<-tmp.dat[,-match(c('icode','ecode','unit','dot','quantity'),names(tmp.dat))]

	if (length(tmp.dat$sitc4) - length(unique(tmp.dat$sitc4)) != 
		0) {
		# Aggregate the data to unique SITC codes.		
		 tmp.df<-aggregate(tmp.dat$value,by=list(tmp.dat$sitc4),FUN=sum)
		tmp.dat<-tmp.dat[match(tmp.df$Group.1,tmp.dat$sitc4),]
		tmp.dat$value<-tmp.df$x
		 
	}

	# Add total exports.
		tmp.total <- tmp.dat[1, ]
		tmp.total$sitc4 = "total"
		tmp.total$value = sum(as.numeric(tmp.dat$value))

	# Combine it with the data for earlier years.
	tmp.old = rbind(tmp.old, tmp.dat,tmp.total)
}


# Housekeeping.
write.table(tmp.old, paste(dirname.data, "fin-ex-world-panel.csv", 
	sep = ""), row.names = F, sep = ",")

rm(list = ls(pattern = "tmp"))



# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Finland - World, USSR
#
# - - - - - - - - - - - - - - - - - - - - - - 


# Create a panel?
# But the codes don't line up, so I'd have to fill in the missing matches. 
#
# wrld<-read.table(paste(dirname.data, "fin-ex-world-panel.csv", sep = ""),sep = ",",stringsAsFactors=F,header=T,colClasses = rep("character",1, 9))
# su<-read.table(paste(dirname.data, "fin-ex-su-panel.csv", sep = ""),sep = ",",stringsAsFactors=F,header=T,colClasses = rep("character",1, 9))

# # Remove variables that I don't need.
# su$unit<-NULL
# su$ecode<-NULL
# su$icode<-NULL
# su$quantity<-NULL
# su$dot<-NULL
# wrld$unit<-NULL
# wrld$ecode<-NULL
# wrld$icode<-NULL
# wrld$quantity<-NULL
# wrld$dot<-NULL

# # Only look at the years for which I have data for the USSR.
# years = 1975:1991
# wrld<-wrld[which(wrld$year%in%years),]

# tmp<-merge(x=wrld,y=su,by.x=c("year","sitc4"),by.y=c("year","sitc4"))

# # Housekeeping.
# write.table(tmp.old, paste(dirname.data, "fin-ex-wrld-su-panel.csv", 
	# sep = ""), row.names = F, sep = ",")








# rm(list = ls(pattern = "tmp"))

