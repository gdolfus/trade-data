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
# Enable reading Excel files.
library(gdata)


# Directories.
# Data.
dirname.data = "~/RRR_finn/data/feenstra/"
dirname.data.exp = "~/RRR_finn/data/statfin/national/"



# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Choose.
#
# - - - - - - - - - - - - - - - - - - - - - - 



countries = c("su", "wrld", "uk", "ger", "us", "swe", 
	"nor", "fra", "den")


rm(list = ls(pattern = "tmp"))

# "USSR" is not in the data past 1991.
years = 1975:1991


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read data.
#
# - - - - - - - - - - - - - - - - - - - - - - 


# Read export prices.
exp = read.table(paste(dirname.data.exp, "fin-exportprices.csv", 
	sep = ""), sep = ",", stringsAsFactors = F, header = T, 
	colClasses = rep("character", 1, 9))
# Convert the values to numeric.
exp[, -which(names(exp) %in% "year")] = lapply(exp[, 
	-which(names(exp) %in% "year")], as.numeric)

# Change the base year to 1975.
tmp.new.base = "1975"

tmp.base = exp[which(exp$year == tmp.new.base), -which(names(exp) %in% 
	"year")]
tmp.base = as.numeric(tmp.base)

tmp.new = t(100 * t(exp[, -which(names(exp) %in% "year")])/tmp.base)

exp[, -which(names(exp) %in% "year")] = tmp.new


# Read the panels of the Feenstra data that were created with read_feenstra_raw.R.

for (i in countries) {


	tmp.dat <- read.table(paste(dirname.data, "fin-ex-", 
		i, "-panel-raw.csv", sep = ""), sep = ",", stringsAsFactors = F, 
		header = T, colClasses = rep("character", 1, 
			5))


	# Convert "value" to numeric.
	tmp.dat[, which(names(tmp.dat) %in% c("value"))] = as.numeric(tmp.dat[, 
		which(names(tmp.dat) %in% c("value"))])

	assign(i, tmp.dat)



}

rm(list = ls(pattern = "tmp"), i)

# Read the descriptions.
# This file comes directly from the UN.
sitc.desc = read.xls(paste(dirname.data, "SITC2.xls", 
	sep = ""), colClasses = c("character", "character"), 
	stringsAsFactors = F)

# Choose the codes and descriptions for 4-digit SITC 2 codes.
sitc.desc = sitc.desc[which(nchar(sitc.desc$Commodity.Code) == 
	4), ]





# - - - - - - - - - - - - - - - - - - - - - -  
#
#	 Add variables.
#
# - - - - - - - - - - - - - - - - - - - - - - 





