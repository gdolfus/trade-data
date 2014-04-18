# 	Gero Dolfus
# 	University of Helsinki, HECER
# 	Start: April 18, 2014.
#
#	Read export prices for Finland.
#	
#
#
# Data Source:
#
# http://tilastokeskus.fi/til/thi/index_en.html
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
# Enable reading Excel files.
library(gdata)

# Directories.
# Data.
dirname.data = "~/RRR_finn/data/feenstra/"
dirname.data.cpi = "~/RRR_finn/data/fred/"



# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read data.
#
# - - - - - - - - - - - - - - - - - - - - - - 



# The CPI comes from FRED.
# http://research.stlouisfed.org/fred2/graph/?s[1][id]=CPIAUCSL

cpi=read.xls(paste(dirname.data.cpi,"cpi_1947_2014_1975.xls",sep=''),"FRED Graph",header=T)
cpi=cpi[-c(1:8),]
cpi=data.frame(lapply(cpi,as.character),stringsAsFactors=F)
names(cpi)=c('date','cpi.us')
cpi$cpi.us=as.numeric(cpi$cpi.us)
cpi$date=gsub("-01-01","",cpi$date)
cpi$date=as.numeric(cpi$date)




# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Finland - USSR
#
# - - - - - - - - - - - - - - - - - - - - - - 

years = 75:95

tmp.old <- NULL

for (i in years) {

	# Read the data.
	tmp.dat <- read.dta(paste(dirname.data, "/wtf", i, "/wtf", 
		i, ".dta", sep = ""))
	tmp.dat <- tmp.dat[tmp.dat$exporter == "Finland" & tmp.dat$importer == 
		"Fm USSR", ]
	tmp.dat$importer = "USSR"
	
	# Remove columns that I don't need.
	tmp.dat <- tmp.dat[, -match(c("icode", "ecode", "unit", "dot", 
		"quantity"), names(tmp.dat))]





	if (length(tmp.dat$sitc4) - length(unique(tmp.dat$sitc4)) != 
		0) {
		print(paste("Same codes used more than once in", i, unique(tmp.dat$importer)))


	}
	
	
	
	# ---------------------------------
	# Deflate the data.
	# ---------------------------------	
	
	# Store the nominal values with a different name.
tmp.dat$nominal.value = tmp.dat$value

tmp.dat$value = tmp.dat$value*cpi$cpi.us[which(cpi$date==tmp.dat$year[1])]/100
	
	
	# ---------------------------------
	# Additions based on deflated data.
	# ---------------------------------	

	# Add total exports.
	tmp.total <- tmp.dat[1, ]
	tmp.total$sitc4 = "total"
	tmp.total$value = sum(as.numeric(tmp.dat$value))

	# Add share of good i in total exports to country X.
	tmp.dat$perc.of.tot <- 100 * as.numeric(tmp.dat$value)/tmp.total$value
	tmp.total$perc.of.tot = sum(tmp.dat$perc.of.tot)

	# Combine it with the data for earlier years.
	tmp.old = rbind(tmp.old, tmp.dat, tmp.total)
}




# Housekeeping.
write.table(tmp.old, paste(dirname.data, "fin-ex-su-panel-tmp.csv", 
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
	tmp.dat <- tmp.dat[, -match(c("icode", "ecode", "unit", "dot", 
		"quantity"), names(tmp.dat))]

	if (length(tmp.dat$sitc4) - length(unique(tmp.dat$sitc4)) != 
		0) {
		# Aggregate the data to unique SITC codes.		
		tmp.df <- aggregate(tmp.dat$value, by = list(tmp.dat$sitc4), 
			FUN = sum)
		tmp.dat <- tmp.dat[match(tmp.df$Group.1, tmp.dat$sitc4), 
			]
		tmp.dat$value <- tmp.df$x

	}


	
	# ---------------------------------
	# Deflate the data.
	# ---------------------------------	
	
	# Store the nominal values with a different name.
tmp.dat$nominal.value = tmp.dat$value

tmp.dat$value = tmp.dat$value*cpi$cpi.us[which(cpi$date==tmp.dat$year[1])]/100
	
	
	# ---------------------------------
	# Additions based on deflated data.
	# ---------------------------------	



	# Add total exports.
	tmp.total <- tmp.dat[1, ]
	tmp.total$sitc4 = "total"
	tmp.total$value = sum(as.numeric(tmp.dat$value))

	# Add share of good i in total exports to country X.
	tmp.dat$perc.of.tot <- 100 * as.numeric(tmp.dat$value)/tmp.total$value
	tmp.total$perc.of.tot = sum(tmp.dat$perc.of.tot)

	# Combine it with the data for earlier years.
	tmp.old = rbind(tmp.old, tmp.dat, tmp.total)

}


# Housekeeping.
write.table(tmp.old, paste(dirname.data, "fin-ex-world-panel.csv", 
	sep = ""), row.names = F, sep = ",")

rm(list = ls(pattern = "tmp"))


# - - - - - - - - - - - - - - - - - - - - - -  
#
#	 Share of exports to the USSR in total exports by goods.
#
# - - - - - - - - - - - - - - - - - - - - - - 


wrld <- read.table(paste(dirname.data, "fin-ex-world-panel.csv", 
	sep = ""), sep = ",", stringsAsFactors = F, header = T, colClasses = rep("character", 
	1, 7))
su <- read.table(paste(dirname.data, "fin-ex-su-panel-tmp.csv", sep = ""), 
	sep = ",", stringsAsFactors = F, header = T, colClasses = rep("character", 		1, 6))


tmp.old<-NULL
for(i in paste(19,years,sep='')){
	tmp.su<-su[su$year==i,]
	tmp.wrld<-wrld[wrld$year==i,]
	# Reduce data on exports to the world to the codes in USSR exports.
	tmp.wrld<-tmp.wrld[match(tmp.su$sitc4,tmp.wrld$sitc4),]
	# Compute the percentage of SU exports in total exports.
	tmp.su$value<-as.numeric(tmp.su$value)
	tmp.wrld$value<-as.numeric(tmp.wrld$value)
	tmp.su$perc.of.wrld<-100*tmp.su$value/tmp.wrld$value
	# Combine the data across years.
	tmp.old<-rbind(tmp.old,tmp.su)
}


# Housekeeping.
write.table(tmp.old, paste(dirname.data, "fin-ex-su-panel.csv", 
	sep = ""), row.names = F, sep = ",")

# rm(list = ls(pattern = "tmp"))
