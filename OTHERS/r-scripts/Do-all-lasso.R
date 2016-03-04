library(lars)
data <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/Jenkins-core-plugins-combined.csv')
minPerColumn <- apply(data,MARGIN=2,min)
minPerColumn
maxPerColumn <- apply(data,MARGIN=2,max)
maxPerColumn
data2 <- data[,minPerColumn!=maxPerColumn]
data2
names(data2)
features <- data2[,setdiff(c(1:dim(data2)[2]),which(colnames(data2)=='solutionVector'))]
features
response <- data2[,which(colnames(data2)=='solutionVector')]
featuresNormalized <- scale(features,center=TRUE,scale=TRUE)
lassoWithLars <- lars(x=featuresNormalized,y=response,type="lasso")
dev.new()
plot(lassoWithLars)
lassoWithLars
