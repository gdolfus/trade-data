# 	Gero Dolfus
# 	University of Helsinki, HECER
# 	Start: November 08, 2013.
#
#	Trade statistics from OECD.
#
#	Harmonized System 1988, 2-digits only.
#
#	Read the data.
#
#	Description of the categories.
#	http://unstats.un.org/unsd/tradekb/Knowledgebase/Harmonized-Commodity-Description-and-Coding-Systems-HS
#
#	Fetch the data from OECD.
#	http://dx.doi.org/10.1787/data-00060-en
#




# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Setup.
#
# - - - - - - - - - - - - - - - - - - - - - - 

# Clear workspace.
rm(list = ls())
# Load the package for creating LaTeX tables.
library(xtable)


# Set the name of the directory where the data is.
dirname.data <- "~/RRR_finn/data/oecd/"


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read the data into memory.
#
# - - - - - - - - - - - - - - - - - - - - - - 


# * * * * * * * * * * * * * * * * * * * * * * 
#
# 				FINLAND - USSR
#
# * * * * * * * * * * * * * * * * * * * * * * 



years <- 1988:1989

tmp.dat.old <- NULL

tmp.partner <- "Former USSR"

for (i in years) {

	# Read the file.
	tmp.dat <- read.csv(paste(dirname.data, "hs1988-", 
		as.character(i), ".csv", sep = ""))
	print(paste(dirname.data, "hs1988-", as.character(i), 
		".csv", sep = ""))
	# Clean up and select.
	tmp.dat$Measure <- NULL


	# Only look at Finland.
	tmp.dat <- tmp.dat[tmp.dat$Reporter.Country == "Finland", 
		]
	# Look at USSR.
	tmp.dat <- tmp.dat[tmp.dat$Partner.Country == tmp.partner, 
		]

	tmp.dat$Partner.Country <- as.character(tmp.dat$Partner.Country)
	tmp.dat$Partner.Country[tmp.dat$Partner.Country == 
		"Former USSR"] <- "USSR"

	# Sort the data according to commodities.
	tmp.dat <- tmp.dat[order(tmp.dat$Commodity), ]
	print(dim(tmp.dat))
	sav.dat <- rbind(tmp.dat.old, tmp.dat)
	print(dim(sav.dat))
	tmp.dat.old <- tmp.dat

}


rm(tmp.partner, i, tmp.dat, tmp.dat.old)



# Housekeeping.
write.csv(sav.dat, paste(dirname.data, "bbb-hs-panel-fin-su.csv", 
	sep = ""), row.names = FALSE)



# * * * * * * * * * * * * * * * * * * * * * * 
#
# 				FINLAND - ALL
#
# * * * * * * * * * * * * * * * * * * * * * * 

tmp.dat <- read.csv(paste(dirname.data, "hs1988-", as.character(1988), 
	".csv", sep = ""))

tmp.dat <- tmp.dat[tmp.dat$Reporter.Country == "Finland", 
	]

tmp.dat$Partner.Country <- as.character(tmp.dat$Partner.Country)
tmp.dat$Partner.Country[tmp.dat$Partner.Country == "Former USSR"] <- "USSR"


# Housekeeping.
write.csv(tmp.dat, paste(dirname.data, "bbb-hs-1988-fin-all.csv", 
	sep = ""), row.names = FALSE)



# Clean up.
# rm(list=ls())

