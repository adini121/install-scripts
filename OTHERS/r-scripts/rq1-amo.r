library(ggplot2)
library(calibrate)
raw_robusttests = c(50,50,6,30,8,41,37,35,50,50,50,48,45,41,37,35,48,50,50,48,45,41,37,35,50,50,6,30,8,41,37,35,50,50,50,48,45,41,37,35,48,50,50,48,45,41,37,35)
length(raw_robusttests)
robusttests = c(1,1,0.95,0.90,0.85,0.80,0.75,1,1,1,0.90,0.90,0.90,0.85,0.75,1,1,1,1,1,0.92,0.90,0.85,0.75,1,1,0.95,0.90,0.85,0.80,0.75,1,1,1,0.90,0.90,0.90,0.85,0.75,1,1,1,1,1,0.92,0.90,0.85,0.75)
length(robusttests)
revisions=(c(1:48))
dev.new()
plot(revisions,robusttests,xaxt ="n",xlab = "",ylab = "Robustness grade (Avg. # of tests = 50)",ylim = range(0:1),xlim = range(0:50),cex.main=0.8,col="black",pch=16,bty="l",main="Mozilla Addons",cex.lab=1, cex.axis=0.7)
axis(1, at = 1:50, label = rep("", 50), tck = -0.01)
axis(1, at = 1:50, line = -0.7, lwd = 0, cex.axis = 0.7)
mtext(side=1, text="Number of Software revisions over time", line=1.5)
legend("topright", legend = c("# of robust tests)","Major release"), cex=0.75, lty =c(NA,3),lwd = c(NA,2),pch=c(19,NA),col="black",bty = "n")
lines(revisions,robusttests)
textxy(revisions,robusttests,labs = raw_robusttests, offset = -1,cex = 0.5)
abline(v=1,col="black",lty=3,lwd=1.5)
abline(v=8,col="black",lty=3,lwd=1.5)
abline(v=16,col="black",lty=3,lwd=1.5)
