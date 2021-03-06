# 	Gero Dolfus
# 	University of Helsinki, HECER
# 	Start: November 08, 2013.
#
#	First look at trade statistics from OECD.
#
#	2-digits only.
#
#	
#
#	Description of the categories.
#	http://unstats.un.org/unsd/tradekb/Knowledgebase/Harmonized-Commodity-Description-and-Coding-Systems-HS
#
#	Fetch the data from OECD.
#	http://dx.doi.org/10.1787/data-00060-en
#
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
# Load the package for creating plots.
library(ggplot2)


# Set the name of the directory where the data is.
dirname.data <- "~/RRR_finn/data/oecd/"

# Set the name of the directory for saving LaTeX tables.
dirname.tab <- "~/RRR_finn/tables/"

# Set the name of the directory for saving pictures.
dirname.pics <- "~/RRR_finn/pics/"


# The data is for 1988 and 1989.
year <- 1989

# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read the data into memory.
#
# - - - - - - - - - - - - - - - - - - - - - - 




dat <- read.csv(paste(dirname.data, "oecd-hs-1988-fin-all-", year, ".csv", sep = ""))




sav.comment.text <- "{\\footnotesize{\\it Source:} OECD Harmonized System 1988, \\cite{OECD2013}}."



# * * * * * * * * * * * * * * * * * * * * * * 
#
# 				FINLAND - country i	
#
# * * * * * * * * * * * * * * * * * * * * * * 

# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Look at the biggest groups of goods.
#
# - - - - - - - - - - - - - - - - - - - - - - 

for (i in c("USSR", "Sweden", "UK", "Germany", "USA")) {
	# for (i in c("USSR")) {
	

	tmp.dat <- dat[dat$Partner.Country == i, ]



	# Sort the data according to the value of the trade by commodity group.
	tmp.sorted <- tmp.dat[order(tmp.dat$Value, decreasing = TRUE), ]
	# Check one year at a time.
	tmp.88 <- tmp.sorted[tmp.sorted$Time == year, ]
	tmp.total <- tmp.88[1, ]
	# Drop the sum over all commodities.
	tmp.88 <- tmp.88[-1, ]
	tmp.88 <- data.frame(tmp.88$Commodity, tmp.88$Value, 100 * tmp.88$Value/tmp.total$Value, 100 * tmp.88$Value/max(tmp.88$Value))
	colnames(tmp.88) <- c("Commodity", "current Mill USD", "% of sum", "% of max ")

	# Compute top and bottom commodity groups.
	tmp.88.top15 <- tmp.88[1:10, ]
	tmp.88.top25 <- tmp.88[1:25, ]
	# tmp.88.bottom5 <- tmp.88[(dim(tmp.88)[1] - 5):dim(tmp.88)[1], 	]
	# tmp.filler <- matrix(NA, nrow = 1, ncol = dim(tmp.88)[2])
# colnames(tmp.filler) <- colnames(tmp.88)
tmp.88.bottom5 <- NULL
	tmp.filler <- NULL
	tmp.table <- rbind(tmp.88.top15, tmp.filler, tmp.88.bottom5)

	tmp.table$"current Mill USD" <- tmp.table$"current Mill USD"/10^6
	tmp.table$"current Mill USD" <- format(tmp.table$"current Mill USD", big.mark = ",", scientific = FALSE, digits = 2)

	tmp.comment <- list()
	tmp.comment$pos <- list()
	tmp.comment$pos[[1]] <- c(nrow(tmp.table))
	tmp.comment$command <- c(paste("\\hline \n", sav.comment.text, "  \n", sep = ""))

tmp.comment.text <- paste("\\multicolumn{4}{l{",sav.comment.text,'}',sep="")


tmp.label = paste("oecd-trade-fin-", tmp.dat$Partner.Country[1], "-", as.character(year), sep = "")
tmp.filename = paste(dirname.tab, tmp.label,".tex", sep = "")


	tmp.textable <- xtable(tmp.table, caption = paste("Finnish Exports to ", i, " in ", as.character(year), sep = ""), 
		align = rep("l", ncol(tmp.table) + 1), label = tmp.label, 
		digits = c(0, 0, 2, 2, 2))
	sink(file = tmp.filename)
	print(tmp.textable, include.rownames = FALSE, caption.placement = getOption("xtable.caption.placement", "top"), 
		add.to.row = tmp.comment, hline.after = c(-1, 0))
	sink() # this ends the sinking

# Save also a smaller table.
tmp.table=tmp.table[,c(1,3)]
tmp.filename = paste(dirname.tab, tmp.label,"-percentage-of-sum-only.tex", sep = "")

tmp.textable <- xtable(tmp.table, caption = paste("Finnish Exports to ", i, " in ", as.character(year), sep = ""), 
		align = rep("l", ncol(tmp.table) + 1), label = tmp.label, 
		digits = c(0,  2,2))
	sink(file = tmp.filename)
	print(tmp.textable, include.rownames = FALSE, caption.placement = getOption("xtable.caption.placement", "top"), 
		add.to.row = tmp.comment, hline.after = c(-1, 0))
	sink() # this ends the sinking




	if (i == "USSR") {
		sav.dat <- tmp.88
	}
	
	

}