for (i in countries) {

	tmp.df = get(i)

	tmp.old <- NULL

	for (j in years) {

		# Subset the data.
		tmp.dat = tmp.df[which(tmp.df$year == j), ]

		# -------------------------------------
		# Add the descriptions of the SITC 2 codes to the trade data.

		tmp.dat = merge(x = tmp.dat, y = sitc.desc, by.x = "sitc4", 
			by.y = "Commodity.Code", all.x = T)



		# ---------------------------------
		# Deflate the data.


		# Store the nominal values with a different name.
		tmp.dat$nominal.value = tmp.dat$value

		tmp.dat$real.value = NA

		# Subset the export prices.
		tmp.exp = exp[exp$year == j, ]

		# Deflate food stuff.
		
		tmp.id = grep("^0", tmp.dat$sitc4)
		tmp.dat$real.value[tmp.id] = tmp.dat$value[tmp.id] * 
			tmp.exp[, grep(paste("sitc", "0", sep = "."), 
				names(tmp.exp))]/100

		tmp.id.done = tmp.id

		# Deflate manufacturing (wood).
		tmp.id = grep("^63", tmp.dat$sitc4)
		tmp.dat$real.value[tmp.id] = tmp.dat$value[tmp.id] * 
			tmp.exp[, grep(paste("sitc", "63", sep = "."), 
				names(tmp.exp))]/100

		tmp.id.done = c(tmp.id.done, tmp.id)


		# Deflate manufacturing (paper).
		tmp.id = grep("^64", tmp.dat$sitc4)
		tmp.dat$real.value[tmp.id] = tmp.dat$value[tmp.id] * 
			tmp.exp[, grep(paste("sitc", "64", sep = "."), 
				names(tmp.exp))]/100

		tmp.id.done = c(tmp.id.done, tmp.id)


		# Deflate manufacturing (machinery).
		tmp.id = grep("^7", tmp.dat$sitc4)
		tmp.dat$real.value[tmp.id] = tmp.dat$value[tmp.id] * 
			tmp.exp[, grep(paste("sitc", "7", sep = "."), 
				names(tmp.exp))]/100

		tmp.id.done = c(tmp.id.done, tmp.id)


		# Deflate manufacturing (other than 63 or 64).
		
		tmp.id = grep("^6", tmp.dat$sitc4)
		tmp.id = tmp.id[-which(tmp.id %in% which(substr(tmp.dat$sitc4, 
			1, 2) %in% c("63", "64")))]

		tmp.dat$real.value[tmp.id] = tmp.dat$value[tmp.id] * 
			tmp.exp[, grep(paste("sitc", "6$", sep = "."), 
				names(tmp.exp))]/100

		tmp.id.done = c(tmp.id.done, tmp.id)


		# Deflate all other goods.
		
		tmp.id = -tmp.id.done

		tmp.dat$real.value[tmp.id] = tmp.dat$value[tmp.id] * 
			tmp.exp[, grep("TOTAL", names(tmp.exp))]/100

		# Deflate all goods by the same export price index.
		

		tmp.dat$value = tmp.dat$value * tmp.exp[, grep("TOTAL", 
			names(tmp.exp))]/100




		# ---------------------------------
		# Additions based on deflated data.


		# Add total exports.
		tmp.total <- tmp.dat[1, ]
		tmp.total$sitc4 = "total"
		tmp.total$Commodity.description = "total"
		tmp.total$value = sum(as.numeric(tmp.dat$value))

		# Add share of good i in total exports to country X.
		tmp.dat$perc.of.tot <- 100 * as.numeric(tmp.dat$value)/tmp.total$value
		tmp.total$perc.of.tot = sum(tmp.dat$perc.of.tot)






		# ---------------------------------
		# Combine it with the data for earlier years.

		tmp.old = rbind(tmp.old, tmp.dat, tmp.total)




	}

	assign(i, tmp.old)
}



rm(list = ls(pattern = "tmp"), i, j)

# - - - - - - - - - - - - - - - - - - - - - -  
#
#	 Share of exports to XXX in total exports by goods.
#
# - - - - - - - - - - - - - - - - - - - - - - 


tmp.old <- NULL

tmp.countries = countries[-which(countries == "wrld")]

for (k in tmp.countries) {
	tmp.dat = get(k)

	for (i in years) {
		tmp.df <- tmp.dat[tmp.dat$year == i, ]
		tmp.wrld <- wrld[wrld$year == i, ]
		# Reduce data on exports to the world to the codes in USSR exports.
		tmp.wrld <- tmp.wrld[match(tmp.df$sitc4, tmp.wrld$sitc4), 
			]
		# Compute the percentage of SU exports in total exports.
		tmp.df$value <- as.numeric(tmp.df$value)
		tmp.wrld$value <- as.numeric(tmp.wrld$value)
		tmp.df$perc.of.wrld <- 100 * tmp.df$value/tmp.wrld$value
		# Combine the data across years.
		tmp.old <- rbind(tmp.old, tmp.df)
	}

	assign(k, tmp.old)
}


rm(list = ls(pattern = "tmp"), i)


# - - - - - - - - - - - - - - - - - - - - - -  
#
#	 Housekeeping.
#
# - - - - - - - - - - - - - - - - - - - - - - 



for (k in countries) {

	write.table(get(k), paste(dirname.data, "fin-ex-", 
		k, "-panel.csv", sep = ""), row.names = F, sep = ",")

}









