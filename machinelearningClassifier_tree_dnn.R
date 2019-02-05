library(caret)
library(caretEnsemble)
library(Metrics)
library(rgdal)
library(raster)
library(e1071)
library(parallel)
library(doParallel)

setwd("D:\\informalsettlements\\banglore\\mosaics")

#### This one only works with bricks, not single layer rasters
r1 <- raster('lac_agg.tif')
names(r1) <- 'buildinglacunarity'
#r2 <- raster('sdbuildingsize.tif')
#names(r2) <- 'sdpatchsize'
r3 <- raster('sdethetavar_agg2_weighted.tif')
names(r3) <- 'varianceofthetaofSDE'
r4 <- raster('numberbuildings.tif')
names(r4) <- 'numpatches'
rcanny <- raster('canny_mosaic.tif')
r5 <- aggregate(rcanny, fact=50, fun=sum, na.rm=T)
names(r5) <- 'numedges'


#rharalick <- brick('haralick3_mosaic.tif')

#r7 <- clusterR(rharalick, raster::aggregate, args = list(fact=50, fun=median, na.rm=T))
#r7 <- aggregate(rharalick, fact=50, fun=median, na.rm=T, file="haralick3_agg100_med.tif")


r7 <- brick('haralick3_agg100.tif')
names(r7) <- paste0('haralick', 1:10, sep="")

#r8 <- raster('mbi_pantex.tif')
#r8 <- aggregate(r8, fact=50, fun=mean, na.rm=T)

#r9 <- raster('mbi_mosaic.tif')
#r9 <- aggregate(r9, fact=50, fun=sd, na.rm=T)
#names(r9) <- 'mbi_sd'

#r10 <- raster('ndvi_wbi')
#r10 <- aggregate(r10>0.4, fact=50, fun=sum, na.rm=T)
#writeRaster(r10, filename = 'ndvi_wbi_100m.tif')
#r10 <- brick('ndvi_wbi_100m.tif')
#r11 <- raster('ndvi_agg.tif')

#resample(r10, r1, method='ngb', filename="ndvi_wbi_100m_v2.tif", overwrite=T)
#resample(r11, r1, method='ngb', filename="ndvi_agg_v2.tif", overwrite=T)
#r10 <- brick("ndvi_wbi_100m_v2.tif")
#names(r10) <- c('ndvimean', 'wbimean')
#r12 <- calc(r10, function(x){x[,1]-x[,2]})
r11 <- raster('ndvi_agg_v2.tif')
names(r11) <- 'vegetationspacing'

r12 <- raster('D:\\Google Drive\\Bangalore Project\\Ancillary Data\\road_rast2.tif')
r12 <- aggregate(r12, fact=50, fun=sum, na.rm=T)
r12 <- resample(r12, r1, method='ngb', filename="road_dens.tif", overwrite=T)
names(r12) <- "roaddens"

r13 <- raster('D:\\Google Drive\\Bangalore Project\\Ancillary Data\\majorRoads_dist.tif')
r13 <- resample(r13, r1, method='ngb')
names(r13) <- "majorRoadDist"


#r14 <- raster('D:\\Google Drive\\Bangalore Project\\Ancillary Data\\RailDist.img')
#r14 <- resample(r14, r1, method='ngb')

r15 <- raster('D:\\Google Drive\\Bangalore Project\\Ancillary Data\\waterbody_dist.tif')
r15 <- resample(r15, r1, method='ngb')

#mulimage <- brick("D:\\Google Drive\\Bangalore Project\\Georeferenced Mosaics\\MUL_mosaic_415.tif")
#r16 <- aggregate(mulimage, fact=50, fun=mean, na.rm=T)
#r16 <- resample(r16, r1, method='ngb', filename="MUL_agg.tif")
r16 <- brick('MUL_agg.tif')
names(r16) <- paste0("MS_", c('coastal', 'blue', 'green', 'yellow', 'red', 'rededge', 'nir1', 'nir2'))


r <- brick(r1,r3,r5,r7[[10]],r11,r12, r13, r15, r16)