rm(list = ls(pattern = "tmp"))


# * * * * * * * * * * * * * * * * * * * * * * 
#
# 				FINLAND - ALL
#
# * * * * * * * * * * * * * * * * * * * * * * 




tmp.dat <- dat[dat$Commodity == "TOTAL : ALL COMMODITIES", ]
tmp.dat <- tmp.dat[order(tmp.dat$Value, decreasing = TRUE), ]

tmp.dat$Flow <- NULL
tmp.dat$Measure <- NULL
tmp.dat$Commodity <- NULL
tmp.dat$Flags <- NULL
tmp.dat$Time <- NULL
tmp.dat$Reporter.Country <- NULL

# Remove "World", i.e. start from second row.
tmp.table <- tmp.dat[2:dim(tmp.dat)[1], ]
tmp.table$tmp <- 100 * tmp.table$Value/max(tmp.table$Value)
tmp.table$tmp2 <- 100 * tmp.table$Value/sum(tmp.table$Value)

# Choose a subset of the table.
tmp.table=tmp.table[1:7,]

# Create the table.

tmp.table$Value <- tmp.table$Value/10^6
tmp.table$tmp2 <- format(tmp.table$tmp2, scientific = FALSE, digits = 2)
tmp.table$tmp <- format(tmp.table$tmp, scientific = FALSE, digits = 2)
tmp.table$Value <- format(tmp.table$Value, big.mark = ",", scientific = FALSE, digits = 2)


colnames(tmp.table) <- c(" ", "current Mill USD", "% of USSR", "% of total")
rownames(tmp.table) <- NULL


tmp.comment <- list()
tmp.comment$pos <- list()
tmp.comment$pos[[1]] <- c(nrow(tmp.table))
tmp.comment$command <- c(paste("\\hline \n", sav.comment.text, "  \n", sep = ""))


tmp.comment.text <- paste("\\multicolumn{4}{l{",sav.comment.text,'}',sep="")


tmp.label = paste("oecd-trade-fin-all-top-", as.character(year), sep = "")
tmp.filename = paste(dirname.tab, tmp.label,".tex", sep = "")


tmp.textable <- xtable(tmp.table, caption = paste("Finland's biggest Trading Partners in", as.character(year), 
	sep = " "), align = c("l", "l", "r", "r", "r"), label = tmp.label, 
	digits = c(0, 0, 2, 2, 2))


sink(file = tmp.filename)
print(tmp.textable, include.rownames = FALSE, caption.placement = getOption("xtable.caption.placement", "top"), 
	add.to.row = tmp.comment, hline.after = c(-1, 0))
sink() # this ends the sinking

sink(file = tmp.filename)
print(tmp.textable, include.rownames = FALSE, caption.placement = getOption("xtable.caption.placement", "top"), 
	add.to.row = tmp.comment, hline.after = c(-1, 0))
sink() # this ends the sinking



# Create a pie chart.

colnames(tmp.table)[1]='country'
colnames(tmp.table)[4]='percentage'
tmp.table$country=as.character(tmp.table$country)
tmp.other=as.character((100-sum(as.numeric(tmp.table$percentage))))
tmp.table=rbind(tmp.table,c("Other","NA","NA",tmp.other))
tmp.table$percentage = as.numeric(tmp.table$percentage)

