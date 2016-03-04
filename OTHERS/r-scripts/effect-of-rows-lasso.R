# Effect of order of rows on result of LASSO
# features and response from the mtcars dataset
mtcars
features <- mtcars[,2:11]
response <- mtcars[,1]

mydata <- read.csv('/Users/adityanisal/Dropbox/ExtractedResultFiles/CSV/amomv325feb.csv',header=TRUE, sep=",")

# normalized features
featuresNormalized <- scale(features,center=TRUE,scale=TRUE)
featuresNormalized
# choosing an order for shuffling rows
orderOfShufflingRows <- sample(c(1:dim(featuresNormalized)[1]),dim(featuresNormalized)[1])
orderOfShufflingRows
# normalized features, and response that are shuffled according to orderOfShufflingRows
featuresNormalizedShuffledRows <- featuresNormalized[orderOfShufflingRows,]
featuresNormalizedShuffledRows
responseShuffledRows <- response[orderOfShufflingRows]
# Performing lasso with lars
lassoWithLars <- lars(x=featuresNormalized,y=response,type="lasso")
lassoWithLarsShuffledRows <- lars(x=featuresNormalizedShuffledRows,y=responseShuffledRows,type="lasso")
# The plots look identical when lars is used for performing lasso
plot(lassoWithLars)
plot(lassoWithLarsShuffledRows)
# Performing lasso with glmnet
lassoWithGlmNet <- glmnet(x=featuresNormalized,y=response)
lassoWithGlmNetShuffledRows <- glmnet(x=featuresNormalizedShuffledRows,y=responseShuffledRows)
# The plots look identical when glmnet is used for performing lasso
plot(lassoWithGlmNet)
plot(lassoWithGlmNetShuffledRows)