#names(r) <- c('lacunarity', 'sdpatchsize', 'sdethetavar', 'numberpatch', 'edgeDens', 'edgeskew',, )
#trainData <- readOGR('/Users/nikhilkaza/Desktop/trainingbuff2.shp', layer='trainingbuff2')
trainValidateData <- readOGR('D:\\Google Drive\\Bangalore Project\\Training Data\\September_trainingData\\mansi_trainingdataseptember2017_trainValidate.shp', layer='mansi_trainingdataseptember2017_trainValidate')
trainValidateData$Class <- as.factor(paste(trainValidateData$CaseID, trainValidateData$Category, sep="_"))

trainData <- trainValidateData[trainValidateData$trainORval=='train',]
validationData <- trainValidateData[trainValidateData$trainORval=='validate',]


responseCol <- 'Class'

TrdfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(r)) + 1))   
ValdfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(r)) + 1))   

for (i in 1:length(unique(trainData[[responseCol]]))){                          
  category <- unique(trainData[[responseCol]])[i]
  Trcategorymap <- trainData[trainData[[responseCol]] == category,]
  TrdataSet <- extract(r, Trcategorymap)
  TrdataSet <- TrdataSet[!unlist(lapply(TrdataSet, is.null))]
  TrdataSet <- lapply(TrdataSet, function(x){cbind(x, class = rep(category, nrow(x)))})
  Trdf <- do.call("rbind", TrdataSet)
  TrdfAll <- rbind(TrdfAll, Trdf)
  
  Valcategorymap <- validationData[validationData[[responseCol]] == category,]
  ValdataSet <- extract(r, Valcategorymap)
  ValdataSet <- ValdataSet[!unlist(lapply(ValdataSet, is.null))]
  ValdataSet <- lapply(ValdataSet, function(x){cbind(x, class = rep(category, nrow(x)))})
  Valdf <- do.call("rbind", ValdataSet)
  ValdfAll <- rbind(ValdfAll, Valdf)
}

TrdfAll$class <- factor(TrdfAll$class, labels=make.names(levels(trainValidateData$Class)))
ValdfAll$class <- factor(ValdfAll$class, labels=make.names(levels(trainValidateData$Class)))

TrdfAll <- TrdfAll[complete.cases(TrdfAll),]
                                                
#nsamples <- 300
#sdfAll <- subset(dfAll[sample(1:nrow(dfAll), nsamples), ])
control <- trainControl(method="repeatedcv", number=10, repeats=3, savePredictions='final', classProbs=TRUE)
algorithmList <- c('xgbTree', 'svmRadial')


nThreads <- detectCores(logical = TRUE)
cl <- makeCluster(nThreads-1)
registerDoParallel(cl)
set.seed(30)

#modFit <- train(class ~ ., method = 'xgbTree', data = TrdfAll, preProcess = c('scale', 'center'), trControl=control, tuneLength=10)
#modFit2 <- train(as.factor(class) ~ ., method = 'dnn', data = dfAll, preProcess = c('scale', 'center'), trControl=control, numepochs=500)
#modFit2
#varImp(modFit2, scale=F)

models <- caretList(class~., data=TrdfAll, trControl=control, methodList=algorithmList)
results <- resamples(models)
summary(results)
dotplot(results)
modelCor(results)
splom(results)

stackControl <- trainControl(method="repeatedcv", number=10, repeats=3, savePredictions=TRUE, classProbs=TRUE)
set.seed(30)
stack.glm <- caretStack(models, method="glm", metric="Accuracy", trControl=stackControl)
print(stack.glm)

stopCluster(cl)
registerDoSEQ()



beginCluster()
predrast <- clusterR(r, raster::predict, args = list(model = modFit, type="prob"))
writeRaster(predrast, file="D:\\informalsettlements\\banglore\\classificationwork\\pred_xgbTree_nov_prob.tif", overwrite=T)
predrast <- clusterR(r, raster::predict, args = list(model = modFit))
writeRaster(predrast, file="D:\\informalsettlements\\banglore\\classificationwork\\pred_xgbTree_nov.tif", overwrite=T, datatype="INT2S")

endCluster()