tmp.plot<-ggplot(tmp.table, aes(x = factor(0), y = percentage, fill = country))
tmp.plot =tmp.plot+	geom_bar(stat = "identity", position = "fill") 
tmp.plot =tmp.plot+	scale_fill_brewer(palette = "Set1") 
tmp.plot =tmp.plot+ coord_polar(theta = "y") 
tmp.plot = tmp.plot + 
	theme(axis.ticks = element_blank(), 
	axis.text.y = element_blank(), 
		axis.text.x = element_blank(),
		 panel.background = element_blank(),
		panel.grid.minor = element_blank(), 
		panel.grid.major = element_blank(), 
		axis.title.y = element_blank(), 		
		axis.title.x = element_blank(), 
		legend.title=element_blank()
		# title=element_text(paste("Finland's biggest Trading Partners in", as.character(year)))
		)

ggsave(paste(dirname.pics,tmp.label,'-pie.pdf',sep=""), plot = tmp.plot, width = 4, height = 4)



rm(list = ls(pattern = "tmp"))




# * * * * * * * * * * * * * * * * * * * * * * 
#
# 				Geographic distribution of largest export groups to the USSR
#
# * * * * * * * * * * * * * * * * * * * * * * 


tmp.goods <- as.character(sav.dat$Commodity[1:6])


tmp.dat <- dat[dat$Commodity %in% tmp.goods, ]
tmp.dat <- tmp.dat[tmp.dat$Partner.Country != "World", ]
tmp.dat$Reporter.Country <- NULL
tmp.dat$Measure <- NULL
tmp.dat$Flow <- NULL
tmp.dat$Time <- NULL
tmp.dat$Flags <- NULL
tmp.dat$Value <- as.numeric(as.character(tmp.dat$Value))

tmp.sorted <- tmp.dat[order(tmp.dat$Value, decreasing = TRUE), ]


start = "yes"
tmp.ncountries = 5
for (i in tmp.goods) {

	tmp.v <- tmp.sorted[tmp.sorted$Commodity == i, ]
	tmp.v$Commodity <- NULL
	tmp.v$tmp <- 100 * tmp.v$Value/sum(tmp.v$Value)
	tmp.new <- tmp.v[1:tmp.ncountries, ]
	# tmp.new$Partner.Country<-as.character(tmp.new$Partner.Country)
	# tmp.new$Value<-as.numeric(as.character(tmp.new$Value))


	# Place holder.
	tmp.filler <- matrix(NA, nrow = 2, ncol = dim(tmp.new)[2])
	colnames(tmp.filler) <- colnames(tmp.new)
	tmp.filler[1, 1] <- i
	# tmp.filler[1, 2] <- " "
	# tmp.filler[1, 3] <- " "
tmp.filler <- data.frame(tmp.filler)

	if (start == "yes") {
		tmp.df <- tmp.new
		start = "no"
	}

	# Create one long table.
	tmp.df <- rbind(tmp.df, tmp.filler, tmp.new, tmp.filler[, 2])



}


tmp.df <- tmp.df[-c(1:tmp.ncountries), ]

colnames(tmp.df) <- c("Country", "current Mill USD", "% of total")
tmp.table <- tmp.df

tmp.table$"current Mill USD" <- as.numeric(tmp.table$"current Mill USD")
tmp.table$"current Mill USD" <- tmp.table$"current Mill USD"/10^6
tmp.table$"% of total" <- as.numeric(tmp.table$"% of total")
tmp.table$"current Mill USD" <- format(tmp.table$"current Mill USD", big.mark = ",", scientific = FALSE, digits = 2)

tmp.comment.text <- paste("\\multicolumn{3}{l{",sav.comment.text,'}',sep="")


tmp.comment <- list()
tmp.comment$pos <- list()
tmp.comment$pos[[1]] <- c(nrow(tmp.table))
tmp.comment$command <- c(paste("\\hline \n", sav.comment.text, "  \n", sep = ""))

tmp.label = paste("oecd-trade-fin-ussr-distribution-", as.character(year), sep = "")
tmp.filename = paste(dirname.tab, tmp.label,".tex", sep = "")


tmp.textable <- xtable(tmp.table, caption = "Geographical Distribution of Biggest Export Groups in Finnish-Soviet Trade", 
	align = c("l", "l", "r", "r"), label =tmp.label, 
	digits = c(0, 0, 2, 2))


sink(file = tmp.filename)
print(tmp.textable, include.rownames = FALSE, caption.placement = getOption("xtable.caption.placement", "top"), 
	add.to.row = tmp.comment, hline.after = c(-1, 0), tabular.environment = "longtable", floating = FALSE)
sink() # this ends the sinking



# rm(list = ls(pattern = "tmp"))
