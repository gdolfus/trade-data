# 	Gero Dolfus
# 	University of Helsinki, HECER
# 	Start: November 08, 2013.
#
#	First look at trade statistics from OECD.
#
#	2-digits only.
#
#	.
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


# Set the name of the directory where the data is.
dirname.data <- "~/RRR_finn/data/oecd/"

# Set the name of the directory for saving LaTeX tables.
dirname.tab <- "~/RRR_finn/tables/"



# * * * * * * * * * * * * * * * * * * * * * * 
#
# 				FINLAND - USSR
#
# * * * * * * * * * * * * * * * * * * * * * * 



# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read the data into memory.
#
# - - - - - - - - - - - - - - - - - - - - - - 


dat<-read.csv(paste(dirname.data, "bbb-hs-panel-fin-su.csv", 
	sep = ""))


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Look at the biggest groups of goods.
#
# - - - - - - - - - - - - - - - - - - - - - - 

# Sort the data according to the value of the trade by commodity group.
tmp.sorted <- dat[order(dat$Value, decreasing = TRUE), ]
# Check one year at a time.
tmp.88<-tmp.sorted[tmp.sorted $Time==1988, ]
# Drop the sum over all commodities.
tmp.88<-tmp.88[-1,]
tmp.88<-data.frame(tmp.88$Commodity,tmp.88$Value,tmp.88$Value/max(tmp.88$Value))
colnames(tmp.88)<-c('Commodity','Value','Relative to Max')

# Compute top and bottom commodity groups.
tmp.88.top15<-tmp.88[1:15,]
tmp.88.top25<-tmp.88[1:25,]
tmp.88.bottom10<-tmp.88[(dim(tmp.88)[1]-10):dim(tmp.88)[1],]

tmp.filler<-matrix(NA,nrow=1,ncol=dim(tmp.88)[2])
colnames(tmp.filler)<-colnames(tmp.88)
tmp.table<-rbind(tmp.88.top15,tmp.filler,tmp.88.bottom10)

tmp.textable<-xtable(tmp.table, caption='OECD Harmonized System 1988 -- Finnish Exports to USSR in 1988', align=rep('l',ncol(tmp.table)+1), label='trade-top-bottom-1988')
sink(file=paste(dirname.tab,'bbb-trade-fin-su-1988.tex',sep=''))
tmp.textable
sink() # this ends the sinking



# * * * * * * * * * * * * * * * * * * * * * * 
#
# 				FINLAND - ALL
#
# * * * * * * * * * * * * * * * * * * * * * * 


# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read the data into memory.
#
# - - - - - - - - - - - - - - - - - - - - - - 


dat<-read.csv(paste(dirname.data, "bbb-hs-1988-fin-all.csv", 
	sep = ""))


tmp.dat <- dat[dat$Commodity == "TOTAL : ALL COMMODITIES", ]
tmp.dat <- tmp.dat[order(tmp.dat$Value,decreasing=TRUE),]
tmp.dat <- tmp.dat[tmp.dat$Partner.Country!="World",]

# colnames(tmp.filler)<-colnames(tmp.88)

tmp.dat$Flow<-NULL
tmp.dat$Measure<-NULL
tmp.dat$Commodity<-NULL
tmp.dat$Flags<-NULL
tmp.dat$Time<-NULL
tmp.dat$Reporter.Country<-NULL
tmp.dat$tmp<-tmp.dat$Value/max(tmp.dat$Value)

tmp.table<-tmp.dat[1:20,]

colnames(tmp.table)<-c(" ","1988 USD","Relative to USSR")
rownames(tmp.table)<-NULL
tmp.textable<-xtable(tmp.table, caption='OECD Harmonized System 1988 -- Finland\'s biggest Trading Partners in 1988', align=rep('l',ncol(tmp.table)+1), label='top-partners-1988')
sink(file=paste(dirname.tab,'bbb-trade-fin-all-top-1988.tex',sep=''))
print(tmp.textable,include.rownames=FALSE)
sink() # this ends the sinking



