# 	Gero Dolfus
# 	University of Helsinki, HECER
# 	Start: April 29, 2014.
#
#	Read SITC 2 data from OECD.
#	Finnish exports to the USSR and the world.
#
#
# Data Source:
#
#	10.1787/itcs-data-en
#
#
#
#



# Clear workspace.
rm(list = ls())


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 					Directories.
#
# - - - - - - - - - - - - - - - - - - - - - - 

dirname.data = "~/RRR_finn/data/oecd/"


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 					Read data.
#
# - - - - - - - - - - - - - - - - - - - - - - 




# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# The raw csv files from the OECD needed to be changed.
#
# Remove the "Flags" column from the header.
# Replace "x,a" and "x,d" by x (x=0:9).
# Replace "x," by "x".
# Replace "n"s" by "n's".
#
#
#	Contrary to the file names, there's no data for 1961-1963.
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


wrld.1 <- read.table(paste(dirname.data, "SITC_1961_1969_wrld/", 
	"SITC_REV2_Data_12103a9b-7354-455c-9ebe-4cba72e54f90.csv", 
	sep = ""), sep = ",", stringsAsFactors = F, header = T	, 
	colClasses = rep("character", 7))


wrld.2 <- read.table(paste(dirname.data, "SITC_1970_1980_wrld/", 
	"SITC_REV2_Data_53f05fd5-fea1-40bd-bfa4-6769a8c2fb42.csv", 
	sep = ""), sep = ",", stringsAsFactors = F, header = T	, 
	colClasses = rep("character", 7))


wrld.3 <- read.table(paste(dirname.data, "SITC_1981_1991_wrld/", 
	"SITC_REV2_Data_2bb7f927-df42-4710-9024-8c07230f80f4.csv", 
	sep = ""), sep = ",", stringsAsFactors = F, header = T	, 
	colClasses = rep("character", 7))
	
wrld=rbind(wrld.1,wrld.2,wrld.3)


su <- read.table(paste(dirname.data, "SITC_su_all/", 
	"SITC_REV2_Data_6f494195-faf5-447e-a2f7-5a7187044bf2.csv", 
	sep = ""), sep = ",", stringsAsFactors = F, header = T	, 
	colClasses = rep("character", 7))

	
# # su.1 <- read.table(paste(dirname.data, "SITC_1961_1969/", 
	# "SITC_REV2_Data_3c8ee37c-71f1-4cb3-8663-f0c86be1b322.csv", 
	# sep = ""), sep = ",", stringsAsFactors = F, header = T	, 
	# colClasses = rep("character", 7))

# su.1$Flags=NULL

# su.2 <- read.table(paste(dirname.data, "SITC_1970_1980/", 
	# "SITC_REV2_Data_c856baaa-3991-4899-93e8-7813b22f425a.csv", 
	# sep = ""), sep = ",", stringsAsFactors = F, header = T	, 
	# colClasses = rep("character", 7))

# su.3 <- read.table(paste(dirname.data, "SITC_1981_1991/", 
	# "SITC_REV2_Data_881f00ec-69da-47b0-9e44-d3d15b246fad.csv", 
	# sep = ""), sep = ",", stringsAsFactors = F, header = T	, 
	# colClasses = rep("character", 7))

# su=rbind(su.1,su.2,su.3)


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 					Housekeeping.
#
# - - - - - - - - - - - - - - - - - - - - - - 

write.table(su, paste(dirname.data, "sitc-oecd-fin-ex-su-panel-raw.csv", 
	sep = ""), row.names = F, sep = ",")
	
	write.table(wrld, paste(dirname.data, "sitc-oecd-fin-ex-wrld-panel-raw.csv", 
	sep = ""), row.names = F, sep = ",")

