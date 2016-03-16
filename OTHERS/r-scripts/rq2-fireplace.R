library(lars)
# load data from csv file
fireplaceData <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/CSV/combined-fireplace.csv',header=TRUE, sep=",")
# display data
fireplaceData
# remove "null" columns (columns with all 0s)
fireplaceDataNonZero <- fireplaceData[,colSums(fireplaceData) !=0]
fireplaceDataNonZero
# Take all columns (features) except the last solutionVector
fireplace_x_var <- fireplaceDataNonZero[,c(1:11)]
fireplace_x_var
# solution vector
fireplace_y_var <- fireplaceDataNonZero[,12]
fireplace_y_var
#normalize with mean =0 and sd=1
fireplace_fin_x = scale(fireplace_x_var,center = TRUE,scale = TRUE)
fireplace_fin_x
names(fireplace_x_var)
# create lasso model using lars
fireplace_fit <- lars(fireplace_fin_x,fireplace_y_var,type = "lasso")
# show steps
fireplace_fit
# show standardized coefficients
coef(fireplace_fit)
# plot lasso path
fireplacemyplot.lars <- edit(plot.lars)
dev.new()
fireplacemyplot.lars(fireplace_fit,breaks = FALSE,lty=1,cex.lab=0.9,cex.axis=0.7,ylim = c(-1.5,1))
# text(fireplace_fin_x,fireplace_y_var)
fireplacelables <- names(fireplace_x_var)
fireplacelab = paste(col=1:length(fireplacelables),sep = "-",fireplacelables)
fireplacelab
# legend('topleft', legend=fireplacelables,legend=(col=1:length(fireplacelables)), col=1:length(fireplacelables),cex=0.7, lty=1,bty = "n")
legend('topleft', title="Robustness Factors",pt.lwd = 2,pt.cex = 2,legend=fireplacelab, col=1:length(fireplacelab),cex=0.8, lty=1,bty = "n")
fireplacelables
length(fireplacelables)

