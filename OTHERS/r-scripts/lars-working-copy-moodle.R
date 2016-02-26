library(ggplot2)
library(glmnet)
library(lars)
library(msgps)
# load data from csv file
fullData <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/CSV/moodle.csv',header=TRUE, sep=",")
# display data
fullData
# remove "null" columns (columns with all 0s)
M <- fullData[,colSums(fullData) !=0]
M
# Take all columns (features) except the last solutionVector
x1 <- M[,c(1:10)]
x1
x <- x1[,-3]
x
# solution vector
y <- M[,11]
y
#normalize with mean =0 and sd=1
fin_x = scale(x,center = TRUE,scale = TRUE)
fin_x
names(x)
# create lasso model using lars
fit <- lars(fin_x,y,type = "lasso")
# show steps
fit
# show standardized coefficients
coef(fit)
# plot lasso path
# myplot.lars <- edit(plot.lars)
dev.new()
myplot.lars(fit,breaks = TRUE,lty=1,cex.lab=0.9,cex.axis=0.7,ylim = c(-0.5,0.8))
# text(fin_x,y)
mylab = paste(col=1:length(labs),sep = "-",labs)
mylab
# legend('topleft', legend=labs,legend=(col=1:length(labs)), col=1:length(labs),cex=0.7, lty=1,bty = "n")
legend('topleft', title="Robustness Factors",pt.lwd = 2,pt.cex = 2,legend=mylab, col=1:length(labs),cex=0.8, lty=1,bty = "n")
labs
length(labs)
