# 	Gero Dolfus
# 	University of Helsinki, HECER
# 	Start: April 18, 2014.
#
#	Read export prices for Finland.
#	
#
#
# Data Source:
#
# http://tilastokeskus.fi/til/thi/index_en.html
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

# Directories.
# Data.
dirname.data = "~/RRR_finn/data/statfin/prices/"



# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Functions.
#
# - - - - - - - - - - - - - - - - - - - - - - 

# Returns string w/o leading or trailing whitespace.
fun.trim <- function(x) gsub("^\\s+|\\s+$", "", x)
# Remove all punctuation.
fun.rm.pnct <- function(x) gsub("[[:punct:]]", " ", x)




# - - - - - - - - - - - - - - - - - - - - - -  
#
# 		Read data.
#
# - - - - - - - - - - - - - - - - - - - - - - 

# NOTE: I've manipulated the csv file manually to be able to read it.
tmp.file<-paste(dirname.data,'030_thi_tau_103c.csv',sep='')
tmp.dat = read.table(tmp.file, header = F, sep = ",",  stringsAsFactors = FALSE)

names(tmp.dat)=tmp.dat[1,]
tmp.dat=tmp.dat[-1,-1]
# The data for 2014 are missing.
tmp.dat=tmp.dat[-1,]

names(tmp.dat)[1]='year'

# Select columns with data classified by SITC.
tmp.sitc=grep("SITC",names(tmp.dat))
tmp.dat=tmp.dat[,c(1,tmp.sitc)]
tmp.dat=tmp.dat[,order(names(tmp.dat))]
tmp.dat=tmp.dat[,c(dim(tmp.dat)[2],1:(dim(tmp.dat)[2]-1))]

# Change to numeric to obtain NAs for missing data.
tmp.dat[,-which(names(tmp.dat)%in%'year')]=lapply(tmp.dat[,-which(names(tmp.dat)%in%'year')],as.numeric)

# Select the entries that are not NAs.
tmp.idx=which( !is.na(tmp.dat), arr.ind=TRUE)

tmp.dat=tmp.dat[,unique(tmp.idx[,2])]


tmp.sitc=grep('SITC',names(tmp.dat))
tmp.names=names(tmp.dat)[tmp.sitc]

tmp.names=substr(tmp.names,1,2)
tmp.names=fun.trim(tmp.names)
tmp.names=paste('sitc',tmp.names,sep='.')

tmp.dat=cbind(tmp.dat,rep(tmp.dat[tmp.sitc]))
names(tmp.dat)[tmp.sitc] = tmp.names


# Housekeeping.
write.csv(tmp.dat,paste(dirname.data,'fin-exportprices.csv',sep=''),row.names=FALSE)

