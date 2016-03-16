library(lars)
# data <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/Jenkins-core-plugins-combined.csv')
# data <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/AMO-Mv3-rq2.csv')
data <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/Fireplace-Mv4-rq2.csv')
# data <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/Jenkins-core-plugins-combined.csv')

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
myplot.lars <- edit(plot.lars)
dev.new()
labs2 <- names(features)
myplot.lars(lassoWithLars,breaks = FALSE,lty=1,cex.lab=0.9,cex.axis=0.7,ylim = c(-2,2),col=1:length(labs))
lassoWithLars
# labs <- names(unlist(lassoWithLars$actions))
labs2 <- names(features)
mylab = paste(col=1:length(labs2),sep = "  -  #",labs2)
mylab
# legend('topleft', legend=labs,legend=(col=1:length(labs)), col=1:length(labs),cex=0.7, lty=1,bty = "n")
legend('topleft', title="Robustness Factors",pt.lwd = 2,pt.cex = 2,legend=mylab, col=1:length(labs),cex=0.8, lty=1,bty = "n")
