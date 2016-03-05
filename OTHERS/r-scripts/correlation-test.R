data1 <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/AMO-Mv3-rq2.csv')
data2 <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/Fireplace-Mv1-rq2.csv')
data3 <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/Jenkins-Plugins-Mv2-rq2.csv')
data4 <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/CSV/moodle.csv')
data4 <- data4[,4:17]
list.data <- list()
list.data[[1]] <- data1
list.data[[2]] <- data2
list.data[[3]] <- data3
list.data[[4]] <- data4
featureNamesAll <- vector()
for (i in 1:length(list.data)) { 
  minPerColumn <- apply(list.data[[i]],MARGIN=2,min)
  maxPerColumn <- apply(list.data[[i]],MARGIN=2,max)
  list.data[[i]] <- list.data[[i]][,minPerColumn!=maxPerColumn]
  
  featureNames <- unique(colnames(list.data[[i]]))
  featureNames <- setdiff(featureNames,"solutionVector")
  featureNamesAll <- c(featureNamesAll, featureNames)
}
uniquefeatureNames <- unique(featureNamesAll)

corList <- list()
for(featureName in uniquefeatureNames){
   corList[[featureName]] <- vector()
}

for (i in 1:length(list.data)) { 
  for(featureName in uniquefeatureNames){
    if (featureName %in% names(list.data[[i]])) {
      corFeatureDataSet <- cor(list.data[[i]]$solutionVector,list.data[[i]][,featureName], method = "kendall")
      corList[[featureName]] <- c(corList[[featureName]],corFeatureDataSet)
      corList
    }
  }
}
dev.new()
boxplot(corList)

# data1 <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/New-CSV/Jenkins-core-plugins-combined.csv')
# minPerColumn <- apply(data1,MARGIN=2,min)
# maxPerColumn <- apply(data1,MARGIN=2,max)
# data1 <- data1[,minPerColumn!=maxPerColumn]
# colnames(data1)
# featureNames <- colnames(data1[,-which(colnames(data1)=='solutionVector')])
# featureNames
# corList <- list()
# for(featureName in featureNames){
#   corList[[featureName]] <- vector()
#   corFeatureDataSet <- cor(data1$solutionVector,data1[,featureName], method = "spearman")
#   corList[[featureName]] <- c(corList[[featureName]],corFeatureDataSet)
#   corList
# }
# # }
# boxplot(corList)

