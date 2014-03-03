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
	if (length(tmp.dat$sitc4) - length(unique(tmp.dat$sitc4)) != 
		0) {
		print(paste("Same codes used more than one in", i, unique(tmp.dat$importer)))
	}

	# Combine it with the data for earlier years.
	tmp.old = rbind(tmp.old, tmp.dat)
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

	if (length(tmp.dat$sitc4) - length(unique(tmp.dat$sitc4)) != 
		0) {
		print(paste("Same codes used more than one in", i, unique(tmp.dat$importer)))
	}

	# Combine it with the data for earlier years.
	tmp.old = rbind(tmp.old, tmp.dat)
}


# Housekeeping.
write.table(tmp.old, paste(dirname.data, "fin-ex-world-panel.csv", 
	sep = ""), row.names = F, sep = ",")

rm(list = ls(pattern = "tmp"))
