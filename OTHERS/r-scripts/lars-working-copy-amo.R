library(lars)
# load data from csv file
amoData <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/CSV/amo-mv1.csv',header=TRUE, sep=",")
# display data
amoData
# remove "null" columns (columns with all 0s)
amoDataNonZero <- amoData[,colSums(amoData) !=0]
amoDataNonZero
# Take all columns (features) except the last solutionVector
amo_x_var <- amoDataNonZero[,c(1:9)]
amo_x_var
# solution vector
amo_y_var <- amoDataNonZero[,10]
amo_y_var
#normalize with mean =0 and sd=1
amo_fin_x = scale(amo_x_var,center = TRUE,scale = TRUE)
amo_fin_x
names(amo_x_var)
# create lasso model using lars
amo_fit <- lars(amo_fin_x,amo_y_var,type = "lasso")
# show steps
amo_fit
# show standardized coefficients
coef(amo_fit)
# plot lasso path
amomyplot.lars <- edit(plot.lars)
dev.new()
amomyplot.lars(amo_fit,breaks = FALSE,lty=1,cex.lab=0.9,cex.axis=0.7,ylim = c(-0.2,0.2))
# text(amo_fin_x,amo_y_var)
amolables <- names(amo_x_var)
amolab = paste(col=1:length(amolables),sep = "-",amolables)
amolab
# legend('topleft', legend=amolables,legend=(col=1:length(amolables)), col=1:length(amolables),cex=0.7, lty=1,bty = "n")
legend('topleft', title="Robustness Factors",pt.lwd = 2,pt.cex = 2,legend=amolab, col=1:length(amolab),cex=0.8, lty=1,bty = "n")
amolables
length(amolables)

