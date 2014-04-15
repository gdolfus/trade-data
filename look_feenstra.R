# 	Gero Dolfus
# 	University of Helsinki, HECER
# 	Start: February 24, 2014.
#
#	Work with the Feenstra et al. data.	
#	
#
#
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
library(ggplot2)
# Standard plot settings.
sav.plot.setup <- theme(axis.text = element_text(color = "black", 
	size = "14"), axis.ticks = element_line(color = "black"), 
	panel.grid.minor = element_blank(), panel.background = element_blank(), 
	panel.grid.major.x = element_blank(), panel.grid.major.y = element_line(size = 0.1, 
		color = "gray", linetype = "dashed"), legend.justification = c(0, 
		1), legend.position = c(0, 1), legend.key = element_blank(), 
	legend.title = element_blank(), legend.text = element_text(color = "black", 
		size = "14"), axis.line = element_line(color = "black", 
		size = 0.75), axis.title = element_text(color = "black", 
		size = "14"))



# Directories.
# Data.
dirname.data <- "~/RRR_finn/data/feenstra/"
# Pictures to be saved.
dirname.pics <- "~/RRR_finn/pics/"



# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read the data into memory.
#
# - - - - - - - - - - - - - - - - - - - - - - 

wrld <- read.table(paste(dirname.data, "fin-ex-world-panel.csv", 
	sep = ""), sep = ",", stringsAsFactors = F, header = T, colClasses = rep("character", 
	1, 5))
su <- read.table(paste(dirname.data, "fin-ex-su-panel.csv", sep = ""), 
	sep = ",", stringsAsFactors = F, header = T, colClasses = rep("character", 
		1, 6))

su[,which(names(su)%in%c("value","perc.of.tot","perc.of.wrld"))]=lapply(su[,which(names(su)%in%c("value","perc.of.tot","perc.of.wrld"))],as.numeric)
wrld[,which(names(wrld)%in%c("value","perc.of.tot","perc.of.wrld"))]=lapply(wrld[,which(names(wrld)%in%c("value","perc.of.tot","perc.of.wrld"))],as.numeric)


# Only look at the years for which I have data for the USSR.
years = 1975:1991
wrld <- wrld[which(wrld$year %in% years), ]











# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Figure out the structure of the data.
#
# - - - - - - - - - - - - - - - - - - - - - - 

# For years starting with 1984.

tmpYY <- wrld[wrld$year == 1986, ]

length(tmpYY$sitc4)
length(unique(tmpYY$sitc4))

# X, XX, A, AA code suffixes may occur for the data past 1984.

#**************************************************
#
#	X and XX
#
#**************************************************


# SITC codes ending in XX. 
tmpXX <- tmpYY[grep("XX$", tmpYY$sitc4), ]

# SITC codes ending X.
tmpX <- tmpYY[grep("X$", tmpYY$sitc4), ]

tmpX <- tmpX[-grep("XX$", tmpX$sitc4), ]

# There are codes for which the values at the disaggregate codes don't sum up to the value at the aggregate code. Such codes end in X or XX.
# Feenstra et al. "As an example, suppose the value of imports is reported for SITC 4441 and 4442 as $100 million and $50 million, respectively giving a sum of $150 million for SITC 444, but the reported value of import for SITC 444 is $200 million. To deal with such a case, an additional SITC is created which combines the beginning of the 3-digit SITC with an ending of X (444X) and its value equals the difference between the reported value and the sum of the values of imports at the 4-digit SITC (50)."

dim(tmpX)
dim(tmpXX)

length(tmpX$sitc4) - length(unique(tmpX$sitc4))
length(tmpXX$sitc4) - length(unique(tmpXX$sitc4))

#**************************************************
#
#	A and AA
#
#**************************************************

# SITC codes ending in AA. 
tmpAAA <- tmpYY[grep("AAA$", tmpYY$sitc4), ]

# SITC codes ending in AA. 
tmpAA <- tmpYY[grep("AA$", tmpYY$sitc4), ]
tmpAA <- tmpAA[-grep("AAA$", tmpAA$sitc4), ]

