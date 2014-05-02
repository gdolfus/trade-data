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
# Enable reading Excel files.
library(gdata)

# Directories.
# Data.
dirname.data = "~/RRR_finn/data/feenstra/"


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read data.
#
# - - - - - - - - - - - - - - - - - - - - - - 





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
		tmp.old = rbind(tmp.old, tmp.dat)
	
}

print(paste('Year=',i,'that is, the USSR no longer exists.'))


# Housekeeping.
write.table(tmp.old, paste(dirname.data, "fin-ex-su-panel-raw.csv", 
	sep = ""), row.names = F, sep = ",")


# "Fm USSR" is not in the data past 1991.
tmp.dat <- read.dta(paste(dirname.data, "/wtf", 92, "/wtf", 92, 
	".dta", sep = ""))
tmp.dat[tmp.dat$exporter == "Finland" & tmp.dat$importer == "Fm USSR", 
	]
# If I want to use that, I will have to aggregate it somehow.

rm(list = ls(pattern = "tmp"),i)






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


		# Combine it with the data for earlier years.
	tmp.old = rbind(tmp.old, tmp.dat)

}


# Housekeeping.
write.table(tmp.old, paste(dirname.data, "fin-ex-world-panel-raw.csv", 
	sep = ""), row.names = F, sep = ",")

rm(list = ls(pattern = "tmp"))










