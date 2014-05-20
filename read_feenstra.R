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
dirname.data.xra = "~/RRR_finn/data/bof/fim_usd_exchange_rate/"


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Choose.
#
# - - - - - - - - - - - - - - - - - - - - - - 

countries = c("su", "wrld", "uk", "ger", "us", "swe", 
	"nor", "fra", "den", "ita", "pol", "spa", "chi", 
	"net")



# "USSR" is not in the data past 1991.
# 
years = 1975:1991


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read data.
#
# - - - - - - - - - - - - - - - - - - - - - - 

# Read exchange rates.

xra = read.table(paste(dirname.data.xra, "fim-usd-xrate-1948-2013.csv", 
	sep = ""), sep = ",", stringsAsFactors = F, header = T, 
	colClasses = rep("character", 1, 3))

xra[, which(names(xra) %in% c("fim.usd", "eur.usd"))] = lapply(xra[, 
	which(names(xra) %in% c("fim.usd", "eur.usd"))], 
	as.numeric)


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

		names(tmp.dat)[which(names(tmp.dat) %in% c("Commodity.description.x"))] = "Commodity.description"
		tmp.dat[which(names(tmp.dat) %in% c("Commodity.description.y"))] = NULL





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
		# Additions based on NOMINAL data.
		
		


		# Add the data in EUR.
		tmp.dat$eur.value = tmp.dat$nominal.value * xra$eur.usd[which(xra$year == 
			j)]

		# Add the data in FIM.
		tmp.dat$fim.value = tmp.dat$nominal.value * xra$fim.usd[which(xra$year == 
			j)]


			# Add share of good i in total exports to country X.
		tmp.dat$perc.of.tot <- 100 * as.numeric(tmp.dat$nominal.value)/sum(as.numeric(tmp.dat$nominal.value), 
			na.rm = T)

		# ---------------------------------

	# Add totals.
		tmp.total <- tmp.dat[1, ]
		tmp.total$sitc4 = "total"
		tmp.total$Commodity.description = "total"
	
	 tmp.total$value =   sum(as.numeric(tmp.dat$value), 
			na.rm = T)

	tmp.total$nominal.value = sum(as.numeric(tmp.dat$nominal.value), 
			na.rm = T)

	tmp.total$real.value  = sum(as.numeric(tmp.dat$real.value), 
			na.rm = T)

	tmp.total$eur.value  = sum(as.numeric(tmp.dat$eur.value), 
			na.rm = T)
	
	tmp.total$fim.value  = sum(as.numeric(tmp.dat$fim.value), 
			na.rm = T)


	tmp.total$fim.value  = sum(as.numeric(tmp.dat$fim.value), 
			na.rm = T)


	tmp.total$perc.of.tot = sum(as.numeric(tmp.dat$perc.of.tot))

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



tmp.countries = countries[-which(countries == "wrld")]

for (k in tmp.countries) {
	tmp.dat = get(k)
	tmp.old <- NULL

	for (i in years) {
		tmp.df <- tmp.dat[which(tmp.dat$year == i), ]
		tmp.wrld <- wrld[which(wrld$year == i), ]


		# Reduce data on exports to the world to the codes in USSR exports.
		tmp.wrld <- tmp.wrld[which(tmp.wrld$sitc4 %in% 
			tmp.df$sitc4), ]
		tmp.wrld = tmp.wrld[order(tmp.wrld$sitc4), ]
		tmp.df = tmp.df[order(tmp.df$sitc4), ]

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
	print(k)
	write.table(get(k), paste(dirname.data, "fin-ex-", 
		k, "-panel.csv", sep = ""), row.names = F, sep = ",")

}