# SITC codes ending A.
tmpA <- tmpYY[grep("A$", tmpYY$sitc4), ]
tmpA <- tmpA[-grep("AAA$", tmpA$sitc4), ]
tmpA <- tmpA[-grep("AA$", tmpA$sitc4), ]


length(tmpA$sitc4) - length(unique(tmpA$sitc4))
length(tmpAA$sitc4) - length(unique(tmpAA$sitc4))
length(tmpAAA$sitc4) - length(unique(tmpAAA$sitc4))


# There are codes for which values were reported at the more aggregate level, but not at the more disaggregate level. Such codes end in A or AA.
# Feenstra et al. "As an example, suppose the value of imports is reported as $200 million for SITC 444, but there are no corresponding four-digit SITC with leading numbers of 444. To deal with such a case, an additional SITC is created which combines the beginning of the 3-digit SITC with an ending of A (444A) and is given a value equal to the value of import at the 3-digit SITC level (200). This residual category represents “aggregate” imports or exports in SITC 444. (Having a double “AA” or triple “AAA” ending would occur rarely if at all)."


dim(tmpA)
dim(tmpAA)



# Note that there are double entries.

tmpCLEAR <- tmpYY[-which(tmpYY$sitc4 %in% tmpX$sitc4), ]
tmpCLEAR <- tmpCLEAR[-which(tmpCLEAR$sitc4 %in% tmpXX$sitc4), 
	]
tmpCLEAR <- tmpCLEAR[-which(tmpCLEAR$sitc4 %in% tmpA$sitc4), ]
tmpCLEAR <- tmpCLEAR[-which(tmpCLEAR$sitc4 %in% tmpAA$sitc4), 
	]
tmpCLEAR <- tmpCLEAR[-which(tmpCLEAR$sitc4 %in% tmpAAA$sitc4), 
	]

length((tmpCLEAR$sitc4))
length(unique(tmpCLEAR$sitc4))

# Should I just aggregate them?

tmpAGG <- aggregate(x = tmpYY$value, by = list(tmpYY$sitc4), FUN = sum)
names(tmpAGG) <- c("sitc2", "value")
tmpAGG$year <- rep(tmpYY$year, length(tmpAGG$value), 1)
tmpAGG$exporter <- rep(tmpYY$exporter, length(tmpAGG$value), 1)
tmpAGG$importer <- rep(tmpYY$importer, length(tmpAGG$value), 1)



#**************************************************
#
#	Additional changes to the Russian Federation data,
#	late 1990s.
#
#**************************************************


# See section 5 in Feenstra et al.


rm(list = ls(pattern = "tmp"))



# - - - - - - - - - - - - - - - - - - - - - -  
#
#	 Plots.		
#
# - - - - - - - - - - - - - - - - - - - - - - 


# -------------------------------------------------------------# Aggregate Finnish exports to the World and the USSR, base year==100.


tmp.df <- rbind(su[su$sitc4 == "total",which(names(su)%in%names(wrld)) ], wrld[wrld$sitc4 == 
	"total",])

base.year='1975'

tmp.df$value[tmp.df$importer == "USSR"] <- 100 * tmp.df$value[tmp.df$importer == 
	"USSR"]/tmp.df$value[tmp.df$importer == "USSR" & tmp.df$year == 
	base.year]
tmp.df$value[tmp.df$importer == "World"] <- 100 * tmp.df$value[tmp.df$importer == 
	"World"]/tmp.df$value[tmp.df$importer == "World" & tmp.df$year == 
	as.character(min(years))]
tmp.df$value <- round(tmp.df$value)

tmp.plot <- ggplot(tmp.df, aes(x = year, y = value))
tmp.plot <- tmp.plot + geom_line(aes(col = importer, group = importer))
tmp.plot <- tmp.plot + geom_point(aes(col = importer, group = importer))
tmp.plot <- tmp.plot + sav.plot.setup

x_breaks = seq(min(years), max(years), by = 5)
x_labels = as.character(x_breaks)

tmp.plot <- tmp.plot + scale_x_discrete(breaks = x_breaks, labels = x_labels)
tmp.plot <- tmp.plot + ylab(paste(base.year, " = 100", sep = " "))
tmp.plot <- tmp.plot + theme(axis.title.x = element_blank())
tmp.plot <- tmp.plot + ggtitle("Finnish Exports")

