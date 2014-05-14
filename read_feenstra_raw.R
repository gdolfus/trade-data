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

# countries = c("Fm USSR", "World")
# label = countries
# tmp.short = c("su", "wrld")

countries = c("Fm USSR", "World", "UK", "Germany", "USA", 
	"Sweden", "Norway", "France,Monac", "Denmark")


label = countries
tmp.short = c("su", "wrld", "uk","ger", "us", "swe", 
	"nor", "fra", "den")
label = data.frame(label, tmp.short)
names(label)[1] = "orig"
names(label)[2] = "short"

rm(list = ls(pattern = "tmp"))

# "Fm USSR" is not in the data past 1991.
years = 75:91

# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Finland - XXX
#
# - - - - - - - - - - - - - - - - - - - - - - 




for (i in years) {


	# Read the data.
	tmp.df <- read.dta(paste(dirname.data, "/wtf", i, 
		"/wtf", i, ".dta", sep = ""))

	for (k in countries) {


		tmp.label = as.character(label$short[which(label$orig == 
			k)])
			
			
		if(k=="Germany"&i<91){k="Fm German FR"}


		tmp.dat <- tmp.df[which(tmp.df$exporter == "Finland" & 
			tmp.df$importer == k), ]
		# Rename USSR for consistency with other scripts.
		if (k == "Fm USSR") {
			tmp.dat$importer = "USSR"
		}

		# Remove columns that I don't need.
		tmp.dat <- tmp.dat[, -which(names(tmp.dat) %in% 
			c("icode", "ecode", "unit", "dot", "quantity"))]

		# 		tmp.dat <- tmp.dat[, -match(c("icode", "ecode", 
		# "dot"), names(tmp.dat))]




		if (length(tmp.dat$sitc4) - length(unique(tmp.dat$sitc4)) != 
			0) {
			print(paste("Same codes used more than once in", 
				i, unique(tmp.dat$importer)))


		}

		assign(paste(tmp.label, i, sep = ""), tmp.dat)
	}




}


# "Fm USSR" is not in the data past 1991.
# tmp.dat <- read.dta(paste(dirname.data, "/wtf", 92, "/wtf", 92, 
# ".dta", sep = ""))
# tmp.dat[tmp.dat$exporter == "Finland" & tmp.dat$importer == "Fm USSR", 
# ]
# If I want to use that, I will have to aggregate it somehow.

rm(list = ls(pattern = "tmp"), i, k)







# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Housekeeping.
#
# - - - - - - - - - - - - - - - - - - - - - - 



for (k in label$short) {



	tmp.old <- NULL

	for (i in years) {

		tmp.dat = get(paste(k, i, sep = ""))

		tmp.old = rbind(tmp.old, tmp.dat)
	}


	write.table(tmp.old, paste(dirname.data, "fin-ex-", 
		k, "-panel-raw.csv", sep = ""), row.names = F, 
		sep = ",")

}
