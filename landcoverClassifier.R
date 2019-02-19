library(plyr)
library(dplyr)
library(caret)
library(xgboost)
library(Metrics)
library(rgdal)
library(raster)
library(e1071)
library(doParallel)
library(magrittr)


#### functions ###

### Create a stratified sample of training data.

strat_sample <- function(data, gr_variab, tr_percent, thresh_test = 0, seed) {
  
  stopifnot(tr_percent > 0 & tr_percent < 1)
  
  if(require(dplyr) & require(magrittr)) {
    
    if(!missing(seed)) set.seed(seed)
    
    names0 <- names(data)
    gr_variab <- which(names0 == gr_variab)
    names(data) <- make.unique(c("n", "tRows", "SET", names0))[-(1:3)]
    gr_variab <- names(data)[gr_variab]        
    
    data %<>% 
      sample_frac %>% 
      group_by_(gr_variab) %>%
      mutate(n = n(), tRows = round(tr_percent * n))
    
    with(data, if(any(n - tRows < thresh_test))        
      warning("Zero or too few observations in one or more groups"))
    
    data %<>%
      mutate(SET = ifelse(row_number() <= tRows, "Train", "Test")) %>%
      select(-n, -tRows) %>%
      ungroup
    
    names(data) <- make.unique(c(names0, "SET"))
    
    data
    
  }
  
}

# Classify into trainign and test.

extract_set <- function(data, whichSET) {
  
  stopifnot(is.element(whichSET, c("Train", "Test")))
  
  if(require(dplyr)) {
    
    variab <- names(data)[ncol(data)]
    condit <- get(variab, data) == whichSET
    
    data %>%
      filter_(~ condit) %>%
      select_(paste0("-", variab)) 
    
  }
}

###################


setwd("D:\\Google Drive\\Bangalore Project\\Training Data")

## Raster to be classified.

r <- brick('stacked')

names(r) <- c('Coastal', 'Blue', 'Green', 'Yellow', 'Red', 'RedEdge', 'NIR1', 'NIR2', 'MBI', 'NDBSI', 'NDVI', 'NDWI')

## Vector training datasset with Category as a the land use class

trainData <- readOGR('D:\\Google Drive\\Bangalore Project\\Training Data\\classification_featuredata.shp', layer='classification_featuredata')
trainData$Class <- trainData$Category
responseCol <- 'Class'

# Extract the raster values that fall under the polygons.

dfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(r)) + 1))   
for (i in 1:length(unique(trainData[[responseCol]]))){                          
  category <- unique(trainData[[responseCol]])[i]
  categorymap <- trainData[trainData[[responseCol]] == category,]
  dataSet <- raster::extract(r, categorymap)
  dataSet <- dataSet[!unlist(lapply(dataSet, is.null))]
  dataSet <- lapply(dataSet, function(x){cbind(x, class = as.numeric(rep(category, nrow(x))))})
  df <- do.call("rbind", dataSet)
  dfAll <- rbind(dfAll, df)
}

dfAll <- dfAll[complete.cases(dfAll),]
rm(df)
rm(dataSet)
rm(categorymap)


## Set minimum number of training rows to 100., 

groups <- strat_sample(dfAll, "class", .75, thresh_test = 1000)
with(groups, prop.table(table(class, SET), 1))

## Split to Train and Test samples.
sdfAll_train <- extract_set(groups, "Train")
sdfAll_test <- extract_set(groups, "Test")
rm(dfAll)


set.seed(20)

# The following trains the gradient boosted tree algorithm and predicts the classes for each pixel.

control <- trainControl(method="repeatedcv", number=10, repeats=3)

nThreads <- detectCores(logical = TRUE)
cl <- makeCluster(nThreads-1)
registerDoParallel(cl)
modFit <- train(as.factor(class) ~ ., method = 'xgbTree', data = sdfAll_train, preProcess = c('scale', 'center'), trControl=control, tuneLength=3)
modFit
varImp(modFit, scale=F)
predrast <- clusterR(r, raster::predict, args = list(model = modFit))
stopCluster(cl)
registerDoSEQ()

writeRaster(predrast, file="luclass_jul31.tif", overwrite=T)
save.image('landuseClass_model.RData')