tmp.plot

ggsave(paste(dirname.pics, "feenstra-fin-ex-su-wrld-agg-100.pdf", 
	sep = ""), plot = tmp.plot, width = 8, height = 4)


# -----------------------------------------------------------
# Aggregate Finnish exports to the USSR, base year==100.

tmp.df <- rbind(su[su$sitc4 == "total",which(names(su)%in%names(wrld)) ])

base.year='1990'

tmp.df$value[tmp.df$importer == "USSR"] <- 100 * tmp.df$value[tmp.df$importer == 
	"USSR"]/tmp.df$value[tmp.df$importer == "USSR" & tmp.df$year == 
	base.year]

tmp.df$value <- round(tmp.df$value)

tmp.plot <- ggplot(tmp.df, aes(x = year, y = value))
tmp.plot <- tmp.plot + geom_line(aes(col = importer, group = importer))
tmp.plot <- tmp.plot + geom_point(aes(col = importer, group = importer))
tmp.plot <- tmp.plot + sav.plot.setup

x_breaks = seq(min(years), max(years), by = 5)
x_labels = as.character(x_breaks)

tmp.plot <- tmp.plot + scale_x_discrete(breaks = x_breaks, labels = x_labels)
tmp.plot <- tmp.plot + ylab(paste(base.year, " = 100", sep = " "))
tmp.plot <- tmp.plot + theme(axis.title.x = element_blank())
tmp.plot <- tmp.plot + ggtitle("Finnish Exports to the USSR")

tmp.plot

ggsave(paste(dirname.pics, "feenstra-fin-ex-su-agg-100.pdf", 
	sep = ""), plot = tmp.plot, width = 8, height = 4)





# ------------------------------------------------------------
# Aggregate Finnish exports to the world and the USSR, real values.


tmp.df <- rbind(su[su$sitc4 == "total", ], wrld[wrld$sitc4 == 
	"total", ])
tmp.df$value <- round(as.numeric(tmp.df$value)/1e+06)

tmp.plot <- ggplot(tmp.df, aes(x = year, y = value))
tmp.plot <- tmp.plot + geom_line(aes(col = importer, group = importer))
tmp.plot <- tmp.plot + geom_point(aes(col = importer, group = importer))
tmp.plot <- tmp.plot + sav.plot.setup

x_breaks = seq(min(years), max(years), by = 5)
x_labels = as.character(x_breaks)

tmp.plot <- tmp.plot + scale_x_discrete(breaks = x_breaks, labels = x_labels)
tmp.plot <- tmp.plot + ylab("Million USD")
tmp.plot <- tmp.plot + theme(axis.title.x = element_blank())
tmp.plot <- tmp.plot + ggtitle("Finnish Exports")

ggsave(paste(dirname.pics, "feenstra-fin-ex-su-wrld-agg.pdf", 
	sep = ""), plot = tmp.plot, width = 8, height = 4)




# -----------------------------------------------------------
# Share of exports to Soviet Union in total Finnish exports.

tmp.df <- su[su$sitc4 == "total",]
tmp.df$perc.of.wrld <- round(as.numeric(tmp.df$perc.of.wrld))

tmp.plot <- ggplot(tmp.df, aes(x = year, y = perc.of.wrld))
tmp.plot <- tmp.plot + geom_line(aes(col = importer, group = importer))
tmp.plot <- tmp.plot + geom_point(aes(col = importer, group = importer))
tmp.plot <- tmp.plot + sav.plot.setup

x_breaks = seq(min(years), max(years), by = 5)
x_labels = as.character(x_breaks)

tmp.plot <- tmp.plot + scale_x_discrete(breaks = x_breaks, labels = x_labels)
tmp.plot <- tmp.plot + ylab("percent")
tmp.plot <- tmp.plot + theme(axis.title.x = element_blank())
tmp.plot <- tmp.plot + ggtitle("Share in Total Finnish Exports")

ggsave(paste(dirname.pics, "feenstra-fin-ex-su-shrofwrld-agg.pdf", 
	sep = ""), plot = tmp.plot, width = 8, height = 4)


